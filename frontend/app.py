from flask import Flask, render_template, request, redirect, url_for, flash
import os
from uuid import uuid4
from werkzeug.utils import secure_filename
from  utils.send_request import send_request
import psycopg2







app = Flask(__name__)
app.config["SECRET_KEY"] = "gkemhcsversion"
app.config['UPLOAD_FOLDER'] = '/mnt/azure/'



app.config['MAX_CONTENT_LENGTH'] = 16 * 1024 * 1024  # 16 MB limit

hostname = os.getenv("CONTAINER_APP_HOSTNAME", "http://localhost:8080")
instance_name = os.getenv("CONTAINER_APP_REPLICA_NAME", "localhost")
revision_id = os.getenv("CONTAINER_APP_REVISION", "12345")

ALLOWED_EXTENSIONS = {
    'video-to-audio': {'mp4', 'avi', 'mov', 'mkv'},
    'pdf-to-doc': {'pdf'},
    }


def get_db_connection():
    conn = psycopg2.connect(
        dbname=os.getenv("POSTGRES_DATABASE","converter"),
        user=os.getenv("POSTGRES_USER"),
        password=os.getenv("POSTGRES_PASSWORD"),
        host=os.getenv("POSTGRES_HOST"),
        port=os.getenv("POSTGRES_DATABASE_PORT","5432")
    )
    return conn

def create_table():
    conn = get_db_connection()
    cursor = conn.cursor()
    create_table_query = '''
    CREATE TABLE IF NOT EXISTS converter_transactions (
        serial_no SERIAL PRIMARY KEY,
        converter_type VARCHAR(50) CHECK (converter_type IN ('pdf-to-doc', 'video-to-audio', 'text-to-speech')),
        user_email VARCHAR(50),
        timestamp TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
        signed_url TEXT
    );
    '''
    cursor.execute(create_table_query)
    conn.commit()
    cursor.close()
    conn.close()

def allowed_file(filename, conversion_type):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS.get(conversion_type, set())

def get_upload_folder(conversion_type):
    return os.path.join(app.config['UPLOAD_FOLDER'], conversion_type,"inputs")

def is_authenticated():
   return request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME") is not None
 
# creating the table if it doesn't exist
create_table()


@app.route("/")
def home():
   if not is_authenticated():
        return render_template("home.html", hostname=hostname, instance_name=instance_name, revision_id=revision_id)
   
   return render_template('home.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))

@app.route("/home")
def user_home(): 
   if not is_authenticated():
        return render_template("home.html", hostname=hostname, instance_name=instance_name, revision_id=revision_id)
   
   return render_template('home.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))



@app.route("/user_validation", methods=["GET"])
def check_user():
    print(request.method)
    print("user id:- ", request.headers.get("X-MS-CLIENT-PRINCIPAL-ID"))
    print("user name:- ", request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
    return {"userid": request.headers.get("X-MS-CLIENT-PRINCIPAL-ID"), "user name": request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME")}



@app.route("/text-to-speech",methods=["GET","POST"])
def text_to_speech():
    if not is_authenticated():
        return redirect("/.auth/login/google?post_login_redirect_uri=/")
    if(request.method=="GET"):
          return render_template('text-to-speech.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
    text=request.form.get("text") 
    upload_folder = get_upload_folder('text-to-speech')
    os.makedirs(upload_folder, exist_ok=True)
    filename=f"{request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME").split("@")[0]}-{uuid4()}.txt"
  
    with open(os.path.join(upload_folder, filename),"w") as f:
        f.write(text)          
    sas_url=send_request("text-to-speech-converter",filename)
    conn = get_db_connection()
    cursor = conn.cursor()
    query = """
    INSERT INTO converter_transactions (converter_type, user_email,signed_url)
    VALUES (%s, %s ,%s)
    RETURNING serial_no, converter_type, timestamp, signed_url;
    """
    cursor.execute(query, ("text-to-speech",request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"),sas_url))
    conn.commit()
    cursor.close()
    conn.close()
    return render_template('download.html', conversion_type="text-to-speech", download_link=sas_url, hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
   



@app.route("/pdf-to-doc", methods=["POST", "GET"])
def pdf_to_doc():
    if not is_authenticated():
        return redirect("/.auth/login/google")

    if request.method == "GET":
        return render_template('pdf-to-doc.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
    
    if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
    
    file = request.files['file']
    
    if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
    
    if file and allowed_file(file.filename, 'pdf-to-doc'):
        filename = f"{request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME").split("@")[0]}-{secure_filename(file.filename).split(".")[0]}-{uuid4()}.{secure_filename(file.filename).split(".")[1]}"
        upload_folder = get_upload_folder('pdf-to-doc')
        os.makedirs(upload_folder, exist_ok=True)
        file.save(os.path.join(upload_folder, filename))
        flash('File successfully uploaded')
        sas_url=send_request("pdf-to-docx-converter",filename)
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
        INSERT INTO converter_transactions (converter_type,user_email, signed_url)
        VALUES (%s, %s,%s)
        RETURNING serial_no, converter_type, timestamp, signed_url;
        """
        cursor.execute(query, ("pdf-to-doc",request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"),sas_url))
        conn.commit()
        cursor.close()
        conn.close()
        return render_template('download.html', conversion_type="pdf-to-doc", download_link=sas_url, hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
       
    
    flash('File type not allowed')
    return redirect(request.url)



@app.route("/video-to-audio", methods=["GET", "POST"])
def video_to_audio():
    if not is_authenticated():
        return redirect("/.auth/login/google")

    if request.method == "GET":
        return render_template('video-to-audio.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
    
    if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
    
    file = request.files['file']
    
    if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
    
    if file and allowed_file(file.filename, 'video-to-audio'):
        filename = f"{request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME").split("@")[0]}-{secure_filename(file.filename).split(".")[0]}-{uuid4()}.{secure_filename(file.filename).split(".")[1]}"
        upload_folder = get_upload_folder('video-to-audio')
        os.makedirs(upload_folder, exist_ok=True)
        file.save(os.path.join(upload_folder, filename))
        flash('File successfully uploaded')
        sas_url=send_request("video-to-audio-converter",filename)
        conn = get_db_connection()
        cursor = conn.cursor()
        query = """
        INSERT INTO converter_transactions (converter_type,user_email, signed_url)
        VALUES (%s, %s,%s)
        RETURNING serial_no, converter_type, timestamp, signed_url;
        """
        cursor.execute(query, ("video-to-audio",request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"),sas_url))
        conn.commit()
        cursor.close()
        conn.close()
        return render_template('download.html', conversion_type="video-to-audio", download_link=sas_url, hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email=request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
        
    
    flash('File type not allowed')
    return redirect(request.url)



if __name__ == "__main__":
    app.run(port=8080, host="0.0.0.0", debug=True)


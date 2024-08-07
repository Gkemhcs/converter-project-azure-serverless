from flask import Flask, render_template, request, redirect, url_for, flash
import os
from werkzeug.utils import secure_filename

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

def allowed_file(filename, conversion_type):
    return '.' in filename and \
           filename.rsplit('.', 1)[1].lower() in ALLOWED_EXTENSIONS.get(conversion_type, set())

def get_upload_folder(conversion_type):
    return os.path.join(app.config['UPLOAD_FOLDER'], conversion_type)

def is_authenticated():
   return request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME") is not None

@app.route("/")
def home():
    return render_template("home.html", hostname=hostname, instance_name=instance_name, revision_id=revision_id,user_authenticated=True,user_email="gcp@gmail.com")

@app.route("/user_validation", methods=["GET"])
def check_user():
    print(request.method)
    print("user id:- ", request.headers.get("X-MS-CLIENT-PRINCIPAL-ID"))
    print("user name:- ", request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME"))
    return {"userid": request.headers.get("X-MS-CLIENT-PRINCIPAL-ID"), "user name": request.headers.get("X-MS-CLIENT-PRINCIPAL-NAME")}



@app.route("/text-to-speech",methods=["GET","POST"])
def text_to_speech():
    if not is_authenticated():
        return redirect("/.auth/login/google")
    if(request.method=="GET"):
          return render_template('text-to-speech.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id)
    text=request.form.get("text") 
   
    return "ok"



@app.route("/pdf-to-doc", methods=["POST", "GET"])
def pdf_to_doc():
    if not is_authenticated():
        return redirect("/.auth/login/google")

    if request.method == "GET":
        return render_template('pdf-to-doc.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id)
    
    if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
    
    file = request.files['file']
    
    if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
    
    if file and allowed_file(file.filename, 'pdf-to-doc'):
        filename = secure_filename(file.filename)
        upload_folder = get_upload_folder('pdf-to-doc')
        os.makedirs(upload_folder, exist_ok=True)
        file.save(os.path.join(upload_folder, filename))
        flash('File successfully uploaded')
        return redirect(url_for('download', conversion_type='pdf-to-doc', filename=filename))
    
    flash('File type not allowed')
    return redirect(request.url)



@app.route("/video-to-audio", methods=["GET", "POST"])
def video_to_audio():
    if not is_authenticated():
        return redirect("/.auth/login/google")

    if request.method == "GET":
        return render_template('video-to-audio.html', hostname=hostname, instance_name=instance_name, revision_id=revision_id, user_authenticated=True, user_email="gudi@gmail.com")
    
    if 'file' not in request.files:
        flash('No file part')
        return redirect(request.url)
    
    file = request.files['file']
    
    if file.filename == '':
        flash('No selected file')
        return redirect(request.url)
    
    if file and allowed_file(file.filename, 'video-to-audio'):
        filename = secure_filename(file.filename)
        upload_folder = get_upload_folder('video-to-audio')
        os.makedirs(upload_folder, exist_ok=True)
        file.save(os.path.join(upload_folder, filename))
        flash('File successfully uploaded')
        return redirect(url_for('download', conversion_type='video-to-audio', filename=filename))
    
    flash('File type not allowed')
    return redirect(request.url)

@app.route('/download/<conversion_type>/<filename>')
def download(conversion_type, filename):
    download_link = f'/mnt/storage/{filename}'
    return render_template('download.html', conversion_type=conversion_type, download_link=download_link, hostname=hostname, instance_name=instance_name, revision_id=revision_id)

if __name__ == "__main__":
    app.run(port=8080, host="0.0.0.0", debug=True)


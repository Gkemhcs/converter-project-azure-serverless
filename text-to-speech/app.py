from flask import Flask ,request
import os 
from utils.convert import text_to_speech
from utils.blob_upload import upload_file_to_blob
from utils.generate_sas_token import generate_blob_sas_token

app=Flask(__name__)

BLOB_CONTAINER_NAME=os.getenv("CONTAINER_NAME","staging-container")
STORAGE_ACCOUNT_NAME=os.getenv("STORAGE_ACCOUNT_NAME","stagingstoragegkem")

MOUNT_FILE_PATH=os.getenv("FILE_MOUNT_FOLDER","./texts/")
UPLOAD_FOLDER=os.getenv("UPLOAD_FOLDER","./uploads/")

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def home():
       
       return {"status":"200","message":"running healthy"}

@app.route("/convert",methods=["POST"])
def convert():
         text_filename=request.json.get("filename")
         text_file_path=MOUNT_FILE_PATH+text_filename
         audio_file_name=text_filename.split(".")[0]+".mp3"
         audio_file_path=UPLOAD_FOLDER+audio_file_name
         with open(text_file_path) as f:
                 content=f.read()
         print(content)
         text_to_speech(content,audio_file_path)
         blob_name=f"text-to-speech/{audio_file_name}"
         upload_file_to_blob(audio_file_path,BLOB_CONTAINER_NAME,blob_name,STORAGE_ACCOUNT_NAME)  
         url=generate_blob_sas_token(BLOB_CONTAINER_NAME,blob_name,STORAGE_ACCOUNT_NAME)
         print(url)
         os.remove(text_file_path)
         os.remove(audio_file_path)
         return {"sas_url":url}     


if(__name__=="__main__"):
            app.run(port=8080,host="0.0.0.0",debug=True)
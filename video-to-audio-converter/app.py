from flask import  Flask,request

import os

from utils.convert import audio_to_video
from utils.blob_upload import upload_file_to_blob
from utils.generate_sas_token import generate_blob_sas_token

app=Flask(__name__)


BLOB_CONTAINER_NAME=os.getenv("CONTAINER_NAME","staging-container")
STORAGE_ACCOUNT_NAME=os.getenv("STORAGE_ACCOUNT_NAME","stagingstoragegkem")

MOUNT_FILE_PATH=os.getenv("FILE_MOUNT_FOLDER","./videos/")
UPLOAD_FOLDER=os.getenv("UPLOAD_FOLDER","./uploads/")

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def home():
       return "working"
@app.route("/convert",methods=["POST"])
def convert():
  input_video = request.json.get("filename")
  input_video_path=f"{MOUNT_FILE_PATH}{input_video}"
  output_audio=input_video.split(".")[0]+".mp3"
  output_audio_path=f"{UPLOAD_FOLDER}{output_audio}"
  audio_to_video(input_video_path,output_audio_path)
  blob_name=f"video-to-audio/{output_audio}"
  upload_file_to_blob(output_audio_path,BLOB_CONTAINER_NAME,blob_name,STORAGE_ACCOUNT_NAME)  
  url=generate_blob_sas_token(BLOB_CONTAINER_NAME,blob_name,STORAGE_ACCOUNT_NAME)
  print(url)
  os.remove(input_video_path)
  os.remove(output_audio_path)
  return {"sas_url":url}

if(__name__=="__main__"):
        app.run(port=8080,host="0.0.0.0")



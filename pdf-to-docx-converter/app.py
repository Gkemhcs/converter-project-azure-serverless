from flask  import Flask,request 
import os,uuid
from utils.convert import  pdf_to_docx
from utils.blob_upload import upload_file_to_blob
from utils.generate_sas_token import    generate_blob_sas_token


app=Flask(__name__)

BLOB_CONTAINER_NAME=os.getenv("CONTAINER_NAME","staging-container")
STORAGE_ACCOUNT_NAME=os.getenv("STORAGE_ACCOUNT_NAME","stagingstoragegkem")

UPLOAD_FOLDER=os.getenv("UPLOAD_FOLDER","./uploads") 
FILE_MOUNT_FOLDER=os.getenv("FILE_MOUNT_FOLDER","./")

os.makedirs(UPLOAD_FOLDER, exist_ok=True)

@app.route("/")
def home():
      return "working"

@app.route("/convert",methods=["POST"])
def convert():
        pdf_filename=request.json.get("filename")

        pdf_file_path=f"{FILE_MOUNT_FOLDER}{pdf_filename}"
        docx_file_path=f"{UPLOAD_FOLDER}/{pdf_filename.split('.')[0]+'.docx'}"
        blob_name="pdf-to-doc/"+pdf_filename.split('.')[0]+'.docx'
        pdf_to_docx(pdf_file_path,docx_file_path)
        upload_file_to_blob(docx_file_path,BLOB_CONTAINER_NAME,blob_name,STORAGE_ACCOUNT_NAME)
        url=generate_blob_sas_token(BLOB_CONTAINER_NAME,blob_name,STORAGE_ACCOUNT_NAME)
        os.remove(pdf_file_path)
        os.remove(docx_file_path)
        return {"sas_url":url} 




        
        



    





if(__name__=="__main__"):
          app.run(port="8082",host="0.0.0.0")
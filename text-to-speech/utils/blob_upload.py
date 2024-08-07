# utils/upload_blob.py
from azure.storage.blob import BlobServiceClient
from azure.identity import DefaultAzureCredential,ManagedIdentityCredential
import os

def upload_file_to_blob(file, container_name, blob_name,storageaccount):
    try:
        # Use DefaultAzureCredential to get a token
        #credential = DefaultAzureCredential()
        credential=ManagedIdentityCredential(client_id=os.getenv("MANAGED_IDENTITY_CLIENT_ID"))
        blob_service_client = BlobServiceClient(
            account_url=F"https://{storageaccount}.blob.core.windows.net",
            credential=credential
        )
        print("blob name",blob_name)
        blob_client = blob_service_client.get_blob_client(container=container_name, blob=f"{blob_name}")
        print("file",file)
        # Upload the file to Azure Blob Storage
        with open(file, "rb") as data:
            blob_client.upload_blob(data, overwrite=True)
        
        print(f"File {blob_name} uploaded to {container_name} container.")
    except Exception as e:
        print(f"Error occurred: {e}")
        raise   

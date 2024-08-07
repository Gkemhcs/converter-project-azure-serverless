from azure.identity import DefaultAzureCredential,ManagedIdentityCredential
from azure.storage.blob import BlobServiceClient, BlobSasPermissions, generate_blob_sas
from datetime import datetime, timedelta, timezone
import os 
def generate_blob_sas_token(container_name, blob_name, storageaccount):
    try:
        #credential = DefaultAzureCredential()
        credential=ManagedIdentityCredential(client_id=os.getenv("MANAGED_IDENTITY_CLIENT_ID"))
        blob_service_client = BlobServiceClient(
            account_url=f"https://{storageaccount}.blob.core.windows.net",
            credential=credential
        )

        # Generate User Delegation Key
        start_time = datetime.now(timezone.utc)
        expiry_time = start_time + timedelta(minutes=10)
        user_delegation_key = blob_service_client.get_user_delegation_key(
            start_time, expiry_time
        )

        # Generate a SAS token
        sas_token = generate_blob_sas(
            account_name=blob_service_client.account_name,
            container_name=container_name,
            blob_name=blob_name,
            permission=BlobSasPermissions(read=True),
            expiry=expiry_time,
            user_delegation_key=user_delegation_key
        )

        # Construct the full URL to access the blob
        blob_url = f"https://{storageaccount}.blob.core.windows.net/{container_name}/{blob_name}?{sas_token}"
        
        return blob_url
    except Exception as e:
        print(f"Error occurred: {e}")
        raise

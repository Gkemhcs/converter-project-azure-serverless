import requests 
import os 

DAPR_BASE_URL=os.getenv('BASE_URL', 'http://localhost') + ':' + os.getenv('DAPR_HTTP_PORT', '3500')


def send_request(service,filename):
       headers = {'dapr-app-id': service, 'content-type': 'application/json'}
       response=requests.post(DAPR_BASE_URL+"/convert",json={"filename":filename},headers=headers)
       return response.json().get("sas_url")

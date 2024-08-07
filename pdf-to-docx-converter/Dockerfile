FROM python:slim

WORKDIR /home/doc-to-pdf-converter/app 

RUN useradd -ms /bin/bash doc-to-pdf-converter && chown -R doc-to-pdf-converter:doc-to-pdf-converter /home/doc-to-pdf-converter 

RUN mkdir -p /mnt/azure && chown -R doc-to-pdf-converter:doc-to-pdf-converter /mnt/azure

ENV UPLOAD_FOLDER="/mnt/azure/pdf-to-doc/outputs/"
ENV FILE_MOUNT_FOLDER="/mnt/azure/pdf-to-doc/inputs/"

USER doc-to-pdf-converter

COPY . .

RUN pip install -r requirements.txt
    
CMD ["python","app.py"]
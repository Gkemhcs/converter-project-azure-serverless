FROM python:slim

WORKDIR /home/text-to-speech-converter/app 

RUN useradd -ms /bin/bash text-to-speech-converter && chown -R text-to-speech-converter:text-to-speech-converter /home/text-to-speech-converter 

RUN mkdir -p /mnt/azure && chown -R text-to-speech-converter:text-to-speech-converter /mnt/azure

ENV UPLOAD_FOLDER="/mnt/azure/text-to-speech/outputs/"
ENV FILE_MOUNT_FOLDER="/mnt/azure/text-to-speech/inputs/"

USER text-to-speech-converter

COPY . .

RUN pip install -r requirements.txt

CMD ["python","app.py"]
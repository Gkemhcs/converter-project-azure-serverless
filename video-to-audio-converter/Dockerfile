FROM python:slim

WORKDIR /home/video-to-audio-converter/app 

RUN apt-get update && apt-get install  -y ffmpeg   

RUN useradd -ms /bin/bash video-to-audio-converter && chown -R video-to-audio-converter:video-to-audio-converter /home/video-to-audio-converter 

RUN mkdir -p /mnt/azure && chown -R video-to-audio-converter:video-to-audio-converter /mnt/azure

ENV UPLOAD_FOLDER="/mnt/azure/video-to-audio/outputs/"
ENV FILE_MOUNT_FOLDER="/mnt/azure/video-to-audio/inputs/"

USER video-to-audio-converter

COPY . .

RUN pip install -r requirements.txt

CMD ["python","app.py"]
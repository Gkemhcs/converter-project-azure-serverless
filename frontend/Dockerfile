FROM python:slim

WORKDIR /home/frontend/app 

RUN useradd -ms /bin/bash frontend && mkdir -p /mnt/azure && chown -R frontend:frontend /mnt/azure

RUN chown   -R frontend:frontend  /home/frontend/

USER frontend 

COPY . .

RUN pip install -r requirements.txt

CMD ["python","app.py"]
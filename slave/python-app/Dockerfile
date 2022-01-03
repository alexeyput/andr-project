#docker build . -t python-app

FROM alpine:latest

RUN apk update \
  && apk upgrade \
  && apk add --no-cache --update python3 py3-pip \
  && pip install --no-cache-dir flask

WORKDIR /opt/python-app
COPY . /opt/python-app

ENV FLASK_APP=/opt/python-app/python-app.py
EXPOSE 8090

CMD ["flask", "run", "--host=0.0.0.0", "--port=8090"]

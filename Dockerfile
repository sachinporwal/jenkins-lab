FROM ubuntu:22.04

RUN apt update && apt install -y curl

WORKDIR /app

COPY app/ /app/

CMD ["bash", "app.sh"]

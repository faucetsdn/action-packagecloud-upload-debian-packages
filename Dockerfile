FROM ubuntu:focal

RUN apt-get update && apt-get -y install curl git build-essential ruby ruby-dev

COPY entrypoint.sh /entrypoint.sh

ENTRYPOINT ["/entrypoint.sh"]

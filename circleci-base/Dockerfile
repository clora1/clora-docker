# vim: set ai et ts=2 sts=2 sw=2:

FROM docker:18.05.0-ce-git

ENV DOCKER_COMPOSE_VERSION 1.21.12
ENV AWSCLI_VERSION 1.15

RUN set -ex; \
    apk add --no-cache \ 
      curl \
      jq \
      python3 \
    && pip3 --no-cache-dir install awscli~=1.15 docker-compose==1.21.2 \
    && curl -L https://github.com/docker/compose/releases/download/1.21.2/docker-compose-`uname -s`-`uname -m` > ~/docker-compose \
    && chmod +x ~/docker-compose \
    && mv ~/docker-compose /usr/local/bin/docker-compose

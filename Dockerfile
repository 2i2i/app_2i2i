# docker run --name app_builder --rm -i -t debian bash
# docker run --name 4134a2aa81ea --rm -i -t 4134a2aa81ea bash

FROM node:14-alpine

RUN echo "1"

# ARG SSH_PRIVATE_KEY

# RUN mkdir -p ~/.ssh && umask 0077 && echo "${SSH_PRIVATE_KEY}" > ~/.ssh/id_rsa \
# && git config --global url."git@github.com:".insteadOf https://github.com/ \
# && ssh-keyscan github.com >> ~/.ssh/known_hosts

# ENV GOPRIVATE github.com/ghchinoy/robotreadme

COPY . /app

# Install Python and Java and pre-cache emulator dependencies.
# RUN apk add --no-cache bash
# RUN apk add --no-cache python3 py3-pip openjdk11-jre bash && \
# RUN apk add --no-cache python3 py3-pip openjdk11-jre bash && \
    # npm install -g firebase-tools && \
    # rm -rf /var/cache/apk/*
# RUN npm install -g firebase-tools

RUN echo $(pwd)

RUN echo $(ls -al)
RUN echo $(ls /app -al)
# docker run --name app_builder --rm -i -t debian bash

FROM node:14-alpine

RUN echo "hi"

# Install Python and Java and pre-cache emulator dependencies.
RUN apk add --no-cache bash
# RUN apk add --no-cache python3 py3-pip openjdk11-jre bash && \
# RUN apk add --no-cache python3 py3-pip openjdk11-jre bash && \
    # npm install -g firebase-tools && \
    # rm -rf /var/cache/apk/*
RUN npm install -g firebase-tools

RUN echo $(pwd)

RUN echo $(ls -al)
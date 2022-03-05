# docker run --name app_builder --rm -i -t debian bash
# docker run --name 4134a2aa81ea --rm -i -t 4134a2aa81ea bash

FROM node:16

RUN echo "7"

# RUN apk add --no-cache bash

# Install Dependencies.
RUN apt update -y
RUN apt install -y git

# Install Flutter.
ENV FLUTTER_ROOT="/opt/flutter"
RUN git clone -b 2.10.3 https://github.com/flutter/flutter "${FLUTTER_ROOT}"
ENV PATH="${FLUTTER_ROOT}/bin:${PATH}"
ENV ANDROID_HOME="${ANDROID_TOOLS_ROOT}"

# Disable analytics and crash reporting on the builder.
RUN flutter config  --no-analytics

# install firebase
RUN npm install -g firebase-tools

# Install Python and Java and pre-cache emulator dependencies.
# RUN apk add --no-cache python3 py3-pip openjdk11-jre bash && \
# RUN apk add --no-cache python3 py3-pip openjdk11-jre bash && \
    # npm install -g firebase-tools && \
    # rm -rf /var/cache/apk/*

# copy source code to docker
COPY . /app
WORKDIR /app

RUN flutter build web
RUN firebase deploy --only hosting

RUN echo $(pwd)
RUN echo $(ls -al)
RUN echo $(ls /app -al)
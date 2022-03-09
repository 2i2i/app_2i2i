# docker run --name app_builder --rm -i -t debian bash
# docker run --name 4134a2aa81ea --rm -i -t 4134a2aa81ea bash
# docker tag 8fb647540d62 gcr.io/i2i-test/cloudbuild

FROM node:16

RUN echo "16"

# RUN echo 1
# ADD test.bash /usr/bin
# RUN echo 2
# RUN chmod +x /usr/bin/test.bash
# RUN echo 3
# RUN /usr/bin/test.bash
# RUN echo 4
# ENTRYPOINT [ "/usr/bin/test.bash" ]

# RUN echo ${FIREBASE_TOKEN}

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
# RUN firebase use test
RUN firebase deploy --project i2i-test --only hosting

# RUN echo $(pwd)
# RUN echo $(ls -al)
# RUN echo $(ls /app -al)

# CMD ["export", "FIREBASE_TOKEN="]
# ENTRYPOINT [ "install.sh" ]
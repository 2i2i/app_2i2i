# FROM --platform=$BUILDPLATFORM cimg/android:2022.08.1-ndk
FROM cimg/android:2022.08.1-ndk
# FROM ubuntu:20.04
# FROM --platform=$BUILDPLATFORM ubuntu:20.04

USER root:root

RUN apt-get update && apt-get install -y sudo && \
# RUN apt-get update && apt-get install -y sudo && \
    echo "flutter ALL=(ALL) NOPASSWD: ALL" > /etc/sudoers.d/flutter && \
    chmod 0440 /etc/sudoers.d/flutter && \
    rm -rf /var/lib/apt/lists/*

RUN sudo apt-get update && sudo apt-get install -y bash curl file git unzip xz-utils zip libglu1-mesa
RUN sudo rm -rf /var/lib/apt/lists/*

RUN groupadd -r -g 1441 flutter && useradd --no-log-init -r -u 1441 -g flutter -m flutter
USER flutter:flutter
WORKDIR /home/flutter
# USER flutter:flutter

# RUN flutter doctor && sudo echo "WORKS"

# RUN apt-get update && \

# RUN apt-get install -y bash curl file git unzip xz-utils zip libglu1-mesa
# RUN sudo apt-get update && sudo apt-get install -y libglu1-mesa
# RUN apt-get install -y bash curl file git unzip xz-utils zip libglu1-mesa && \


# RUN groupadd -r -g 1441 flutter && useradd --no-log-init -r -u 1441 -g flutter -m flutter

# USER flutter:flutter

# WORKDIR /home/flutter

ARG flutterVersion=stable

ADD https://api.github.com/repos/flutter/flutter/compare/${flutterVersion}...${flutterVersion} /dev/null

RUN git clone https://github.com/flutter/flutter.git -b ${flutterVersion} flutter-sdk

RUN flutter-sdk/bin/flutter precache

# RUN flutter-sdk/bin/flutter config --no-analytics

# ENV PATH="$PATH:/home/flutter/flutter-sdk/bin"
# ENV PATH="$PATH:/home/flutter/flutter-sdk/bin/cache/dart-sdk/bin"

# RUN flutter doctor

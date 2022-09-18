FROM us-west1-docker.pkg.dev/app-2i2i/app2i2i-flutter-android-build/docker:base

RUN pwd
RUN ls

RUN flutter --version
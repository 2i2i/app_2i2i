FROM us-west1-docker.pkg.dev/app-2i2i/app2i2i-flutter-android-build/docker:base

WORKDIR /app_2i2i
RUN git checkout main
RUN git pull
RUN flutter build appbundle --flavor production -t lib/main.dart
RUN cd android
RUN fastlane deploy
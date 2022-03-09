# docker run --name app_builder --rm -i -t debian bash
# docker run --name 4134a2aa81ea --rm -i -t 4134a2aa81ea bash
# docker tag 8fb647540d62 gcr.io/i2i-test/cloudbuild

FROM node:16

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

ADD firebase.bash /usr/bin
RUN chmod +x /usr/bin/firebase.bash
ENTRYPOINT [ "/usr/bin/firebase.bash" ]

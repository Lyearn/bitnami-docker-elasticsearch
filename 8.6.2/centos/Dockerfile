FROM centos:centos7
RUN yum update -y

ARG ELASTICSEARCH_PLUGINS
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb:bullseye" \
      org.opencontainers.image.created="2023-03-11T09:41:15Z" \
      org.opencontainers.image.description="Application packaged by VMware, Inc" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="8.6.2-debian-11-r8" \
      org.opencontainers.image.title="elasticsearch" \
      org.opencontainers.image.vendor="VMware, Inc." \
      org.opencontainers.image.version="8.6.2"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-11" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/java/bin:/opt/bitnami/elasticsearch/bin:$PATH"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "pipefail", "-c"]
RUN mkdir -p /tmp/bitnami/pkg/cache/ && cd /tmp/bitnami/pkg/cache/ && \
    COMPONENTS=( \
      "yq-4.31.2-0-linux-${OS_ARCH}-debian-11" \
      "java-17.0.6-10-2-linux-${OS_ARCH}-debian-11" \
      "gosu-1.16.0-2-linux-${OS_ARCH}-debian-11" \
      "elasticsearch-8.6.2-1-linux-${OS_ARCH}-debian-11" \
    ) && \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://downloads.bitnami.com/files/stacksmith/${COMPONENT}.tar.gz.sha256" -O ; \
      fi && \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" && \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner --wildcards '*/files' && \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done
RUN chmod g+rwX /opt/bitnami

COPY rootfs /
RUN /opt/bitnami/scripts/elasticsearch/postunpack.sh
RUN /opt/bitnami/scripts/java/postunpack.sh
ENV APP_VERSION="8.6.2" \
    BITNAMI_APP_NAME="elasticsearch" \
    ES_JAVA_HOME="/opt/bitnami/java" \
    JAVA_HOME="/opt/bitnami/java" \
    LD_LIBRARY_PATH="/opt/bitnami/elasticsearch/jdk/lib:/opt/bitnami/elasticsearch/jdk/lib/server:$LD_LIBRARY_PATH"

EXPOSE 9200 9300

# Change the URL with a presigned time-bound url for the ZIP file from the S3 bucket
RUN curl -XGET 'https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-2.2.2.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEL7%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmFwLXNvdXRoLTEiSDBGAiEA3rySrEUyLP1rhb8xR%2FJQaFGu%2BCxKIGj0pE0MgABvakwCIQDRzTpp3MZFUrb9E%2FHJtf8n65dwIMGSmBOQhcIwEv5A8SqBAwh3EAMaDDMwNDQyNjA4ODY0MiIMVxhLvayZ65l4LLBmKt4Cyv3NDLCJAg3cJY1UqdPPTCpPq9a1E6%2BgxhgHvhgIt4s5q5EQaIy29tcNY6IczscmurT4PepfaC52bmFVvZ0rlFnbM5jQl2KA5x9LfJmd0VXpGfuYHPAItq5Q1SEiSXjnjRy2m6uVGu5Gx9rA3FlkQu0o2%2B00A9cEABgXaC4Ic3uWx4EtpwRNwxLwwtOcrEaWZ1zV2eFvESSZIvZMsBTd7yvtP%2BuDlMdgZ9fRzeEzMUzbuOal2MDfaV%2FWQ4uP%2F9iSvkiuO7ns8%2FHljBOSeTLCrgdCzWKlrRBpHA4SQxPKvEIiWSNYqPb49NerethlUsajlPdwfbyt3kNEuyZ3bwOBhbaf%2BpWt2CJSatiUDSoEDfCLqU%2FCcvOOOphdzZfAFsQiU3FADCgPy9%2FxFJkuUiQXKxnfvpNBCUV3tLFjwtOI62aWO7uoYsdc2cvWL5cobQkK%2FgJ7S07fujvvSAfOGxswtsn4pgY6sgLPsfQqGxxUz11j5KIWce%2FjY39cEJwlLJuO4TDlIpl3uO8CtmG%2BvxIKANSaYIvvVYDnrSNp%2Fib7OdN3IQBSeRx7wnV65mDobcg%2F15vowGUUap%2B3zg118EqKIlg61hawmwxaPETR5knKfliSKnGf6UYGzGkok5zEI3sL5A8%2F7ihsP0XNPrzTom86LyKtMGc3eK7%2FPwZ7AnGVf7fu8vJ14%2Bu1w3ptQipyo9csM7EXT7aLV6m3fDDM%2FimwfoV%2BEQ%2BAcVnjurlzWeSlCRWbUDRjyYDIfLX2ybiAKJFmSk62cJbm1YjnoN2CuZ4%2F%2FsagwQblgFz0ihUqPljGo%2Bf8zYcK9bdp5TnKO4gYrmuegatpcapjHL5LgJXNgIKI8Pbb11OlK5kPTdKyJviMryAEY6AboPeh%2BTA%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230817T134837Z&X-Amz-SignedHeaders=host&X-Amz-Expires=1800&X-Amz-Credential=ASIAUNYJVPDBAD2CC3XV%2F20230817%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=54cdaa336b89e891b869419b0f15a6fbe47fccfaa57c916d518bfa60968211a2' -o /bitnami/elasticsearch/plugins/left-join-2.2.2.zip -O -J -L
RUN curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-8.6.2.zip  -o /bitnami/elasticsearch/plugins/analysis-icu-8.6.2.zip -O -J -L 



USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]


USER root
RUN rpm -e --nodeps \
                  # curl \
                  # cyrus-sasl-lib \
                  # krb5-libs \
                  # libcom_err \
                  # libcurl \
                  # libidn \
                  # libssh2 \
                  # nspr \
                  # nss \
                  # nss-softokn \
                  # openldap \
                  # openssl-libs \
                  # sqlite \
                  #
                  # audit-libs \
                  # bind-license \
                  # binutils \
                  # bzip2-libs \
                  # cpio \
                  # cracklib \
                  # dbus \
                  # dbus-glib \
                  # device-mapper \
                  # dracut \
                  # elfutils-default-yama-scope \
                  # expat \
                  # file-libs \
                  # gmp \
                  # gnupg2 \
                  # gpgme \
                  # json-c \
                  # libblkid \
                  # libdb \
                  # libgcrypt \
                  # libsepol \
                  # libtasn1 \
                  # libxml2 \
                  # libxml2-python \
                  # lua \
                  # lz4 \
                  # ncurses \
                  # ncurses-base \
                  # p11-kit \
                  # p11-kit-trust \
                  # procps-ng \
                  # python \
                  # python-libs \
                  # readline \
                  # rpm \
                  # rpm-build-libs \
                  # systemd \
                  # systemd-libs \
                  # tar \
                  vim-minimal
USER 1001
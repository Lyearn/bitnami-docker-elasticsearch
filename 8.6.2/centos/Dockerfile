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
RUN curl -XGET 'https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-2.2.1.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEO%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCXVzLWVhc3QtMSJHMEUCIQC%2B3CQcd5oHblWZdrjbVfplSdBCnKxSs7Gx9VZtzkzQewIgC%2BgOz0iR9negOsarLWzJ0byOGP%2FkwchDRXptN1BTGysq%2FwIIKBADGgwzMDQ0MjYwODg2NDIiDI%2F%2BUG7rAYpQdAvlbircAkBCa7rwJsV%2Fs8FUTtzHkvVVKbV3%2B7KFQOU9e88qS1VhPEdhdcCljNCCjIPhf%2FkOsOZXR77ByIQMYD5TngyBz6%2BzURg%2BoFAYpdf2oQnWwJA0v4xEPrRloCWomeojagRluy4A3XTEapk1iwfbeLc%2BUWIK8W19DIzvrYaSB6tEbmDQ6Drp%2Fsa5lJQB5NwCpl3QZqRb0Z2ZHJRmj2AYkkj5B1m7HuK83raAleBT1MLWoOy3ojOObEP1C6LB5OqEWLqBJEMd8KT8taV0lR08rCbSLxvv4drHGwPhRrnWUcsXksfK%2B%2FjwLLGJKHfMkZJ2jRwElUHLO7IoTYRtelk9%2FuX9YuByKaSE8XGYtue4ZaY081ALm9f30jExcb1OCJJ3SDxb2NOPpe5fswrihdSzyNfLZzG41YxNVj8Xu8WTMUGclsaao7IjBjG8%2B7ikaFG82xRZ58wasV9dGP24RZ89lzCcoMGjBjqzAvGJQ54udHJLAx0IYtB3%2FvOhgtFguOZPxM7%2FNcsfYA5XpaZaeX3bXKeITAD0fEDnufkVZ5cQ%2Ba46y0PjLKNNoYB3w9K%2BvYkJBS2rdQRidIiPq5GoetJ%2BaLT%2BAlaiNdVuhlUB%2FSoL7FADFNc%2BCAyAqsnBA9xzFyQXhjk9swWR4rZJ9lCYYKNwd1sgeqCOeNhnoCf5yH2Uc5ruVBwzuGljmyHbqc48XZ58E2mq6GemCs9ql0hwCr%2BHyfZ7ogx1y3PDQkkHWeoch2N9dsMacmWmGzKr4I4WO1T%2BcqfI6LJ%2FzBN4Eo2zC8KzxSd2y147dmdSLtZ76HUjasmc7xuPMHPsFTAeaVUzoTCv9Z3%2FAOoS0Jiu0Dl2%2BmQlACA2jah9%2F3xrChtjqUWL282eXcpWKSiulk2%2BeMc%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230526T062253Z&X-Amz-SignedHeaders=host&X-Amz-Expires=3600&X-Amz-Credential=ASIAUNYJVPDBAFEY5MGY%2F20230526%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=a8735b352ac41d545cf177f73b45eb9920ec403fa5ed001a81a42d005fe0adbb' -o /bitnami/elasticsearch/plugins/left-join-2.2.1.zip -O -J -L
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
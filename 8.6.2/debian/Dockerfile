FROM docker.io/bitnami/minideb:bullseye

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
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libasound2-dev libc6 libfreetype6 libfreetype6-dev libgcc1 procps zlib1g
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
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
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
RUN curl -XGET 'https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-2.1.1.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjECgaCmFwLXNvdXRoLTEiRzBFAiEAromnj3SReSPDSPhiCxJHsgj8%2BrhIfEr1bMk8hhvSbp0CIAFyC7aPrxp%2BOKDQargnyafYgKx68C8CkV7kNChjpU5EKokDCBIQAxoMMzA0NDI2MDg4NjQyIgy8JIahtNn%2BvXbW0Ooq5gJBmTYtvYib1Lifx6a7zdjtY44qPC2i02xAUb7z12Pik6SnH0hhy0XRZgDuVwA64IfHOK4hKEa3Qvv0UoQL%2BnIOeGT3DmrqlyC21AC1E%2BAWLzklPgKv32dpHOV8h74FS5bxWHn8Uk6h374l2nHr7nfEyirTQKnFxFpD0glgLxRhwX4etBaD8J2RFThDq37IRHkgizOXw%2Bb7tiQhYPxZlAs%2FVjebKNdR6dW0LzSErd3mjZsuk1ujFlqpWX8OM7fg%2FmXQ94l0Mw0QZ9OCfiaT1c%2Brts61AxJAXLWplJrrRJm9d%2BMJi95Ldq2WNV0gEQabJkfy8LzWhA13TRRViNQsvJGSl%2FkIOgap5Vj00MDhr99tpTsalCQ78NL5v4wUkauLymt8C6GLF3VENxmbc9E1CCNaN5wdjWOtfwZCCwUYBlsj1uBLf5v3xGcdqHqEHDoIKHq18tKIUxnc1SUSkPrfJJvS1CrN4lPlMOritKEGOrMCCzOdmuNm2SE7bOPAe98Pqf3m%2Fz0mIkEif54VrxU1unDUK%2FG4IbmfMDPllBh2GDOBg7ixyE3T7bkBUYEGEg3CY8UGWmKY%2FQyavJFsx3zyVir3kA9B%2BqPN4vV4klVCWtxHGfhLPTE%2FqueZalAZLYvY5GXTyMKi40R7%2FvFljTRsp2nWetZcjVtEW%2FgKQ5%2B%2B4HAA71Xb%2BbEhmcHwk2D4UmWSDSGilwEpwj4BUs7jADRq%2FyNwsSH5wrFaJc9T4VG3lPkSV6YH3NQ%2BO7CAvW1MR7LKD2nGFdgGU95CqMZJo%2FoULyfr%2FXL6iQTEyYENlSgWJWUoYK%2B%2B1RtjDv41uhilQJWAHss%2BphR%2BACN%2Frui%2BMehhGL88AKvpvjwVe81TP8bhvbnkg4o4oUHS08ygXp9JqHONMIZHfA%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230405T083153Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIAUNYJVPDBKXQDLV7C%2F20230405%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=9a5db256e69c261fe37db230cdeacc92d6617fd1a67859f28f4540eed1627595' -o /bitnami/elasticsearch/plugins/left-join-2.1.1.zip -O -J -L 
RUN curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-8.6.2.zip  -o /bitnami/elasticsearch/plugins/analysis-icu-8.6.2.zip -O -J -L 

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]

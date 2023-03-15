FROM docker.io/bitnami/minideb:bullseye

ARG ELASTICSEARCH_PLUGINS
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb:bullseye" \
      org.opencontainers.image.created="2023-03-13T22:53:39Z" \
      org.opencontainers.image.description="Application packaged by VMware, Inc" \
      org.opencontainers.image.licenses="Apache-2.0" \
      org.opencontainers.image.ref.name="7.17.9-debian-11-r16" \
      org.opencontainers.image.title="elasticsearch" \
      org.opencontainers.image.vendor="VMware, Inc." \
      org.opencontainers.image.version="7.17.9"

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
      "elasticsearch-7.17.9-4-linux-${OS_ARCH}-debian-11" \
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
ENV APP_VERSION="7.17.9" \
    BITNAMI_APP_NAME="elasticsearch" \
    ES_JAVA_HOME="/opt/bitnami/java" \
    JAVA_HOME="/opt/bitnami/java" \
    LD_LIBRARY_PATH="/opt/bitnami/elasticsearch/jdk/lib:/opt/bitnami/elasticsearch/jdk/lib/server:$LD_LIBRARY_PATH"

EXPOSE 9200 9300

# Change the URL with a presigned time-bound url for the ZIP file from the S3 bucket
RUN curl -XGET 'https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-1.4.1.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjECwaCmFwLXNvdXRoLTEiRjBEAiAa3O9RC%2BpEFId7hTo%2BF0%2BWP%2Bu%2F50mJlR6qayy%2FU1tP3wIgGjaKzuaLTHPigNNKZm45TkYmb%2Fe0RFycoGDEBCmT3FwqigMI5f%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FARADGgwzMDQ0MjYwODg2NDIiDDseG8xXEeRCGWg2UyreAm7j6%2Ff3MA%2FQyegN4ClZjq5SrJOun0pvTcQ0l5h7X3Iu5sOOB7uZ7U0QLG7VU8lTmVbHcNrHqGLpsTgmadYDoQt5mxsDpyY7%2B5sZTnj4T3hvLpnDf%2B6IO3%2B3CCITEr58KavigFAfSqOoDMIu383%2BMjFL%2FsvUIky%2FKbfQcnx10M7zGHsVFXJZj8IWESwq2sKxN6lEXovVnHSoFB6My8%2B%2FOGGqsKAsBpzWTo7rzFmrdtDvuF%2BBuc7k06QboWHUC0qjfA4unQBrrdTUZrPZhLFrZHB3HyN5CMXXtepJPImDoeeci3Np9zZJnCSX2NJvRmSZspQI9OSAN9NBTbxur551QMYxU3wxge1U88U7hCNOmdK9m9pLj7dqM5OSnvedQadco2LI7uBqw5D0k4mCysH6ZdVa7bfcHTzBg1iTYEqoR4%2FCEzMwIzb0yyIDzj6AHeZqPnMR8HEv%2BLPMJ%2BHtHdyaMM6ExaAGOrQCyQIuK8inKQKVK4O6VckFk9MKUsx3cHbAhI59BCy3dtrrX8%2Fu9ZbiqOGjYZ%2Fe4ve2iqSoz4fDIMunzD%2F3dsXpz145W6Lcm%2BbZBvv2zxAcO%2BkMOP1yMyVNlXMp%2BACqWIj6PsRPJQuAb%2Bo7J5e8kISIMOz6jBBzBn0rpL82qoHRPalPPWdmwCxTEYbc%2FX87fJd5hk6YJP294L%2F26YlGvCGhXNBS%2BAKI3s3itgwh1q9V5H2NQ6LsQBDN%2FcYWYwSP4KqW3gw2yu8jA2VYBdda4RDpLw3NEQbGKlKGmn2wHYDz98dTBqBKI1JoCM9AI1n4lJe9hknspf1TMuDti%2BXSTJY7ge1psxd9OtqTYiwZZufC3xbctmctydpgdtjqChrGBiOn2LEm70eo8lFoOedrbg%2BcNHXtJ5w%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230315T040038Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIAUNYJVPDBIEUTD5XJ%2F20230315%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=3b1bcc33743df2224fa4c64fa4651b302b05dc636e107f4cef82f4c57fe61838' -o /bitnami/elasticsearch/plugins/left-join-1.4.1.zip -O -J -L 
RUN curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-7.17.9.zip  -o /bitnami/elasticsearch/plugins/analysis-icu-7.17.9.zip -O -J -L 

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]

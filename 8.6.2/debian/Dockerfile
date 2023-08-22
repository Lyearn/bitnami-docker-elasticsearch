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
RUN curl -XGET 'https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-2.2.3.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEDMaCmFwLXNvdXRoLTEiRzBFAiEAyAzI%2BYfNFrxI0oTgHwxgDovpP9Lm4wZJNG3r%2FrwHIEkCICvy9Z02PqtRHXFXfitkVFPhPAnQCfwNdjegGW5Upp1oKooDCOz%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQAxoMMzA0NDI2MDg4NjQyIgzvo4Zc9vYdNaJeTjoq3gJJ%2Fayyx5RNVn6kUm6sKlKpPDz4vV%2FuZMjFk5PSxSSzqR9F3dw2L4XZvtLNMxFjFiAqS4kcTJCZqCBZNdyc58TStD9YBgneaxXPq7aacCQfBa8IFXXweaxR11ruvX0wd6xRWYKaIZyPS747DYika9SdICJ4FY%2FlCzi8vX40%2FWldCgsxXOScI4uViDLMcG96Dm%2Bab5XZuyhaDzHtqboCqssltN%2BJ%2Bpz5thMMtZa26XXUC1cdWZYnOEKamPE4mbdg0RlExAFd0F1LkTv7eexg8zkRu3hFsokCqeWfCBisG0HhevaPALzC6pKWkAUNTMvp9hSZYx75kiqE3HN6VbvLicBThSFCE%2B%2FP1SsFYjDS2Wqv0czeHs9fdPpkSbRzhg5IO0GewXYgDvupMA0iOsTGl%2FaKyrCIREDah9RgAIsd%2Bt9qo5cWSBHsZ4EojfzxoBwDl3A34iP5raHXty3Cz7DMWDCRq5KnBjqzAhTwxHYbZOi3Jw8RoZxF28k1mefph48F4Hrv6h0jlfn3D4OmGs2F71gL4bKORojkCpNDdHna90T1dfYJt%2F3pZtMdWDXASBB14HxgUmADusk2pmFWCapG2thm%2FmvWgROsw2JVJ4kgBI5%2BOCGfskoKYS%2B%2FWFqUfCQF19%2Bn%2F8ldd17YzSEPTSrnEGeHXDLKzxqgGY3UnNKhlyeuonwjKQmmgessRpARzB0tgR92G1M0c8PL%2Fkwaja9GjAa7xZyJ2HLuA%2FXkCABU5FLC8LOaEIdcnpa9IoPWgmHfi89VvQ2vu79HsXl50VzPQrfq%2B%2BG11MC8W83zCoA52AA2u5wEL3qbqZGoKuy32wMG%2BVlA%2BXfKe1EGEvyuc8a8vOYhE630flhb5X%2Ft1W5crIaH%2BA4OfKqgLlKrC3w%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230822T175534Z&X-Amz-SignedHeaders=host&X-Amz-Expires=1800&X-Amz-Credential=ASIAUNYJVPDBA7E2FJVS%2F20230822%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=25df299feab67a09de6f29cd8dec30bbd3d71668cc47f64adabfa78abb77cfb4' -o /bitnami/elasticsearch/plugins/left-join-2.2.3.zip -O -J -L 
RUN curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-8.6.2.zip  -o /bitnami/elasticsearch/plugins/analysis-icu-8.6.2.zip -O -J -L 

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]

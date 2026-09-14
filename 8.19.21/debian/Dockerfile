# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM docker.io/bitnami/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG ELASTIC_DOWNLOADS_URL="artifacts.elastic.co/downloads/elasticsearch"
ARG ELASTICSEARCH_PLUGINS
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2026-09-14T00:00:00Z" \
      org.opencontainers.image.description="Application packaged by Lyearn, based on Broadcom, Inc. Bitnami container" \
      org.opencontainers.image.documentation="https://github.com/bitnami/containers/tree/main/bitnami/elasticsearch/README.md" \
      org.opencontainers.image.ref.name="8.19.21-debian-12-r1" \
      org.opencontainers.image.source="https://github.com/bitnami/containers/tree/main/bitnami/elasticsearch" \
      org.opencontainers.image.title="elasticsearch" \
      org.opencontainers.image.vendor="Lyearn" \
      org.opencontainers.image.version="8.19.21"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/java/bin:/opt/bitnami/elasticsearch/bin:$PATH"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libasound2-dev libc6 libfreetype6 libfreetype6-dev libgcc1 procps zlib1g

# yq and java are still published on Bitnami's stacksmith mirror at these
# component versions - only Elasticsearch itself has stopped being published
# there for anything past 8.18.0 (confirmed via direct HEAD checks against
# every 8.19.x patch and most 9.x versions - all 404). Elasticsearch is
# fetched from Elastic's own official distribution in a separate step below.
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "yq-4.45.1-8-linux-${OS_ARCH}-debian-12" \
      "java-21.0.7-9-0-linux-${OS_ARCH}-debian-12" \
    ) ; \
    for COMPONENT in "${COMPONENTS[@]}"; do \
      if [ ! -f "${COMPONENT}.tar.gz" ]; then \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz" -O ; \
        curl -SsLf "https://${DOWNLOADS_URL}/${COMPONENT}.tar.gz.sha256" -O ; \
      fi ; \
      sha256sum -c "${COMPONENT}.tar.gz.sha256" ; \
      tar -zxf "${COMPONENT}.tar.gz" -C /opt/bitnami --strip-components=2 --no-same-owner ; \
      rm -rf "${COMPONENT}".tar.gz{,.sha256} ; \
    done

# Fetch Elasticsearch itself from Elastic's official distribution (not
# Bitnami's mirror - see note above). The official tarball has a different
# internal layout than Bitnami's repackaged component (a single top-level
# "elasticsearch-<version>/" directory containing bin/, lib/, modules/,
# config/, plugins/, jdk/, etc.), so it's extracted with --strip-components=1
# directly into /opt/bitnami/elasticsearch to match what Bitnami's own
# scripts (elasticsearch-env.sh's ELASTICSEARCH_BASE_DIR) expect.
# The bundled jdk/ that ships inside the official tarball is removed since
# this image uses Bitnami's separately-fetched java component instead
# (ES_JAVA_HOME/JAVA_HOME point at /opt/bitnami/java, set below).
# The official tarball's own config/elasticsearch.yml is also removed:
# Bitnami's postunpack/setup.sh (libelasticsearch.sh's elasticsearch_initialize)
# only auto-generates its managed config (path.data pointed at the
# volume-mounted /bitnami/elasticsearch/data, xpack.security.enabled, etc.)
# when NO elasticsearch.yml exists yet at container first-start - if one is
# already present it assumes "custom configuration file detected, using it"
# and skips all of that, silently leaving path.data at Elasticsearch's own
# built-in default ($ES_HOME/data), which isn't writable by the non-root
# container user and crashes the node on boot (confirmed via a local test
# build - AccessDeniedException on /opt/bitnami/elasticsearch/data).
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ || exit 1 ; \
    ES_VERSION="8.19.21" ; \
    ES_ARCH="x86_64" ; \
    if [ "${OS_ARCH}" = "arm64" ]; then ES_ARCH="aarch64" ; fi ; \
    ES_TARBALL="elasticsearch-${ES_VERSION}-linux-${ES_ARCH}.tar.gz" ; \
    curl -SsLf "https://${ELASTIC_DOWNLOADS_URL}/${ES_TARBALL}" -O ; \
    curl -SsLf "https://${ELASTIC_DOWNLOADS_URL}/${ES_TARBALL}.sha512" -O ; \
    sha512sum -c "${ES_TARBALL}.sha512" ; \
    mkdir -p /opt/bitnami/elasticsearch ; \
    tar -zxf "${ES_TARBALL}" -C /opt/bitnami/elasticsearch --strip-components=1 --no-same-owner ; \
    rm -rf /opt/bitnami/elasticsearch/jdk ; \
    rm -f /opt/bitnami/elasticsearch/config/elasticsearch.yml ; \
    rm -rf "${ES_TARBALL}" "${ES_TARBALL}.sha512"

RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitnami/scripts/elasticsearch/postunpack.sh
RUN /opt/bitnami/scripts/java/postunpack.sh
ENV APP_VERSION="8.19.21" \
    BITNAMI_APP_NAME="elasticsearch" \
    ES_JAVA_HOME="/opt/bitnami/java" \
    JAVA_HOME="/opt/bitnami/java" \
    LD_LIBRARY_PATH="/opt/bitnami/elasticsearch/jdk/lib:/opt/bitnami/elasticsearch/jdk/lib/server:$LD_LIBRARY_PATH"

EXPOSE 9200 9300

# Download and install analysis-icu first (official ES plugin)
RUN mkdir -p /tmp/plugins && \
    curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-8.19.21.zip \
      -o /tmp/plugins/analysis-icu-8.19.21.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/analysis-icu-8.19.21.zip

# Move analysis-icu into plugins.default so it survives the /opt/bitnami/elasticsearch/plugins volume mount.
RUN if [ -d "/opt/bitnami/elasticsearch/plugins/analysis-icu" ]; then \
      mkdir -p /opt/bitnami/elasticsearch/plugins.default && \
      mv /opt/bitnami/elasticsearch/plugins/analysis-icu /opt/bitnami/elasticsearch/plugins.default/analysis-icu; \
    fi

# Download and install left-join plugin separately so failures are isolated.
#
# !!! ACTION NEEDED BEFORE BUILDING !!!
# The plugin zip (left-join-2.2.5.zip, built and uploaded to S3 in
# Lyearn/lyearn-elasticsearch-plugins PR #18 - see
# s3://lyearn-kubernetes/elasticsearch-plugins/left-join-2.2.5.zip) is
# private. Generate a FRESH presigned URL immediately before building this
# image and paste it in below, replacing the placeholder - presigned URLs
# expire (the previous version's URL in the 8.18.0 Dockerfile was only
# valid for 12 hours and is long dead). Do not commit a real URL to git;
# a placeholder here is intentional so a stale link never gets mistaken
# for a live one again.
RUN mkdir -p /tmp/plugins && \
    curl -XGET 'REPLACE_WITH_FRESH_PRESIGNED_URL_FOR_left-join-2.2.5.zip' \
      -o /tmp/plugins/left-join-2.2.5.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/left-join-2.2.5.zip && \
    rm -rf /tmp/plugins

# Move left-join into plugins.default so that it survives the /opt/bitnami/elasticsearch/plugins volume mount.
RUN if [ -d "/opt/bitnami/elasticsearch/plugins/left-join" ]; then \
      mkdir -p /opt/bitnami/elasticsearch/plugins.default && \
      mv /opt/bitnami/elasticsearch/plugins/left-join /opt/bitnami/elasticsearch/plugins.default/left-join; \
    fi

# Log plugin directories to help debug what is present in the built image.
RUN echo 'Contents of /opt/bitnami/elasticsearch/plugins.default (if exists):' && \
    (ls -R /opt/bitnami/elasticsearch/plugins.default || echo '  [missing or empty]') && \
    echo 'Contents of /opt/bitnami/elasticsearch/plugins (if exists):' && \
    (ls -R /opt/bitnami/elasticsearch/plugins || echo '  [missing or empty]')

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]

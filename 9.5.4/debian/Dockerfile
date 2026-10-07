# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM docker.io/bitnami/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG ELASTIC_DOWNLOADS_URL="artifacts.elastic.co/downloads/elasticsearch"
ARG ELASTICSEARCH_PLUGINS
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2026-09-17T00:00:00Z" \
      org.opencontainers.image.description="Application packaged by Lyearn, based on Broadcom, Inc. Bitnami container - services-cluster variant (left-join + analysis-icu baked into plugins.default)" \
      org.opencontainers.image.documentation="https://github.com/bitnami/containers/tree/main/bitnami/elasticsearch/README.md" \
      org.opencontainers.image.ref.name="9.5.4-debian-12-r1-lyn-lj-2.3.0" \
      org.opencontainers.image.source="https://github.com/bitnami/containers/tree/main/bitnami/elasticsearch" \
      org.opencontainers.image.title="elasticsearch" \
      org.opencontainers.image.vendor="Lyearn" \
      org.opencontainers.image.version="9.5.4"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/elasticsearch/jdk/bin:/opt/bitnami/elasticsearch/bin:$PATH"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libasound2-dev libc6 libfreetype6 libfreetype6-dev libgcc1 procps zlib1g

# yq is still published on Bitnami's stacksmith mirror at this component
# version (confirmed via direct HEAD check). No separate "java" component is
# fetched - see the JDK note below (same as the 9.5.4 monitoring variant).
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "yq-4.45.1-8-linux-${OS_ARCH}-debian-12" \
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

# Fetch Elasticsearch itself from Elastic's official distribution (Bitnami's
# mirror has never published anything past 8.18.0 for elasticsearch itself).
# The official tarball has a single top-level "elasticsearch-<version>/"
# directory (bin/, lib/, modules/, config/, plugins/, jdk/, etc.), extracted
# with --strip-components=1 directly into /opt/bitnami/elasticsearch to match
# what Bitnami's own scripts (elasticsearch-env.sh's ELASTICSEARCH_BASE_DIR)
# expect.
#
# The bundled jdk/ is KEPT (same decision as the 9.5.4 monitoring variant):
# the tarball bundles JDK 26.0.2 (Oracle build), and Elastic explicitly
# recommends running only against the bundled JVM rather than substituting
# an untested older JDK across a major-version jump. ES_JAVA_HOME/JAVA_HOME
# below point at the tarball's own jdk/ directory instead of /opt/bitnami/java.
#
# The official tarball's own config/elasticsearch.yml is still removed:
# Bitnami's postunpack/setup.sh (libelasticsearch.sh's elasticsearch_initialize)
# only auto-generates its managed config (path.data pointed at the
# volume-mounted /bitnami/elasticsearch/data, xpack.security.enabled, etc.)
# when NO elasticsearch.yml exists yet at container first-start - if one is
# already present it assumes "custom configuration file detected, using it"
# and skips all of that, silently leaving path.data at Elasticsearch's own
# built-in default ($ES_HOME/data), which isn't writable by the non-root
# container user and crashes the node on boot (same failure mode confirmed
# during the 8.19.21 build).
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ || exit 1 ; \
    ES_VERSION="9.5.4" ; \
    ES_ARCH="x86_64" ; \
    if [ "${OS_ARCH}" = "arm64" ]; then ES_ARCH="aarch64" ; fi ; \
    ES_TARBALL="elasticsearch-${ES_VERSION}-linux-${ES_ARCH}.tar.gz" ; \
    curl -SsLf "https://${ELASTIC_DOWNLOADS_URL}/${ES_TARBALL}" -O ; \
    curl -SsLf "https://${ELASTIC_DOWNLOADS_URL}/${ES_TARBALL}.sha512" -O ; \
    sha512sum -c "${ES_TARBALL}.sha512" ; \
    mkdir -p /opt/bitnami/elasticsearch ; \
    tar -zxf "${ES_TARBALL}" -C /opt/bitnami/elasticsearch --strip-components=1 --no-same-owner ; \
    rm -f /opt/bitnami/elasticsearch/config/elasticsearch.yml ; \
    rm -rf "${ES_TARBALL}" "${ES_TARBALL}.sha512"

RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitnami/scripts/elasticsearch/postunpack.sh
ENV APP_VERSION="9.5.4" \
    BITNAMI_APP_NAME="elasticsearch" \
    ES_JAVA_HOME="/opt/bitnami/elasticsearch/jdk" \
    JAVA_HOME="/opt/bitnami/elasticsearch/jdk" \
    LD_LIBRARY_PATH="/opt/bitnami/elasticsearch/jdk/lib:/opt/bitnami/elasticsearch/jdk/lib/server:$LD_LIBRARY_PATH"

EXPOSE 9200 9300

# Download and install analysis-icu first (official ES plugin)
RUN mkdir -p /tmp/plugins && \
    curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-9.5.4.zip \
      -o /tmp/plugins/analysis-icu-9.5.4.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/analysis-icu-9.5.4.zip

# Move analysis-icu into plugins.default so it survives the /opt/bitnami/elasticsearch/plugins volume mount.
RUN if [ -d "/opt/bitnami/elasticsearch/plugins/analysis-icu" ]; then \
      mkdir -p /opt/bitnami/elasticsearch/plugins.default && \
      mv /opt/bitnami/elasticsearch/plugins/analysis-icu /opt/bitnami/elasticsearch/plugins.default/analysis-icu; \
    fi

# Download and install repository-gcs (official ES plugin) so this cluster
# can register a GCS snapshot repository. Added for the HDFC nonpcidss
# blue-green migration (see HDFC Production ELK Upgrade Runbook) - the new
# 9.5.4 cluster needs this to _restore from the same GCS bucket the old
# 8.18.0 cluster snapshots into. Baked in at build time for the same reason
# as the 8.18.0 image: the live pods sit behind a firewall-level SNI block
# against artifacts.elastic.co, so a runtime ELASTICSEARCH_PLUGINS install
# would fail on every restart (the plugins dir is an emptyDir, wiped each time).
RUN mkdir -p /tmp/plugins && \
    curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/repository-gcs/repository-gcs-9.5.4.zip \
      -o /tmp/plugins/repository-gcs-9.5.4.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/repository-gcs-9.5.4.zip

# Move repository-gcs into plugins.default so it survives the /opt/bitnami/elasticsearch/plugins volume mount.
RUN if [ -d "/opt/bitnami/elasticsearch/plugins/repository-gcs" ]; then \
      mkdir -p /opt/bitnami/elasticsearch/plugins.default && \
      mv /opt/bitnami/elasticsearch/plugins/repository-gcs /opt/bitnami/elasticsearch/plugins.default/repository-gcs; \
    fi

# Download and install left-join plugin separately so failures are isolated.
#
# !!! ACTION NEEDED BEFORE BUILDING !!!
# The plugin zip (left-join-2.3.0.zip, built and uploaded to S3 in
# Lyearn/lyearn-elasticsearch-plugins PR #19 - see
# s3://lyearn-kubernetes/elasticsearch-plugins/left-join-2.3.0.zip) is
# private. Generate a FRESH presigned URL immediately before building this
# image and paste it in below, replacing the placeholder - presigned URLs
# expire. Do not commit a real URL to git; a placeholder here is
# intentional so a stale link never gets mistaken for a live one again.
RUN mkdir -p /tmp/plugins && \
    curl -XGET 'REPLACE_WITH_FRESH_PRESIGNED_URL_FOR_left-join-2.3.0.zip' \
      -o /tmp/plugins/left-join-2.3.0.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/left-join-2.3.0.zip && \
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

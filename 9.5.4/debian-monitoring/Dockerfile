# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM docker.io/bitnami/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG ELASTIC_DOWNLOADS_URL="artifacts.elastic.co/downloads/elasticsearch"
ARG ELASTICSEARCH_PLUGINS
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

LABEL org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2026-09-16T00:00:00Z" \
      org.opencontainers.image.description="Application packaged by Lyearn, based on Broadcom, Inc. Bitnami container - monitoring-cluster variant (no baked-in plugins, mapper-size + analysis-icu installed at runtime)" \
      org.opencontainers.image.documentation="https://github.com/bitnami/containers/tree/main/bitnami/elasticsearch/README.md" \
      org.opencontainers.image.ref.name="9.5.4-debian-12-r1-monitoring" \
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
# version (confirmed via direct HEAD check). Unlike the 8.19.21 Dockerfiles,
# no separate "java" component is fetched here - see the JDK note below.
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
# mirror has never published anything past 8.18.0 for elasticsearch itself -
# confirmed via direct HEAD checks, same as the 8.19.21 build). The official
# tarball has a single top-level "elasticsearch-<version>/" directory
# (bin/, lib/, modules/, config/, plugins/, jdk/, etc.), extracted with
# --strip-components=1 directly into /opt/bitnami/elasticsearch to match
# what Bitnami's own scripts (elasticsearch-env.sh's ELASTICSEARCH_BASE_DIR)
# expect.
#
# UNLIKE the 8.19.21 Dockerfiles: the bundled jdk/ is KEPT this time, not
# stripped and replaced with Bitnami's separately-fetched java component.
# Confirmed by downloading the real 9.5.4 tarball and reading jdk/release
# directly: it bundles JDK 26.0.2 (Oracle build) - a huge jump from
# Bitnami's stacksmith java-21.0.7 component the 8.19.21 pattern used.
# Elastic explicitly recommends running only against the bundled JVM, and
# substituting an untested older JDK for a major-version jump is exactly
# the kind of risk not worth taking. ES_JAVA_HOME/JAVA_HOME below point at
# the tarball's own jdk/ directory instead of /opt/bitnami/java.
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

# No plugins are baked into this image. Unlike the services-cluster image
# (9.5.4/debian, which needs the custom left-join plugin baked in),
# monitoring-cluster only needs official plugins (analysis-icu, mapper-size),
# which the Bitnami chart already installs at container STARTUP via the
# `plugins: "analysis-icu,mapper-size"` values.yaml setting -> ELASTICSEARCH_PLUGINS
# env var -> libelasticsearch.sh's elasticsearch_install_plugins(), which runs
# `elasticsearch-plugin install -b <name>` against Elastic's own plugin
# repository automatically. Confirmed this is how it already works today
# on 8.19.21 - no image-level change needed here beyond the version bump.

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]

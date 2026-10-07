# Copyright Broadcom, Inc. All Rights Reserved.
# SPDX-License-Identifier: APACHE-2.0

FROM docker.io/bitnami/minideb:bookworm

ARG DOWNLOADS_URL="downloads.bitnami.com/files/stacksmith"
ARG ELASTICSEARCH_PLUGINS
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"
ARG TARGETARCH

LABEL com.vmware.cp.artifact.flavor="sha256:c50c90cfd9d12b445b011e6ad529f1ad3daea45c26d20b00732fae3cd71f6a83" \
      org.opencontainers.image.base.name="docker.io/bitnami/minideb:bookworm" \
      org.opencontainers.image.created="2025-04-28T09:29:48Z" \
      org.opencontainers.image.description="Application packaged by Broadcom, Inc." \
      org.opencontainers.image.documentation="https://github.com/bitnami/containers/tree/main/bitnami/elasticsearch/README.md" \
      org.opencontainers.image.ref.name="8.18.0-debian-12-r2" \
      org.opencontainers.image.source="https://github.com/bitnami/containers/tree/main/bitnami/elasticsearch" \
      org.opencontainers.image.title="elasticsearch" \
      org.opencontainers.image.vendor="Broadcom, Inc." \
      org.opencontainers.image.version="8.18.0"

ENV HOME="/" \
    OS_ARCH="${TARGETARCH:-amd64}" \
    OS_FLAVOUR="debian-12" \
    OS_NAME="linux" \
    PATH="/opt/bitnami/common/bin:/opt/bitnami/java/bin:/opt/bitnami/elasticsearch/bin:$PATH"

COPY prebuildfs /
SHELL ["/bin/bash", "-o", "errexit", "-o", "nounset", "-o", "pipefail", "-c"]
# Install required system packages and dependencies
RUN install_packages ca-certificates curl libasound2-dev libc6 libfreetype6 libfreetype6-dev libgcc1 procps zlib1g
RUN mkdir -p /tmp/bitnami/pkg/cache/ ; cd /tmp/bitnami/pkg/cache/ || exit 1 ; \
    COMPONENTS=( \
      "yq-4.45.1-8-linux-${OS_ARCH}-debian-12" \
      "java-21.0.7-9-0-linux-${OS_ARCH}-debian-12" \
      "elasticsearch-8.18.0-1-linux-${OS_ARCH}-debian-12" \
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
RUN apt-get update && apt-get upgrade -y && \
    apt-get clean && rm -rf /var/lib/apt/lists /var/cache/apt/archives
RUN chmod g+rwX /opt/bitnami
RUN find / -perm /6000 -type f -exec chmod a-s {} \; || true

COPY rootfs /
RUN /opt/bitnami/scripts/elasticsearch/postunpack.sh
RUN /opt/bitnami/scripts/java/postunpack.sh
ENV APP_VERSION="8.18.0" \
    BITNAMI_APP_NAME="elasticsearch" \
    ES_JAVA_HOME="/opt/bitnami/java" \
    JAVA_HOME="/opt/bitnami/java" \
    LD_LIBRARY_PATH="/opt/bitnami/elasticsearch/jdk/lib:/opt/bitnami/elasticsearch/jdk/lib/server:$LD_LIBRARY_PATH"

EXPOSE 9200 9300

# Download and install analysis-icu first (official ES plugin)
RUN mkdir -p /tmp/plugins && \
    curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-8.18.0.zip \
      -o /tmp/plugins/analysis-icu-8.18.0.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/analysis-icu-8.18.0.zip

# Move analysis-icu into plugins.default so it survives the /opt/bitnami/elasticsearch/plugins volume mount.
RUN if [ -d "/opt/bitnami/elasticsearch/plugins/analysis-icu" ]; then \
      mkdir -p /opt/bitnami/elasticsearch/plugins.default && \
      mv /opt/bitnami/elasticsearch/plugins/analysis-icu /opt/bitnami/elasticsearch/plugins.default/analysis-icu; \
    fi

# Download and install repository-gcs (official ES plugin) so this cluster
# can register a GCS snapshot repository. Added for the HDFC nonpcidss
# blue-green migration (see HDFC Production ELK Upgrade Runbook) - the live
# nonpcidss pods confirmed a firewall-level SNI block against
# artifacts.elastic.co (TCP connects, TLS ClientHello gets reset), so this
# MUST be baked in at build time rather than installed at runtime via
# ELASTICSEARCH_PLUGINS - the build environment has normal internet egress,
# the air-gapped live pods do not.
RUN mkdir -p /tmp/plugins && \
    curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/repository-gcs/repository-gcs-8.18.0.zip \
      -o /tmp/plugins/repository-gcs-8.18.0.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/repository-gcs-8.18.0.zip

# Move repository-gcs into plugins.default so it survives the /opt/bitnami/elasticsearch/plugins volume mount.
RUN if [ -d "/opt/bitnami/elasticsearch/plugins/repository-gcs" ]; then \
      mkdir -p /opt/bitnami/elasticsearch/plugins.default && \
      mv /opt/bitnami/elasticsearch/plugins/repository-gcs /opt/bitnami/elasticsearch/plugins.default/repository-gcs; \
    fi

# Download and install left-join plugin separately so failures are isolated.
RUN mkdir -p /tmp/plugins && \
    curl -XGET 'https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-2.2.4.zip?response-content-disposition=inline&X-Amz-Content-Sha256=UNSIGNED-PAYLOAD&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEOD%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEaCmFwLXNvdXRoLTEiRzBFAiEAmJsNp%2Bv17pHX4RzZXgZ%2FLiLs7yIfoe2hEYxS%2FFUs5wACIHoxJ5ycqYK9BUHnDiAgux0N9fk5ODhspe4INCq4%2FkRWKtkDCKn%2F%2F%2F%2F%2F%2F%2F%2F%2F%2FwEQBBoMMzA0NDI2MDg4NjQyIgxFhnHLeOVBLLTLMk0qrQMReJvkfJyIx2XjolSzxzyDH8SNq1V9nKlZALBrx3lCcS%2FpKes%2F5gKdtKIQ9p6Slt7o542CMvbdX6kZpiw4gRMJoKofVlGANAstNyBb%2FPg4l4JQ9YFkuu2hDiQ2AR3gNyAbJgZS2wz7VysG5kJ%2FyyVBt%2FI0uc8O%2FDfAesoHjzIY%2FlRsNffm3fiNHTVv%2B8yWYXeFlbSvXieOOMLDGyOWW%2FSBy9eAtYqn6CDOYNTei1ty%2BWbekBUPrILJISKztnTlIp1yvLpczX%2BKRmsHWMHEoGK%2BERnBxd0ds3d2Bg5UTfQRm%2B%2B%2FBwbU9XrtcXtyPuzkBnumm1JP1lti6rhAchMkEGo3O5my%2Bm9%2FrWtE2Tf3CMkdiFw%2B42RfRnu%2FaVBn2MV95Pbqy6O1rDsz2HO0l35xJGgKL5sH5%2FwZxyUXatJBoDpdLSV1OwtEGR5go0ppxubx%2BYHAhtD%2FTAb2qP%2BA4JYDgbUBm%2Fkh9xEx93RMxIUYsIbPU8Gi5rZJMe7oT%2F%2BRH8fdusfBFHlMPGu9q4zd54TdEifZ8sh1BknlHMTJkyypnrCt%2Fk6%2BfeO0wSF%2BxJ42b3Mwusq8ywY63gLaUDwEgWWNpzIJa3VYp3YnSWRxsIQ51Dtd8zdcv8HrCVYPnhQ%2FMXAtrIjvJP6C3AVlvimfWG3qqHGhmggNSRkkkZUq876hgGWUsSytED9oCrMVxFMYphwSLJEwoWujVh4f3rc7JMiLpe62U8%2Bf5XIJFdLWEc54kaJ5Nwr13jOGxYlo1J2tG999iAxc5TZut4CwiCRvvRi2Mp%2FSNoTay%2FeBxKqJdDLd2oKjXqQG808WyIbW%2FBnNVOsUYrvO0nxjJr3wEBvOrM%2BriSqJiy4snMioGOm0t6nHL6NN3zBHT02YIX%2BCXDFg5XJjUkkXtJpz1wCLTYO1ICuxZ9pFv4nBoxM0fZqGW%2F4NzfOoCT25mLP4PbluF%2FGYDninLWtKqkw2i%2FrCiHgtY%2FjEq%2FQUeZZmEODlRVS5pPvzGerxkYZ%2BHW4byJZ1c7AUP9LhYjj%2BbQXrEFWbCKxyc%2BikUZg2xkHK2w%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Credential=ASIAUNYJVPDBMHNJEYCS%2F20260120%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Date=20260120T075006Z&X-Amz-Expires=43200&X-Amz-SignedHeaders=host&X-Amz-Signature=6811ad2cd45ea77795c5561a8861f7e7601d03e5e0221e1f3e9e6638711665bf' \
      -o /tmp/plugins/left-join-2.2.4.zip -O -J -L && \
    /opt/bitnami/elasticsearch/bin/elasticsearch-plugin install -b file:///tmp/plugins/left-join-2.2.4.zip && \
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

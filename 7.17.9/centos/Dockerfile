FROM centos:7
RUN yum update -y 

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
RUN curl -XGET 'https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-1.4.0.zip?response-content-disposition=inline&X-Amz-Security-Token=IQoJb3JpZ2luX2VjEBkaCmFwLXNvdXRoLTEiSDBGAiEA1jYhVwdWFK5M1kOlGlRe7O3847QhFGh1tbBirbx%2BAhMCIQD%2FLoHBSYMtU268a%2Fq2QZ2zUCq1ALm6J0yscKrV9HhyQSqSAwjS%2F%2F%2F%2F%2F%2F%2F%2F%2F%2F8BEAMaDDMwNDQyNjA4ODY0MiIMJKkv19W8jvpY5cB2KuYClemqk70%2FlNNAjviv7afOBwDzrqoLvQvQSk6pQB3wUaCcYsVp3E8lUCg2gd%2B8T8TQr1Fpk7zgpWZsgAAv6dY0bwHgoMrkoQgoGiL5XA5mcRMdSPotVP7gWf6AErb2i1l0HxOJ7ZRzQO86Eort5x%2B6JgD8PBbdpuHTslYKgJXwMVnzeF6xZUWU6498M%2F7scYy3nWiSDwd5uSB3b4xZ8bLbyqv2ObwgKra6geGBZE6QMIb7UsDTKJkPQd1x%2FFfVp1XJCf9jmbk5MwjSBZh99D9F5BMsl0Us5vv%2F%2FMPJH3sJTzOpPuMFCks1BsMIJSQjDAfn8wLaEAsU4E0voLZqVe%2BWJP63M%2FZRC%2B%2FkQ7txGGXsQeLkGCUqL954CHz68vlF2NtjFJnj61DbYoP5iuw3bh9IS2sYAdxt5AbswaMbX019bwfryy6t1bipkMJohxgJSFbM7%2BN%2FUytPjGJIkcaR5z2K4ld9nnOH%2BDCWt8CgBjqyAgFy1CmChJKy33mWwFZ3bstOoXmyzpKTQzbalKuLcgs3W2TMkc%2Fi2EcGMESiYVNGjBajtGVpcvdWQW7IYjR00BOaDcpW1AgP8UYYMYXO6R9ew74zbI%2BcZiukC8CrIrD1dpAWIZbbA6CipsogRljVIZU9BRHCHiWhFewUmODsY3oTUtTMBcZFk8DpTwK%2B8bS7Pd%2BokJufBlqyvFlIXR%2FPtiaMW4gF4kaNqTIVmPPIc3fvLlKbNspPfdDeGpD7RX%2FE88kCe1%2FPE1N5quTrCthEocC%2BX4WlhdxQty6F6azvR%2FGHzo9T81DqXg7vnyxjsKoREjepNGiDi8NHuvMGfncejMf8qu8wOwOhkJkcQ%2FVqDyTzFab0EKO4K%2Bifi270eIBP%2F3UB8QChvGd2I3B%2B5nBbrptrUg%3D%3D&X-Amz-Algorithm=AWS4-HMAC-SHA256&X-Amz-Date=20230314T090010Z&X-Amz-SignedHeaders=host&X-Amz-Expires=43200&X-Amz-Credential=ASIAUNYJVPDBNY2OR4V2%2F20230314%2Fap-south-1%2Fs3%2Faws4_request&X-Amz-Signature=65660bbf963d71d6a072ddb7c5d90e96a2806ee26fd2a8fa4104221b67367a54' -o /bitnami/elasticsearch/plugins/left-join-1.4.0.zip -O -J -L 
RUN curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-7.17.9.zip  -o /bitnami/elasticsearch/plugins/analysis-icu-7.17.9.zip -O -J -L 

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]

# Vulnerability solving
USER root
RUN rpm -e --nodeps \
                  vim-minimal
USER 1001
FROM centos:7
LABEL maintainer "Bitnami <containers@bitnami.com>"

RUN yum update -y 

ENV HOME="/" \
  OS_ARCH="amd64" \
  OS_FLAVOUR="debian-10" \
  OS_NAME="linux" \
  PATH="/opt/bitnami/common/bin:/opt/bitnami/java/bin:/opt/bitnami/elasticsearch/bin:$PATH"

ARG ELASTICSEARCH_PLUGINS=""
ARG JAVA_EXTRA_SECURITY_DIR="/bitnami/java/extra-security"


COPY prebuildfs /
# Install required system packages and dependencies
# RUN install_packages acl ca-certificates curl gzip hostname libasound2-dev libc6 libfreetype6 libfreetype6-dev libgcc1 procps tar zlib1g
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "yq" "4.16.2-2" --checksum 1c135708aaa8cb69936471de63563de08e97b7d0bfb4126d41b54a149557c5c0
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "java" "11.0.13-1" --checksum cf2e298428d67fb30c376ee6638c055afe54cc1f282bab314abc53a34c37be44
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "gosu" "1.14.0-1" --checksum 16f1a317859b06ae82e816b30f98f28b4707d18fe6cc3881bff535192a7715dc
RUN . /opt/bitnami/scripts/libcomponent.sh && component_unpack "elasticsearch" "7.14.2-0" --checksum 9e9bc8244fd4eae6e475c90b73086bfd047391fb456e062ded7e5eed192c918d
# RUN apt-get update && apt-get upgrade -y && \
#   rm -r /var/lib/apt/lists /var/cache/apt/archives

RUN chmod g+rwX /opt/bitnami

COPY rootfs /
RUN /opt/bitnami/scripts/elasticsearch/postunpack.sh
RUN /opt/bitnami/scripts/java/postunpack.sh
ENV BITNAMI_APP_NAME="elasticsearch" \
  BITNAMI_IMAGE_VERSION="7.14.2-debian-10-r1" \
  JAVA_HOME="/opt/bitnami/java" \
  LD_LIBRARY_PATH="/opt/bitnami/elasticsearch/jdk/lib:/opt/bitnami/elasticsearch/jdk/lib/server:$LD_LIBRARY_PATH"

EXPOSE 9200 9300
RUN ls -l
# add plugins 
RUN curl -XGET https://lyearn-kubernetes.s3.ap-south-1.amazonaws.com/elasticsearch-plugins/left-join-1.2.1.zip -o /bitnami/elasticsearch/plugins/left-join-1.2.1.zip -O -J -L 

RUN curl -XGET https://artifacts.elastic.co/downloads/elasticsearch-plugins/analysis-icu/analysis-icu-7.14.2.zip  -o /bitnami/elasticsearch/plugins/analysis-icu-7.14.2.zip -O -J -L 

USER 1001
ENTRYPOINT [ "/opt/bitnami/scripts/elasticsearch/entrypoint.sh" ]
CMD [ "/opt/bitnami/scripts/elasticsearch/run.sh" ]

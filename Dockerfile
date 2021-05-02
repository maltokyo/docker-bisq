FROM ghcr.io/linuxserver/baseimage-rdesktop-web:bionic

ARG BUILD_DATE
ARG VERSION
ARG BISQ_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  CUSTOM_PORT="8080" \
  GUIAUTOSTART="true" \
  HOME="/config"

RUN echo "**** install git-lfs ****" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends curl jq ca-certificates && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git-lfs && \
    git lfs install && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${build_deps} && \
    rm -r /var/lib/apt/lists/* && \


  echo "**** install BISQ ****" && \
  
  mkdir -p \
    /opt/BISQ && \
  #if [ -z ${BISQ_RELEASE+x} ]; then \
  #  BISQ_RELEASE=$(curl -sX GET "https://github.com/bisq-network/bisq/releases/latest" \
  #  | jq -r .tag_name); \
  #fi && \
  #BISQ_VERSION="$(echo ${BISQ_RELEASE} | cut -c2-)" && \
  
  cd /opt/BISQ && \
  git clone --depth 1 --branch v1.6.2 https://github.com/bisq-network/bisq && \
  #git clone --depth 1 --branch ${BISQ_VERSION} https://github.com/bisq-network/bisq && \
  cd bisq && \
  git lfs pull && \
  ./gradlew build && \


  dbus-uuidgen > /etc/machine-id && \


  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*


COPY root/ /
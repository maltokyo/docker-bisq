FROM ghcr.io/linuxserver/baseimage-rdesktop-web:bionic

# set version label
ARG BUILD_DATE
ARG VERSION
ARG BISQ_RELEASE
LABEL build_version="Linuxserver.io version:- ${VERSION} Build-date:- ${BUILD_DATE}"
LABEL maintainer="aptalca"

ENV \
  CUSTOM_PORT="8080" \
  GUIAUTOSTART="true" \
  HOME="/config"

  echo "**** install git-lfs ****" && \

RUN build_deps="curl" && \
    apt-get update && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends ${build_deps} ca-certificates && \
    curl -s https://packagecloud.io/install/repositories/github/git-lfs/script.deb.sh | bash && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends git-lfs && \
    git lfs install && \
    DEBIAN_FRONTEND=noninteractive apt-get purge -y --auto-remove ${build_deps} && \
    rm -r /var/lib/apt/lists/* && \

  echo "**** install other deps ****" && \
    DEBIAN_FRONTEND=noninteractive apt-get install -y --no-install-recommends jq && \

  echo "**** install BISQ ****" && \
  mkdir -p \
    /opt/BISQ && \
  if [ -z ${BISQ_RELEASE+x} ]; then \
    BISQ_RELEASE=$(curl -sX GET "https://github.com/bisq-network/bisq/releases/latest" \
    | jq -r .tag_name); \
  fi && \
  BISQ_VERSION="$(echo ${BISQ_RELEASE} | cut -c2-)" && \
  
  cd /opt/BISQ && \
  git clone --depth 1 --branch ${BISQ_VERSION} https://github.com/bisq-network/bisq && \
  cd bisq && \
  git lfs pull && \
  ./gradlew build && \


#  /opt/BISQ/BISQ_postinstall && \
#  dbus-uuidgen > /etc/machine-id && \


  echo "**** cleanup ****" && \
  apt-get clean && \
  rm -rf \
    /tmp/* \
    /var/lib/apt/lists/* \
    /var/tmp/*

# add local files
COPY root/ /

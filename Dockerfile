FROM armhf/alpine:latest
MAINTAINER armswarm

# metadata params
ARG PROJECT_NAME
ARG BUILD_DATE
ARG VCS_URL
ARG VCS_REF

# metadata
LABEL org.label-schema.schema-version="1.0" \
      org.label-schema.build-date=$BUILD_DATE \
      org.label-schema.name=$PROJECT_NAME \
      org.label-schema.url=$VCS_URL \
      org.label-schema.vcs-url=$VCS_URL \
      org.label-schema.vcs-ref=$VCS_REF \
      org.label-schema.vendor="armswarm" \
      org.label-schema.version="latest"

ARG PROMETHEUS_VERSION
ENV PROMETHEUS_VERSION=${PROMETHEUS_VERSION}

RUN \
 apk add --no-cache --virtual=build-dependencies \
	curl && \

# install syncthing
 curl -so \
 /tmp/prometheus.tar.gz -L \
    "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-armv7.tar.gz" && \
 tar xfz \
    /tmp/prometheus.tar.gz -C /tmp && \

 mkdir -p \
    /prometheus \
    /etc/prometheus \
    /usr/share/prometheus && \

 mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-armv7/prometheus /bin/prometheus && \
 mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-armv7/promtool /bin/promtool && \
 mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-armv7/prometheus.yml /etc/prometheus/prometheus.yml && \
 mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-armv7/console_libraries /usr/share/prometheus/console_libraries/ && \
 mv /tmp/prometheus-${PROMETHEUS_VERSION}.linux-armv7/consoles /usr/share/prometheus/consoles/ && \

 ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/ && \

# clean up
 apk del --purge \
	build-dependencies && \
 rm -rf \
	/tmp/*

EXPOSE 9090

VOLUME ["/prometheus"]

WORKDIR /prometheus

ENTRYPOINT ["/bin/prometheus"]

CMD ["-config.file=/etc/prometheus/prometheus.yml", \
     "-storage.local.path=/prometheus", \
     "-web.console.libraries=/usr/share/prometheus/console_libraries", \
     "-web.console.templates=/usr/share/prometheus/consoles"]

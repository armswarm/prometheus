# FROM quay.io/armswarm/alpine:3.7
FROM alpine:3.7

ARG PROMETHEUS_VERSION
ENV PROMETHEUS_VERSION=${PROMETHEUS_VERSION}

RUN \
 apk add --no-cache --virtual=.fetch-dependencies \
	curl && \
# install prometheus
 curl -so \
 /tmp/prometheus.tar.gz -L \
    "https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-armv7.tar.gz" && \
 tar xfz \
    /tmp/prometheus.tar.gz -C /tmp && \
 mkdir -p \
    /prometheus \
    /etc/prometheus \
    /usr/share/prometheus && \
 cd /tmp/prometheus-${PROMETHEUS_VERSION}.linux-armv7/ && \
 mv prometheus promtool /bin && \
 mv prometheus.yml /etc/prometheus && \
 mv console_libraries consoles /usr/share/prometheus/ && \
 ln -s /usr/share/prometheus/console_libraries /usr/share/prometheus/consoles/ /etc/prometheus/ && \
 chown -R nobody:nogroup /etc/prometheus /prometheus && \
# clean up
 apk del --purge \
	.fetch-dependencies && \
 rm -rf \
	/tmp/*

USER nobody
EXPOSE 9090

VOLUME ["/prometheus"]

WORKDIR /prometheus

ENTRYPOINT ["/bin/prometheus"]

CMD [ "--config.file=/etc/prometheus/prometheus.yml", \
      "--storage.tsdb.path=/prometheus", \
      "--web.console.libraries=/usr/share/prometheus/console_libraries", \
      "--web.console.templates=/usr/share/prometheus/consoles" ]

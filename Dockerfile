FROM alpine:latest as plugin-download

ARG TARGETARCH

RUN apk --no-cache add ca-certificates \
      && update-ca-certificates

RUN wget --no-check-certificate \
      https://github.com/hashicorp-dev-advocates/waypoint-plugin-noop/releases/download/v0.2.2/waypoint-plugin-noop_linux_${TARGETARCH}.zip && \
      unzip waypoint-plugin-noop_linux_${TARGETARCH}.zip

RUN wget --no-check-certificate \
      https://github.com/hashicorp-dev-advocates/waypoint-plugin-consul-release-controller/releases/download/v0.1.0/waypoint-plugin-consul-release-controller_linux_${TARGETARCH}.zip && \
      unzip waypoint-plugin-consul-release-controller_linux_${TARGETARCH}.zip

RUN wget --no-check-certificate \
      https://github.com/hashicorp-dev-advocates/waypoint-plugin-terraform/releases/download/v0.1.0/waypoint-plugin-terraform_linux_${TARGETARCH}.zip && \
      unzip waypoint-plugin-terraform_linux_${TARGETARCH}.zip

FROM hashicorp/waypoint-odr:latest
SHELL ["/kaniko/bin/sh", "-c"]

ENV HOME /root
ENV USER root
ENV PATH="${PATH}:/kaniko"
ENV SSL_CERT_DIR=/kaniko/ssl/certs
ENV DOCKER_CONFIG /kaniko/.docker/
ENV XDG_CONFIG_HOME=/kaniko/.config/
ENV TMPDIR /kaniko/tmp
ENV container docker

# Add certificates
COPY --from=plugin-download /etc/ssl/certs/ca-certificates.crt /kaniko/ssl/certs/ca-certificates.crt

# Add custom plugins
COPY --from=plugin-download /waypoint-plugin-noop /kaniko/.config/waypoint/plugins/waypoint-plugin-noop
COPY --from=plugin-download /waypoint-plugin-terraform /kaniko/.config/waypoint/plugins/waypoint-plugin-terraform
COPY --from=plugin-download /waypoint-plugin-consul-release-controller /kaniko/.config/waypoint/plugins/waypoint-plugin-consul-release-controller

# Add a startup command that can add any additional root certificiates to the store
# this is useful for when you want to talk to servers such as docker registries using self
# signed certificates
COPY ./odr_startup.sh /kaniko/odr_startup.sh
RUN chmod +x /kaniko/odr_startup.sh

ENTRYPOINT ["/kaniko/odr_startup.sh"]

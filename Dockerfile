FROM quay.io/projectquay/golang:1.20 as builder

ARG TARGETPLATFORM=linux/amd64
ARG BUILDPLATFORM=linix/amd64

RUN echo "Build running on $BUILDPLATFORM, building for $TARGETPLATFORM"

COPY . /tmp/kbot
WORKDIR /tmp/kbot

RUN make $TARGETPLATFORM

FROM alpine:latest as stub-builder

FROM scratch

WORKDIR /
COPY --from=builder /tmp/kbot/kbot .
COPY --from=stub-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
ENTRYPOINT ["/kbot"]
    FROM --platform=$BUILDPLATFORM  quay.io/projectquay/golang:1.20 as builder

    ARG TARGETPLATFORM
    ARG BUILDPLATFORM

    RUN echo "Build running on $BUILDPLATFORM, building for $TARGETPLATFORM"

    COPY . /tmp/kbot
    WORKDIR /tmp/kbot

    RUN make -d $TARGETPLATFORM

    FROM --platform=$BUILDPLATFORM alpine:latest as stub-builder

    FROM scratch

    WORKDIR /
    COPY --from=builder /tmp/kbot/kbot .
    COPY --from=stub-builder /etc/ssl/certs/ca-certificates.crt /etc/ssl/certs/
    ENTRYPOINT ["/kbot"]    
FROM --platform=${BUILDPLATFORM:-linux/amd64} golang:1.16-alpine AS builder
ARG TARGETPLATFORM
ARG BUILDPLATFORM
ARG VERSION
RUN echo "running on $BUILDPLATFORM, building for $TARGETPLATFORM"
WORKDIR /app
COPY . .
RUN make test && make build-binary

FROM --platform=${TARGETPLATFORM:-linux/amd64} alpine:latest as prod
RUN addgroup -S app \
    && adduser -S -G app app \
    && apk --no-cache add \
    ca-certificates
USER app
COPY --from=build  /app/bin/eth2-client-metrics-exporter /bin/eth2-client-metrics-exporter
ENTRYPOINT ["/bin/eth2-client-metrics-exporter"]

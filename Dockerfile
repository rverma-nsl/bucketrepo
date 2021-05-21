FROM golang:1.16.3 AS build
WORKDIR /go/src/app
COPY . .
RUN make build

FROM alpine:3.12.0
COPY --chown=nonroot:nonroot ./config/config.yaml /
COPY --from=build --chown=nonroot:nonroot ./go/src/app/bin /
CMD ["/bucketrepo"]

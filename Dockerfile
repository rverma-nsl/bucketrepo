FROM golang:1.16.3 AS build
WORKDIR /go/src/app
COPY . .
RUN make build

FROM gcr.io/distroless/base:nonroot

COPY --chown=nonroot:nonroot ./config/config.yaml ./
COPY --from=build --chown=nonroot:nonroot ./go/src/app/bin ./
CMD ["/home/nonroot/bucketrepo"]

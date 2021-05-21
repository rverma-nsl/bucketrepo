SHELL := /bin/bash
GO := GO111MODULE=on go
GO_NOMOD :=GO111MODULE=off go
NAME := bucketrepo
OS := $(shell uname)
MAIN_GO := ./internal
ROOT_PACKAGE := $(GIT_PROVIDER)/$(ORG)/$(NAME)
GO_VERSION := $(shell $(GO) version | sed -e 's/^[^0-9.]*\([0-9.]*\).*/\1/')
BUILDFLAGS := ''
CGO_ENABLED = 0
GOSEC := GO111MODULE=on $(GOPATH)/bin/gosec
GOLINT := GO111MODULE=on $(GOPATH)/bin/golint
IMAGE_TAG?=$(shell git rev-parse --short HEAD)


all: build fmt lint sec test

.PHONY: build
build:
	CGO_ENABLED=$(CGO_ENABLED) $(GO) build -ldflags $(BUILDFLAGS) -o bin/$(NAME) $(MAIN_GO)

.PHONY: test
test: 
	CGO_ENABLED=$(CGO_ENABLED) $(GO) test ./internal/... -test.v

.PHONY: install
install:
	GOBIN=${GOPATH}/bin $(GO) install -ldflags $(BUILDFLAGS) $(MAIN_GO)

.PHONY: fmt
fmt:
	@echo "FORMATTING"
	@FORMATTED=`$(GO) fmt ./internal/...`
	@([[ ! -z "$(FORMATTED)" ]] && printf "Fixed unformatted files:\n$(FORMATTED)") || true

.PHONY: clean
clean:
	rm -rf bin release

lint_install:
	$(GO_NOMOD) get -u golang.org/x/lint/golint

.PHONY: lint
lint: lint_install
	@echo "LINTING"
	$(GOLINT) -set_exit_status ./internal/...
	@echo "VETTING"
	$(GO) vet ./internal/...

sec_install:
	$(GO_NOMOD) get -u github.com/securego/gosec/cmd/gosec

.PHONY: sec
sec: sec_install
	@echo "SECURITY SCANNING"
	$(GOSEC) -fmt=csv ./internal/...

docker:
	docker buildx build --platform="linux/amd64,linux/arm64" --push -t ghcr.io/nslhb/bucketrepo:$(IMAGE_TAG) .
BINARY_NAME := kbot
VERSION := $(shell git describe --tags --abbrev=0 2>/dev/null)-$(shell git rev-parse --short HEAD)
REGISTRY := bergshrund
BUILD_ARCH := $(subst x86_64,amd64,$(shell uname -m))

TARGET := $(BINARY_NAME)
.DEFAULT_GOAL: $(TARGET)

SRC = $(shell find . -type f -name '*.go' -not -path "./vendor/*")

.PHONY: help no-dirty get tidy audit run clean

FIRST_TARGET := $(word 1, $(MAKECMDGOALS))

$(TARGET): TARGET_PLATFORM := $(file < PLATFORM)
$(TARGET): TARGETOS := $(firstword $(subst /, ,$(TARGET_PLATFORM)))
$(TARGET): TARGETARCH := $(lastword $(subst /, ,$(TARGET_PLATFORM)))
$(TARGET): $(SRC)
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o=${BINARY_NAME} -ldflags "-X="github.com/bergshrund/kbot/cmd.appVersion=${VERSION}

help:
	@echo -e 'Usage: make [TARGET]'
	@sed -n 's/^##//p' ${MAKEFILE_LIST} | column -t -s ':' |  sed -e 's/^/ /' | xargs echo -e

no-dirty:
	git diff --exit-code

get:
	@go get

tidy:
	@go fmt ./...
	@go mod tidy -v

audit:
	go mod verify
	go vet ./...
	go run honnef.co/go/tools/cmd/staticcheck@latest -checks=all,-ST1000,-U1000 ./...
	go run golang.org/x/vuln/cmd/govulncheck@latest ./...
	go test -race -buildvcs -vet=off ./...

.PHONY: test
test:
	@go test -v -buildvcs ./...

.PHONY: linux linux/amd64
linux linux/amd64: TARGETOS := linux
linux linux/amd64: TARGETARCH := amd64
linux linux/amd64: build

.PHONY: linux/386
linux/386: TARGETOS := linux
linux/386: TARGETARCH := 386
linux/386: build

.PHONY: linux/arm64
linux/arm64: TARGETOS := linux
linux/arm64: TARGETARCH := arm64
linux/arm64: build

.PHONY: windows windows/amd64
windows windows/amd64: TARGETOS := windows
windows windows/amd64: TARGETARCH := amd64
windows windows/amd64: build

.PHONY: windows/arm64
windows/arm64: TARGETOS := windows
windows/arm64: TARGETARCH := arm64
windows/arm64: build

.PHONY: darwin
darwin: TARGETOS := darwin
darwin: TARGETARCH := amd64
darwin: build

.PHONY: darwin/arm64
darwin/arm64: TARGETOS := darwin
darwin/arm64: TARGETARCH := arm64
darwin/arm64: build

ifeq ($(FIRST_TARGET),image)
build:
	@true
else
build: get tidy
	CGO_ENABLED=0 GOOS=${TARGETOS} GOARCH=${TARGETARCH} go build -v -o=${BINARY_NAME} -ldflags "-X="github.com/bergshrund/kbot/cmd.appVersion=${VERSION}
endif

run:
	${BINARY_NAME}

.PHONY: image
ifeq ($(lastword $(MAKECMDGOALS)),image)
image: export TARGET_PLATFORM := $(file < PLATFORM)
image: TARGETARCH := $(lastword $(subst /, ,$(TARGET_PLATFORM)))
image: TARGETARCH := $(if $(TARGETARCH),$(TARGETARCH),$(BUILD_ARCH))
image:
	@if [ @$${TARGET_PLATFORM} = '@' ]; then \
		docker build . -t ${REGISTRY}/${BINARY_NAME}:${VERSION}-${TARGETARCH}; \
	else \
		docker build . --platform=${TARGET_PLATFORM} -t ${REGISTRY}/${BINARY_NAME}:${VERSION}-${TARGETARCH}; \
	fi
else
image: TARGET_PLATFORM := $(lastword $(MAKECMDGOALS))
image: TARGETARCH := $(lastword $(subst /, ,$(TARGET_PLATFORM)))
image:
	@echo ${TARGET_PLATFORM}
	docker build . --platform=${TARGET_PLATFORM} -t ${REGISTRY}/${BINARY_NAME}:${VERSION}-${TARGETARCH}
endif

.PHONY: push
push: TARGET_PLATFORM := $(file < PLATFORM)
push: TARGETARCH := $(lastword $(subst /, ,$(TARGET_PLATFORM)))
push: TARGETARCH := $(if $(TARGETARCH),$(TARGETARCH),$(BUILD_ARCH))
push:
	docker push ${REGISTRY}/${BINARY_NAME}:${VERSION}-${TARGETARCH}

clean: export IMAGE := $(shell docker image ls ${REGISTRY}/${BINARY_NAME} -q | head -1)
clean:
	@rm -fr ${BINARY_NAME}
	@if [ @$${IMAGE} != '@' ]; then echo 'Removing image ${IMAGE}'; docker rmi -f $${IMAGE}; fi

# IMPORTANT: Don't edit or delete next comments. It's a formatted part of make help output.
# Run 'make help' to get this output
# -----------------------------------------------------------------------------------------
## :\\n
## Launch \\033[1mmake\\033[0m command without a target for building a binary for the current platform.\\n
## You can hardcode platform value using the file with the name \\033[1mPLATFORM\\033[0m\\n
## where specify the desired platform in the form: <target-os>/<target-architecture>.\\n
## For example, a \\033[1mPLATFORM\\033[0m file might contain \\033[1mlinux/arm64\\033[0m on the first line,\\n 
## which corresponds to ARM architecture for the Linux family OS.\\n
## :\\n
## \\033[1mHelper targets\\033[0m\\n
## :\\n
## help:\\t\\tprint this help message\\n
## get:\\t\\tdownload the packages named by the import paths, along with their dependencies\\n
## clean:\\t\\tremove binary and supplementary files including the last created docker image\\n
## :\\n
## \\033[1mQuality control and test targets\\033[0m\\n
## :\\n
## tidy:\\t\\tformat code and tidy modfile\\n
## audit:\\t\\trun quality control checks\\n
## test:\\t\\trun all tests\\n
## :\\n
## \\033[1mBuild targets\\033[0m\\n
## :\\n
## linux:\\t\\tbuild the application for linux/amd64\\n
## linux/arm64:\\tbuild the application for linux/arm64\\n
## linux/386:\\tbuild the application for linux/386\\n
## windows:\\tbuild the application for windows/amd64\\n
## windows/arm64:\\tbuild the application for windows/arm64\\n
## darwin:\\tbuild the application for macOS darwin/amd64\\n
## darwin/arm64:\\tbuild the application for macOS darwin/arm64\\n
## run:\\t\\trun the application\\n
## :\\n
## \\033[1mDeployment targets\\033[0m\\n
## :\\n
## image <target-platform>:\\tbuild Docker image for specified platform\\n
## push:\\t\\tPush Docker image to the registry\\n
# -----------------------------------------------------------------------------------------
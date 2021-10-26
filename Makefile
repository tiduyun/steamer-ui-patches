# Makefile for build steamer-ui patches
# by allex_wang

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

platform := linux/amd64
prefix ?= hub.tidu.io/steamer

ifndef prefix
	$(error prefix not valid)
endif

IMAGE_NAME = $(prefix)/steamer-ui-patches

ifneq ("$(wildcard .version)","")
	BUILD_VERSION := $(shell cat .version)
endif

.DEFAULT_GOAL := build

docker-build = \
	docker buildx build -t $(1) $(2)

# enable push mode: > make push=1 build
docker-build-args = \
	--label build_ver=$(BUILD_VERSION) \
	--label git_head=$(shell git rev-parse HEAD) \
	--platform=$(platform) \
	$(if $(push),--push,--load)

get-image-name = \
	$(IMAGE_NAME):$(BUILD_VERSION)

.version:
	@echo $(BUILD_VERSION) > .version

version:
	@read -p "Enter a new version: ${BUILD_VERSION:+ (current: ${BUILD_VERSION})}" v; \
	if [ "$$v" ]; then \
		echo "The publish version is: $$v"; \
		echo $$v > $(ROOT_DIR)/.version; \
	fi

build: .version
ifndef BUILD_VERSION
	$(error "'BUILD_VERSION' not defined, run 'make version' first")
endif
	$(call docker-build, $(get-image-name), $(docker-build-args)) .


clean:
	docker rmi -f $(get-image-name)

.PHONY: build

# Makefile for build steamer-ui patches
# by allex_wang

ROOT_DIR := $(shell dirname $(realpath $(firstword $(MAKEFILE_LIST))))

PREFIX ?= steamer
# image repository prefix
IMAGE_NAME = $(PREFIX)/steamer-ui-patches
BUILD_VERSION := bigdata-8.0.0

ifneq ("$(wildcard .version)","")
	BUILD_VERSION := $(shell cat .version)
endif

.DEFAULT_GOAL := build

docker-build = \
	docker buildx build -t $(1) $(2)

# enable push mode: > make push=1 build
docker-build-args = \
	--label build_ver=$(BUILD_VERSION) \
	$(if $(push),--push,--load)

get-image-name = \
	$(IMAGE_NAME):$(BUILD_VERSION)

.version:
	@echo $(BUILD_VERSION) > .version

version:
	@read -p "Enter a new version: (current: $(BUILD_VERSION)) " v; \
	if [ "$$v" ]; then \
		echo "The publish version is: $$v"; \
		echo $$v > $(ROOT_DIR)/.version; \
	fi

build: .version
	$(call docker-build, $(get-image-name), $(docker-build-args)) .

clean:
	docker rmi -f $(get-image-name)

.PHONY: build

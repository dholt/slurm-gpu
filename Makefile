PKG_VERSION ?= 2

ifdef DOCKER_APT_PROXY
  CACHES = --build-arg APT_PROXY_PORT=${DOCKER_APT_PROXY}
else
  CACHES =
endif
       
.PHONY: build tag push release clean distclean

default: clean copy

BUILD_DISTRO ?= ubuntu
ifeq ($(BUILD_DISTRO), ubuntu)
        BASE_IMAGE := ubuntu:16.04
        IMAGE_NAME := build-slurm:ubuntu-16.04
        FILE_EXT := _amd64.deb
        FILE_PRE := _
endif 
ifeq ($(BUILD_DISTRO), centos)
        BASE_IMAGE := centos:7
        IMAGE_NAME := build-slurm:centos-7
        FILE_EXT := .x86_64.rpm
        FILE_PRE := -
endif 

RELEASE_IMAGE ?= nvcr.io/nvidian_sas/${IMAGE_NAME}

.Dockerfile:
	echo FROM $(BASE_IMAGE) > .Dockerfile
	cat Dockerfile.$(BUILD_DISTRO) >> .Dockerfile

build: .Dockerfile
	docker build ${CACHES} --build-arg SLURM_VERSION=${SLURM_VERSION} --build-arg PKG_VERSION=${PKG_VERSION} -f .Dockerfile -t ${IMAGE_NAME} . 

copy: build 
	docker run --rm -ti -v ${PWD}:/out ${IMAGE_NAME} cp /tmp/slurm-build/slurm${FILE_PRE}${SLURM_VERSION}-${PKG_VERSION}${FILE_EXT} /out

dev: build
	docker run --rm -ti -v ${PWD}:/out ${IMAGE_NAME} bash

tag: build
	docker tag ${IMAGE_NAME} ${RELEASE_IMAGE}

push: tag
	docker push ${RELEASE_IMAGE}

release: push

clean:
	@rm -f .Dockerfile 2> /dev/null ||:
	@docker rm -v `docker ps -a -q -f "status=exited"` 2> /dev/null ||:
	@docker rmi `docker images -q -f "dangling=true"` 2> /dev/null ||:

distclean: clean
	@docker rmi ${IMAGE_NAME} 2> /dev/null ||:
	@docker rmi ${RELEASE_IMAGE} 2> /dev/null ||:



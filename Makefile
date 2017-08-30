BASE_IMAGE ?= ubuntu:16.04
IMAGE_NAME ?= build-slurm
RELEASE_IMAGE ?= nvcr.io/nvidian_sas/build-slurm

SLURM_VERSION=17.02.7
APT_VERSION=2

ifdef DOCKER_APT_PROXY
  CACHES = --build-arg APT_PROXY_PORT=${DOCKER_APT_PROXY}
else
  CACHES =
endif

.PHONY: build tag push release clean distclean

default: clean copy

build: 
	echo FROM ${BASE_IMAGE} > Dockerfile
	cat Dockerfile.j2 >> Dockerfile
	docker build ${CACHES} --build-arg SLURM_VERSION=${SLURM_VERSION} --build-arg APT_VERSION=${APT_VERSION} -t ${IMAGE_NAME} . 

copy: build
	docker run --rm -ti -v ${PWD}:/out ${IMAGE_NAME} cp slurm_${SLURM_VERSION}-${APT_VERSION}_amd64.deb /out

dev: build
	docker run --rm -ti -v ${PWD}:/out ${IMAGE_NAME} bash


tag: build
	docker tag ${IMAGE_NAME} ${RELEASE_IMAGE}

push: tag
	docker push ${RELEASE_IMAGE}

release: push

clean:
	@rm -f Dockerfile 2> /dev/null ||:
	@docker rm -v `docker ps -a -q -f "status=exited"` 2> /dev/null ||:
	@docker rmi `docker images -q -f "dangling=true"` 2> /dev/null ||:

distclean: clean
	@docker rmi ${IMAGE_NAME} 2> /dev/null ||:
	@docker rmi ${RELEASE_IMAGE} 2> /dev/null ||:


IMG := index.docker.io/wshihadeh/redis
IMG_TAG ?= traefik

build:
	@echo "Building docker image";
	@docker build  -t ${IMG}:${IMG_TAG} .

push:
	@echo "Push docker image";
	@docker push ${IMG}:${IMG_TAG}


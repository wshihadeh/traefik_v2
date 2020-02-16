DEPLOY_VERSION ?= v1
DEPLOY_STACK ?= traefik-stack-${DEPLOY_VERSION}.yml


config:
	@echo "Createing Docker Network"; \
	docker network create --driver=overlay --subnet=10.0.15.0/24  --attachable traefik 2>/dev/null || true;

deploy: config
	@echo "Deploy Services"; \
	docker stack deploy -c ${DEPLOY_STACK} traefik


clean:
	@echo "Perform cleanup"; \
	docker stack rm traefik
	docker network rm  traefik;
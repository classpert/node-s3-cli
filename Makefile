NAME   :=	classpert/node
TAG    :=	1.0.0
IMG    :=	${NAME}\:${TAG}
LATEST :=	${NAME}\:latest

ENV ?= development
DOCKER_COMPOSE_RUN = @docker-compose run $(DOCKER_COMPOSE_FLAGS) npm_$(ENV)
BASH_ENTRYPOINT = --entrypoint /bin/bash
NPM_RUN = $(DOCKER_COMPOSE_RUN) run
NPM_VERSION = $(DOCKER_COMPOSE_RUN) version

.PHONY: help prepare clean bump-semver dev build build-dist build-docs deploy deploy-dist deploy-docs dev-scratchpad gen-bare-scratchpad gen-vue-scratchpad update-browserslist tty down docker-build docker-push git-push

help:
	@grep -E '^[%a-zA-Z_-]+:.*?## .*$$' $(MAKEFILE_LIST) | awk 'BEGIN {FS = ":.*?## "}; {printf "\033[36m%-20s\033[0m %s\n", $$1, $$2}'

release: bump-semver git-push git-push-tags publish ## Bump to version identified by [v] and deploy | e.g make release v={minor,major,patch,$version}

publish: ## Run npm publish
	$(DOCKER_COMPOSE_RUN) publish

bump-semver:
	$(NPM_VERSION) $(v)

git-push:
	@git push origin $$(git branch --show-current)

git-push-tags:
	@git push origin --tags

tty: DOCKER_COMPOSE_FLAGS = $(BASH_ENTRYPOINT)
tty: ## Attach a tty to the app container. Usage e.g: make tty
	$(DOCKER_COMPOSE_RUN)

docker-build: Dockerfile ## Builds the docker image
	@docker build -t ${IMG} .
	@docker tag ${IMG} ${LATEST}

docker-push: ## Pushes the docker image to Dockerhub
	@docker push ${NAME}

%: | examples/%.example
	cp -n $| $@


# import DockerHub deploy config file.
dpl ?= /home/gaetan/.dockerhub.env
include $(dpl)
export $(shell sed 's/=.*//' $(dpl))

DOCKER_NAME ?=ai-deep3d#pytorch3d
DOCKER_USR ?=gaetanlandreau

#DOCKER_NAME ?=
build: ## Build the container
	 docker build -t $(DOCKER_USR)/$(DOCKER_NAME) .

build-nc: ## Build the container without caching
	 docker build --no-cache -t $(DOCKER_USR)/$(DOCKER_NAME) .

stop: ## Stop and remove a running container
	 docker stop $(DOCKER_USR)/$(DOCKER_NAME); sudo docker rm $(DOCKER_USR)/$(DOCKER_NAME)

release: build-nc publish ## Make a release by building and publishing the `{version}` ans `latest` tagged containers.

# Docker publish
publish: login publish-latest publish-version ## Publish the `{version}` ans `latest` tagged containers.

publish-latest: tag-latest ## Publish the `latest` taged container. 
	@echo 'publish latest to $(DOCKER_USR) Docker Hub.'
	docker push $(DOCKER_USR)/$(DOCKER_NAME):latest

publish-version: tag-version ## Publish the `{version}` taged container.
	@echo 'publish $(VERSION) to $(DOCKER_USR) Docker Hub.'
	docker push $(DOCKER_USR)/$(DOCKER_NAME):$(VERSION)

# Docker tagging
tag: tag-latest tag-version ## Generate container tags for the `{version}` ans `latest` tags

tag-latest: ## Generate container `{version}` tag
	@echo 'create tag latest'
	docker tag $(DOCKER_USR)/$(DOCKER_NAME) $(DOCKER_USR)/$(DOCKER_NAME):latest

tag-version: ## Generate container `latest` tag
	@echo 'create tag $(VERSION)'
	docker tag $(DOCKER_USR)/$(DOCKER_NAME) $(DOCKER_USR)/$(DOCKER_NAME):$(VERSION)

login: 
	docker login --username $(DOCKER_USR) --password $(DOCKER_PASSWORD) 

default: build 
ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: build test pull tag login push enter

DIR = .
FILE = Dockerfile
IMAGE = flaconi/jnlp-slave-py
TAG = latest

# Base image version: https://github.com/jenkinsci/docker-agent/releases/latest
JENKINS_AGENT =  3283.v92c105e0f819-8-jdk21

# Python versions: $PYTHON_MAJOR.$PYTHON_PATCH
PYTHON_MAJOR = 3.13
PYTHON_PATCH = 2

pull:
	docker pull $(shell grep FROM Dockerfile | sed 's/^FROM//g' | sed "s/\$${JENKINS_AGENT}/$(JENKINS_AGENT)/g";)

build:
	docker build \
	  --network=host \
    --build-arg JENKINS_AGENT=$(JENKINS_AGENT) \
		--build-arg PYTHON_MAJOR=$(PYTHON_MAJOR) \
    --build-arg PYTHON_PATCH=$(PYTHON_PATCH) \
		-t $(IMAGE) -f $(DIR)/$(FILE) $(DIR)

test:
	docker run --rm --entrypoint=python$(PYTHON_MAJOR) $(IMAGE) --version | grep -E '$(PYTHON_MAJOR).$(PYTHON_PATCH)$$'

tag:
	docker tag $(IMAGE) $(IMAGE):$(TAG)

login:
ifndef DOCKER_USER
	$(error DOCKER_USER must either be set via environment or parsed as argument)
endif
ifndef DOCKER_PASS
	$(error DOCKER_PASS must either be set via environment or parsed as argument)
endif
	@yes | docker login --username $(DOCKER_USER) --password $(DOCKER_PASS)

push:
	docker push $(IMAGE):$(TAG)

enter:
	docker run --rm --name $(subst /,-,$(IMAGE)) -it --entrypoint=/bin/sh $(ARG) $(IMAGE)

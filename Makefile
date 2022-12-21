ifneq (,)
.error This Makefile requires GNU Make.
endif

.PHONY: build test pull tag login push enter

DIR = .
FILE = Dockerfile
IMAGE = flaconi/jnlp-slave-py
TAG = latest

# Base image version
JENKINS_SLAVE = 4.13.3-1-jdk11

# Python versions: $PYTHON_MAJOR.PYTHON_PATCH
PYTHON_MAJOR = 3.7
PYTHON_PATCH = 9

pull:
	docker pull $(shell grep FROM Dockerfile | sed 's/^FROM//g' | sed "s/\$${JENKINS_SLAVE}/$(JENKINS_SLAVE)/g";)

build:
	docker build \
	  --network=host \
    --build-arg JENKINS_SLAVE=$(JENKINS_SLAVE) \
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

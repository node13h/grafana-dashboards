export CONTAINER_EXECUTABLE ?= docker

GIT_TAG = $(shell git tag --points-at HEAD | tail -n 1)

.PHONY: pipeline tag-pipeline update-deps

pipeline: .gitlab-ci-local-variables.yml
	./run-pipeline.sh branch

tag-pipeline: .gitlab-ci-local-variables.yml
	./run-pipeline.sh tag $(GIT_TAG)

update-deps:
	./update-deps.sh

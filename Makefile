.PHONY: pipeline tag-pipeline update-deps

pipeline: .gitlab-ci-local-variables.yml
	./run-pipeline.sh branch

tag-pipeline: .gitlab-ci-local-variables.yml
	./run-pipeline.sh tag

update-deps:
	./update-deps.sh

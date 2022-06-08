VERSION ?= 'latest'
work_dir ?= $(shell pwd)

# This will output the help for each task
# thanks to https://marmelab.com/blog/2016/02/29/auto-documented-makefile.html
.PHONY: help

help: ## This help
	@awk 'BEGIN {FS = ":.*?## "} /^[a-zA-Z_-]+:.*?## / {printf "\033[36m%-30s\033[0m %s\n", $$1, $$2}' $(MAKEFILE_LIST)

build: ## Common way for images building
		docker build -t luckycatalex/kalilinux:${VERSION} .

run: ## Common way for images runnig
	docker run --rm -v $(work_dir):/work_dir -it luckycatalex/kalilinux:${VERSION} bash
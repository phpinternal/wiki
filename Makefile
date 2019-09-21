.SILENT:
.DEFAULT_GOAL := serve
.PHONY: help build serve new clean

COLOR_RESET   = \033[0m
COLOR_INFO    = \033[32m
COLOR_COMMENT = \033[33m
COLOR_ERROR   = \033[31m

ifneq ($(shell [ -e .env ] && echo yes),yes)
$(shell cp .env.dist .env)
endif

include .env

ifndef PORT
override PORT="1313"
endif
ifndef BIND
override BIND="0.0.0.0"
endif
ifndef OUTPUT
override OUTPUT="$(PWD)/public/"
endif
ifndef SOURCE
override SOURCE="$(PWD)"
endif

HUGO := $(shell command -v hugo 2> /dev/null)
ifndef HUGO
    DOCKER := $(shell command -v docker 2> /dev/null)
    ifdef DOCKER
    OUTPUT_HOST := $(OUTPUT)
    HUGO=$(DOCKER) run --rm=true -it -v $(PWD):/src -v $(OUTPUT_HOST):/output -p $(PORT):$(PORT) jojomi/hugo /usr/local/sbin/hugo
    override SOURCE="/src"
    override OUTPUT="/output"
   	else
    $(error "No hugo or docker in $(PATH), consider installing one of them")
    endif
endif

## Outputs this help screen
help:
	printf "${COLOR_COMMENT}Usage:${COLOR_RESET}\n"
	printf " make [target]\n\n"
	printf "${COLOR_COMMENT}Available targets:${COLOR_RESET}\n"
	awk '/^[a-zA-Z\-\_0-9\.@]+:/ { \
		helpMessage = match(lastLine, /^## (.*)/); \
		if (helpMessage) { \
			helpCommand = substr($$1, 0, index($$1, ":")); \
			helpMessage = substr(lastLine, RSTART + 3, RLENGTH); \
			printf " ${COLOR_INFO}%-16s${COLOR_RESET} %s\n", helpCommand, helpMessage; \
		} \
	} \
	{ lastLine = $$0 }' $(MAKEFILE_LIST)

## Build and serve static content
serve:
	$(HUGO) server --source=$(SOURCE) --watch=true --bind=$(BIND) --port=$(PORT) --destination=$(OUTPUT)

## Build static content
build:
	$(HUGO) --source=$(SOURCE) --destination=$(OUTPUT)

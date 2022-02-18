.PHONY: clean lint build test test
.DEFAULT_GOAL := help

BINDIR := $(CURDIR)/bin
BIN_NAME := go-get-proxied
HAS_GIT := $(shell command -v git;)

define PRINT_HELP_PYSCRIPT
import re, sys

for line in sys.stdin:
	match = re.match(r'^([0-9a-zA-Z_-]+):.*?## (.*)$$', line)
	if match:
		target, help = match.groups()
		print("%-20s %s" % (target, help))
endef
export PRINT_HELP_PYSCRIPT

help:  ## prints (this) help message
	@python -c "$$PRINT_HELP_PYSCRIPT" < $(MAKEFILE_LIST)

build:  ## build go binary for the current platform
	GOBIN=$(BINDIR) go install ./...

lint:  ## lint the code
	golangci-lint run -v -c .golangci.yml && \
	echo OK || (echo FAIL && exit 1)

test:  ## run unit tests
	go test -v -race -cover -coverprofile=coverage.out -run . ./...

clean:  ## delete all build, test and coverage artifacts
	go clean ./...
	rm -rf $(BINDIR)
	rm -f coverage.*

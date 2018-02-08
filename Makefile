THIS_MAKEFILE = $(lastword $(MAKEFILE_LIST))
REPOROOT = $(abspath $(dir $(THIS_MAKEFILE)))
TEST_PACKAGES = $(subst $(REPOROOT)/src/,,$(shell go list -f '{{if gt (len .TestGoFiles) 0}}{{.Dir}}{{end}}' ./...))

export GOPATH := $(REPOROOT)/

.PHONY: all
all: ankh

.PHONY: clean
clean:
	@rm -rf $(REPOROOT)/bin
	@rm -rf $(REPOROOT)/pkg

.PHONY: ankh
ankh:
	cd $(REPOROOT)/src/ankh/cmd/ankh; go install

.PHONY: install
install: ankh
	sudo cp -f $(REPOROOT)/bin/ankh /usr/local/bin/ankh

.PHONY: cover-clean
cover-clean:
	@rm -f $(REPOROOT)/src/ankh/coverage/*

.PHONY: cover-generate
cover-generate: cover-clean
	@cd $(REPOROOT)/src/ankh; $(foreach p,$(TEST_PACKAGES),go test $(p) -coverprofile=coverage/$(subst /,_,$(p)).out;)
	@cat $(REPOROOT)/src/ankh/coverage/*.out | awk 'NR==1 || !/^mode/' > $(REPOROOT)/coverage.txt

.PHONY: cover
cover: cover-generate

.PHONY: cover-html
cover-html: cover-generate
	@go tool cover -html=$(REPOROOT)/coverage.txt

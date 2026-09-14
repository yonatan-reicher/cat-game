.PHONY: default build-all test

BUILD_DIR = build
ELMJS = $(BUILD_DIR)/elm.js
ELM_FILES = $(wildcard src/*.elm src/*/*.elm)
ELM_MAIN = src/Main.elm

default: build-all

build-all: $(ELMJS)

$(ELMJS): $(ELM_FILES) | $(BUILD_DIR)
	elm make $(ELM_MAIN) --output=$(ELMJS)

$(BUILD_DIR):
	mkdir -p $@

test: $(ELM_FILES)
	elm-test

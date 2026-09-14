.PHONY: default build-all fmt

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

fmt: $(ELM_FILES)
	elm-format src/

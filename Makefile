.PHONY: default build-all test debug generate

BUILD_DIR = build
GEN_DIR = $(BUILD_DIR)/generated
ELMJS = $(BUILD_DIR)/elm.js
ELM_FILES = $(wildcard src/*.elm src/*/*.elm $(GEN_DIR)/*.elm)
ELM_MAIN = src/Main.elm

default: build-all

build-all: generate $(ELMJS)

debug: ELM_FLAGS += --debug
debug: build-all

$(ELMJS): generate $(ELM_FILES) | $(BUILD_DIR)
	elm make $(ELM_MAIN) --output=$(ELMJS) $(ELM_FLAGS)

$(BUILD_DIR):
	mkdir -p $@

$(GEN_DIR):
	mkdir -p $@

test: $(ELM_FILES)
	elm-test

generate: $(GEN_DIR)/Names.elm | $(GEN_DIR)

$(GEN_DIR)/Names.elm: src/generate_names_elm.py | $(GEN_DIR)
	python3 src/generate_names_elm.py \
		he assets/names/he \
		en assets/names/en \
		> $@

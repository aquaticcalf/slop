ODIN     ?= odin
OUT_DIR  := bin
EXE_NAME := slop

ifeq ($(OS),Windows_NT)
  EXE   := .exe
  MKDIR := if not exist $(OUT_DIR) mkdir $(OUT_DIR)
  RM    := if exist $(OUT_DIR) rmdir /s /q $(OUT_DIR)
else
  EXE   :=
  MKDIR := mkdir -p $(OUT_DIR)
  RM    := rm -rf $(OUT_DIR)
endif

COLLECTIONS := -collection:pkg=pkg
FLAGS       := $(COLLECTIONS)

.PHONY: all build run test check clean dirs help

all: help

dirs:
	@$(MKDIR)

build: dirs
	$(ODIN) build cmd/slop -out:$(OUT_DIR)/$(EXE_NAME)$(EXE) $(FLAGS)

run: build
	$(OUT_DIR)/$(EXE_NAME)$(EXE)

check:
	$(ODIN) check pkg/slop -no-entry-point $(FLAGS)
	$(ODIN) check pkg/jax -no-entry-point $(FLAGS)
	$(ODIN) check cmd/slop $(FLAGS)

test: dirs
	$(ODIN) test pkg/slop/test -out:$(OUT_DIR)/test_slop$(EXE) $(FLAGS)
	$(ODIN) test cmd/slop/test -out:$(OUT_DIR)/test_cmd_slop$(EXE) $(FLAGS)

clean:
	@$(RM)

help:
	@echo targets:
	@echo   make / make help   - show this help
	@echo   make build         - build bin/$(EXE_NAME)$(EXE)
	@echo   make run           - build and run
	@echo   make check         - typecheck packages
	@echo   make test          - run tests
	@echo   make clean         - remove $(OUT_DIR)/

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

ODIN_ROOT  := $(shell $(ODIN) root)
OLS_DIR    := $(ODIN_ROOT)/ols
ODINFMT_SRC := $(OLS_DIR)/tools/odinfmt/main.odin
ODINFMT    := $(OLS_DIR)/tools/odinfmt/odinfmt$(EXE)

COLLECTIONS := -collection:pkg=pkg
FLAGS       := $(COLLECTIONS)

.PHONY: all build run test check fmt clean dirs help setup

all: help

dirs:
	@$(MKDIR)

build: dirs
	$(ODIN) build cmd/slop -out:$(OUT_DIR)/$(EXE_NAME)$(EXE) $(FLAGS)

run: build
	$(OUT_DIR)/$(EXE_NAME)$(EXE)

setup: $(ODINFMT)

$(ODINFMT): $(ODINFMT_SRC)
	cd $(OLS_DIR)/tools/odinfmt && $(ODIN) build main.odin -file -collection:src=../../src -out:odinfmt$(EXE)

$(ODINFMT_SRC): $(OLS_DIR)
	@true

$(OLS_DIR):
	cd $(ODIN_ROOT) && git clone https://github.com/DanielGavin/ols.git

fmt: $(ODINFMT)
	$(ODINFMT) -w -path:pkg/
	$(ODINFMT) -w -path:cmd/

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
	@echo   make setup         - build odinfmt (auto if missing)
	@echo   make fmt           - format all .odin files
	@echo   make check         - typecheck packages
	@echo   make test          - run tests
	@echo   make clean         - remove $(OUT_DIR)/

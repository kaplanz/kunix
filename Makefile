# File:        Makefile
# Author:      Zakhary Kaplan <https://zakhary.dev>
# Created:     04 Nov 2024
# SPDX-License-Identifier: NONE

# --------------------
# --    Project     --
# --------------------

-include Project.mk


# --------------------
# --   Variables    --
# --------------------

# -- Directories --
# Root directory
ROOT     = .
# Base directories
OUT      = $(ROOT)/out
SRC      = $(ROOT)/src
# Build directories
BIN      = $(OUT)
OBJ      = $(OUT)/obj

# -- Files --
# Sources
SRCS    := $(shell find $(SRC) -type f -name "*.s")
OBJS    := $(SRCS:$(SRC)/%.s=$(OBJ)/%.o)
# Targets
ifneq ($(OBJS),)
GAME     = $(BIN)/$(PROJECT).gb
endif

# -- Compiler --
# Programs
RGBASM   = rgbasm
RGBFIX   = rgbfix
RGBLINK  = rgblink
# Flags
ASFLAGS += $(addprefix -I,$(INCLUDES))
LDFLAGS +=
FXFLAGS += -v                         \
	   $(if $(NOJAPAN),-j)        \
	   $(addprefix -p,$(PADBYTE))
# Recipies
COMPILE  = $(RGBASM)  $(ASFLAGS)
LINK     = $(RGBLINK) $(LDFLAGS)
PREP     = $(RGBFIX)  $(FXFLAGS)

# -- Programs --
# Runner
DEBUGGER = rugby run --gbd
EMULATOR = rugby run
# Utility
MKDIR    = mkdir -p
RM       = rm -rfv


# --------------------
# --    Targets     --
# --------------------

# Build targets
.PHONY: build
build: $(GAME)

# Clean artifacts
.PHONY: clean
clean:
	@$(RM) $(OUT)

# Run in debugger
.PHONY: dbg
dbg: $(GAME)
	@$(DEBUGGER) $^

# Run in emulator
.PHONY: run
run: $(GAME)
	@$(EMULATOR) $^


# --------------------
# --     Build      --
# --------------------

# Link executable
.PRECIOUS: $(GAME)
$(GAME): $(OBJS)
	@$(MKDIR) $(@D)
	$(LINK) $(OUTPUT_OPTION) $^
	$(PREP) $@

# Compile objects
.PRECIOUS: $(OBJ)/%.o
$(OBJ)/%.o: $(SRC)/%.s
	@$(MKDIR) $(@D)
	$(COMPILE) $(OUTPUT_OPTION) $<


# --------------------
# --      Echo      --
# --------------------

# Help information
.PHONY: help
help: version
	@echo "                                  "
	@echo "Usage:                            "
	@echo "    make [TARGET]                 "
	@echo "                                  "
	@echo "Compile:                          "
	@echo "    build         Build artifacts."
	@echo "    clean         Clean artifacts."
	@echo "                                  "
	@echo "Execute:                          "
	@echo "    dbg           Run in debugger."
	@echo "    run           Run in emulator."
	@echo "                                  "
	@echo "System:                           "
	@echo "    help          Print help.     "
	@echo "    version       Print version.  "

# Version header
.PHONY: version
version:
ifdef PROJECT
	@echo "$(PROJECT)" "$(VERSION)"
endif
ifdef AUTHOR
	@echo "$(AUTHOR)"
endif
ifdef DESCRIPTION
	@echo "$(DESCRIPTION)"
endif


# --------------------
# --    Options     --
# --------------------

# Explicitly set default goal
.DEFAULT_GOAL := build

.SUFFIXES: .gb .o .s

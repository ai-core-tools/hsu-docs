# HSU Universal Makefile - Root Coordinator
# Supports all 3 approaches in HSU Repository Portability Framework
# Version: 1.0.0

# Include project configuration (with defaults)
-include HSU_MAKEFILE_CONFIG.mk
-include Makefile.config
-include config.mk

# Auto-detect OS and Shell Environment
ifeq ($(OS),Windows_NT)
    ifneq ($(findstring msys,$(shell uname -s 2>/dev/null | tr A-Z a-z)),)
        DETECTED_OS := Windows-MSYS
        RM_RF := rm -rf
        RM := rm -f
        MKDIR := mkdir -p
        COPY := cp
        PATH_SEP := /
        EXE_EXT := .exe
        NULL_DEV := /dev/null
        SHELL_TYPE := MSYS
    else
        DETECTED_OS := Windows
        RM_RF := rmdir /s /q
        RM := del /Q /F
        MKDIR := mkdir
        COPY := copy
        PATH_SEP := \\
        EXE_EXT := .exe
        NULL_DEV := NUL
        SHELL_TYPE := CMD
    endif
else
    DETECTED_OS := $(shell uname -s)
    RM_RF := rm -rf
    RM := rm -f
    MKDIR := mkdir -p
    COPY := cp
    PATH_SEP := /
    EXE_EXT := 
    NULL_DEV := /dev/null
    SHELL_TYPE := UNIX
endif

# Compatibility aliases
EXECUTABLE_EXT := $(EXE_EXT)
RMDIR := $(RM_RF)

# Default project settings (if not configured)
PROJECT_NAME ?= hsu-project
PROJECT_DOMAIN ?= $(shell basename $(PWD) | sed 's/^hsu-//')
PROJECT_VERSION ?= 1.0.0
DEFAULT_PORT ?= 50055

# Auto-detect repository structure
ifndef REPO_TYPE
    ifneq ($(wildcard go/go.mod),)
        ifneq ($(wildcard python/pyproject.toml),)
            REPO_TYPE := multi-language
        else
            REPO_TYPE := multi-language
        endif
    else ifneq ($(wildcard go.mod),)
        REPO_TYPE := single-language-go
    else ifneq ($(wildcard pyproject.toml),)
        REPO_TYPE := single-language-python
    else ifneq ($(wildcard requirements.txt),)
        REPO_TYPE := single-language-python
    else
        REPO_TYPE := unknown
    endif
endif

# Auto-detect language directories
ifndef GO_DIR
    ifneq ($(wildcard go/go.mod),)
        GO_DIR := go
    else ifneq ($(wildcard go.mod),)
        GO_DIR := .
    else
        GO_DIR := 
    endif
endif

ifndef PYTHON_DIR
    ifneq ($(wildcard python/pyproject.toml),)
        PYTHON_DIR := python
    else ifneq ($(wildcard python/requirements.txt),)
        PYTHON_DIR := python
    else ifneq ($(wildcard pyproject.toml),)
        PYTHON_DIR := .
    else ifneq ($(wildcard requirements.txt),)
        PYTHON_DIR := .
    else
        PYTHON_DIR := 
    endif
endif

# Auto-detect enabled languages
ifndef ENABLE_GO
    ifneq ($(GO_DIR),)
        ENABLE_GO := yes
    else
        ENABLE_GO := no
    endif
endif

ifndef ENABLE_PYTHON
    ifneq ($(PYTHON_DIR),)
        ENABLE_PYTHON := yes
    else
        ENABLE_PYTHON := no
    endif
endif

# Language-specific includes
ifeq ($(ENABLE_GO),yes)
    ifneq ($(GO_DIR),)
        include HSU_MAKEFILE_GO.mk
    endif
endif

ifeq ($(ENABLE_PYTHON),yes)
    ifneq ($(PYTHON_DIR),)
        include HSU_MAKEFILE_PYTHON.mk
    endif
endif

# Default target
.DEFAULT_GOAL := help

# Global targets
.PHONY: help info clean build test setup lint format check all

## Help - Show available targets
help:
	@echo "HSU Universal Makefile ($(REPO_TYPE)) - Available Targets:"
	@echo ""
	@echo "Universal Commands:"
	@echo "  help         - Show this help message"
	@echo "  info         - Show build environment information"
	@echo "  setup        - Initialize development environment"
	@echo "  clean        - Clean all build artifacts"
	@echo "  build        - Build all enabled languages"
	@echo "  test         - Run tests for all enabled languages"
	@echo "  lint         - Run linting for all enabled languages"
	@echo "  format       - Format code for all enabled languages"
	@echo "  check        - Run all checks for all enabled languages"
	@echo ""
ifeq ($(ENABLE_GO),yes)
	@echo "Go Commands:"
	@echo "  go-build     - Build Go components"
	@echo "  go-test      - Run Go tests"
	@echo "  go-lint      - Lint Go code"
	@echo "  go-format    - Format Go code"
	@echo "  go-clean     - Clean Go artifacts"
	@echo ""
endif
ifeq ($(ENABLE_PYTHON),yes)
	@echo "Python Commands:"
	@echo "  py-build     - Build Python components"
	@echo "  py-test      - Run Python tests"
	@echo "  py-lint      - Lint Python code"
	@echo "  py-format    - Format Python code"
	@echo "  py-clean     - Clean Python artifacts"
	@echo ""
endif
	@echo "Examples:"
	@echo "  make setup && make build"
	@echo "  make test"
	@echo "  make format && make lint"

## Info - Show build environment and detected configuration
info:
	@echo "=== HSU Universal Makefile - Build Environment ==="
	@echo ""
	@echo "Environment:"
	@echo "  Detected OS: $(DETECTED_OS)"
	@echo "  Shell Type: $(SHELL_TYPE)"
	@echo "  Native OS: $(OS)"
	@echo "  Path Separator: $(PATH_SEP)"
	@echo "  Executable Extension: $(EXECUTABLE_EXT)"
	@echo ""
	@echo "Project Configuration:"
	@echo "  Project Name: $(PROJECT_NAME)"
	@echo "  Project Domain: $(PROJECT_DOMAIN)"
	@echo "  Project Version: $(PROJECT_VERSION)"
	@echo "  Repository Type: $(REPO_TYPE)"
	@echo ""
	@echo "Language Support:"
	@echo "  Go Enabled: $(ENABLE_GO)"
ifeq ($(ENABLE_GO),yes)
	@echo "    Go Directory: $(GO_DIR)"
	@echo "    Go Module: $(GO_MODULE_NAME)"
endif
	@echo "  Python Enabled: $(ENABLE_PYTHON)"
ifeq ($(ENABLE_PYTHON),yes)
	@echo "    Python Directory: $(PYTHON_DIR)"
	@echo "    Python Package: $(PYTHON_PACKAGE_NAME)"
endif
	@echo ""
	@echo "Build Configuration:"
	@echo "  Default Port: $(DEFAULT_PORT)"
	@echo "  Build CLI: $(BUILD_CLI)"
	@echo "  Build Server: $(BUILD_SRV)"
	@echo "  Build Library: $(BUILD_LIB)"

## Setup - Initialize development environment
setup:
	@echo "=== Setting up development environment ==="
ifeq ($(ENABLE_GO),yes)
	@$(MAKE) go-setup
endif
ifeq ($(ENABLE_PYTHON),yes)
	@$(MAKE) py-setup
endif
	@echo "✓ Development environment setup complete"

## Clean - Clean all build artifacts
clean:
	@echo "=== Cleaning all build artifacts ==="
ifeq ($(ENABLE_GO),yes)
	@$(MAKE) go-clean
endif
ifeq ($(ENABLE_PYTHON),yes)
	@$(MAKE) py-clean
endif
	@echo "✓ Clean complete"

## Build - Build all enabled components
build:
	@echo "=== Building all components ==="
ifeq ($(ENABLE_GO),yes)
	@$(MAKE) go-build
endif
ifeq ($(ENABLE_PYTHON),yes)
	@$(MAKE) py-build
endif
	@echo "✓ Build complete"

## Test - Run tests for all enabled languages
test:
	@echo "=== Running tests for all languages ==="
ifeq ($(ENABLE_GO),yes)
	@$(MAKE) go-test
endif
ifeq ($(ENABLE_PYTHON),yes)
	@$(MAKE) py-test
endif
	@echo "✓ Tests complete"

## Lint - Run linting for all enabled languages
lint:
	@echo "=== Running linting for all languages ==="
ifeq ($(ENABLE_GO),yes)
	@$(MAKE) go-lint
endif
ifeq ($(ENABLE_PYTHON),yes)
	@$(MAKE) py-lint
endif
	@echo "✓ Linting complete"

## Format - Format code for all enabled languages
format:
	@echo "=== Formatting code for all languages ==="
ifeq ($(ENABLE_GO),yes)
	@$(MAKE) go-format
endif
ifeq ($(ENABLE_PYTHON),yes)
	@$(MAKE) py-format
endif
	@echo "✓ Formatting complete"

## Check - Run all checks for all enabled languages
check: lint test
	@echo "✓ All checks complete"

## All - Build, test, and check everything
all: setup build check
	@echo "✓ Full build and validation complete"

# Version information
version:
	@echo "HSU Universal Makefile v1.0.0"
	@echo "Repository Type: $(REPO_TYPE)"
	@echo "Project: $(PROJECT_NAME) v$(PROJECT_VERSION)" 
# HSU Make System - Configuration Options

Complete reference for configuring the HSU Make System.

## 📋 **Configuration Overview**

The HSU system uses a **defaults-first approach** with minimal required configuration. Most settings have intelligent defaults that work for standard project layouts.

### **Configuration Hierarchy**
The system looks for configuration in this order:
1. `HSU_MAKEFILE_CONFIG.mk` (system defaults/template)
2. `Makefile.config` (project-specific settings)
3. `config.mk` (alternative project configuration file)

### **Minimal Required Configuration**
```make
# Makefile.config - Only these are required
PROJECT_NAME := my-hsu-project
PROJECT_DOMAIN := my-domain  
INCLUDE_PREFIX := make/
```

Everything else uses intelligent defaults based on auto-detection.

## 🎯 **Core Configuration**

### **Project Information**
```make
# Project Identity (Required)
PROJECT_NAME := hsu-example-project
PROJECT_DOMAIN := example
PROJECT_VERSION := 1.0.0

# Include Path (Required)
INCLUDE_PREFIX := make/      # Where HSU system files are located
                            # Common values: make/ build/ scripts/ or empty
```

### **Build Configuration**
```make
# Build Settings (Optional - defaults provided)
DEFAULT_PORT := 50055        # Default: 50055
BUILD_CLI := yes            # Default: yes
BUILD_SRV := yes            # Default: yes  
BUILD_LIB := yes            # Default: yes
```

### **Language Support**
```make
# Language Detection (Optional - auto-detected)
ENABLE_GO := yes            # Default: auto-detected from go.mod
ENABLE_PYTHON := yes        # Default: auto-detected from pyproject.toml/requirements.txt
```

## 🐍 **Python Configuration**

### **Basic Python Settings**
```make
# Python Package Configuration
PYTHON_PACKAGE_NAME := $(subst -,_,$(PROJECT_NAME))  # Default: PROJECT_NAME with underscores
PYTHON_BUILD_TOOL := pip    # Options: poetry | pdm | pip | setuptools
PYTHON_VERSION := 3.9       # Default: 3.9
PYTHON_VENV := .venv        # Default: .venv

# Directory Structure (relative to PYTHON_DIR)
PY_CLI_BUILD_DIR := cli     # Default: cli
PY_SRV_BUILD_DIR := srv     # Default: srv
PY_LIB_BUILD_DIR := lib     # Default: lib
```

### **Nuitka Binary Compilation**
```make
# Nuitka Build Configuration
ENABLE_NUITKA := yes                    # Default: auto-detected if nuitka available
NUITKA_OUTPUT_NAME := my-app-server     # Default: $(PROJECT_NAME)-server
NUITKA_ENTRY_POINT := srv/run_server.py # Default: first server script found
NUITKA_EXCLUDES_FILE := nuitka_excludes.txt # Default: nuitka_excludes.txt
NUITKA_BUILD_MODE := onefile            # Options: onefile | standalone

# Advanced Nuitka Configuration
NUITKA_EXTRA_MODULES := srv.domain.simple_handler
NUITKA_EXTRA_PACKAGES := hsu_echo hsu_echo_simple
NUITKA_EXTRA_FOLLOW_IMPORTS := hsu_core
NUITKA_BUILD_FLAGS := --enable-plugin=anti-bloat
```

### **Nuitka Configuration Examples**

#### **Simple Server Application**
```make
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := echo-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_BUILD_MODE := onefile
```

#### **Complex Application with Dependencies**
```make
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := complex-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_EXCLUDES_FILE := nuitka_excludes.txt
NUITKA_EXTRA_MODULES := srv.domain.handler,lib.utils.helper
NUITKA_EXTRA_PACKAGES := my_package,shared_lib
NUITKA_EXTRA_FOLLOW_IMPORTS := hsu_core,external_dep
NUITKA_BUILD_MODE := standalone
NUITKA_BUILD_FLAGS := --enable-plugin=anti-bloat --include-data-dir=assets=assets
```

## 🔧 **Go Configuration**

### **Basic Go Settings**
```make
# Go Module Configuration
GO_MODULE_NAME := github.com/core-tools/$(PROJECT_NAME)  # Default: based on PROJECT_NAME
GO_BUILD_FLAGS := -v -race              # Default: -v
GO_TEST_FLAGS := -v -race -cover        # Default: -v -race
GO_TEST_TIMEOUT := 5m                   # Default: 30s

# Directory Structure (relative to GO_DIR)
CLI_BUILD_DIR := cmd/cli                # Default: cmd/cli
SRV_BUILD_DIR := cmd/srv                # Default: cmd/srv
LIB_BUILD_DIR := pkg                    # Default: pkg
```

### **Domain Import Configuration**
For projects using domain-based import patterns:

```make
# Domain Import Settings
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .

# This automatically configures go.mod:
# replace github.com/core-tools/hsu-example2 => .
```

### **Go Build Examples**

#### **Standard Go Project**
```make
GO_MODULE_NAME := github.com/myorg/my-project
GO_BUILD_FLAGS := -v -race
GO_TEST_FLAGS := -v -race -cover
```

#### **Domain-Based Go Project**
```make
PROJECT_DOMAIN := echo
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)  
DOMAIN_REPLACE_TARGET := .
GO_BUILD_FLAGS := -v -race -ldflags="-s -w"
```

## 🔄 **Auto-Detection Settings**

### **Repository Type Detection**
The system automatically detects your repository structure:

```make
# Auto-detected values (read-only)
REPO_TYPE := single-language-go    # or single-language-python or multi-language
GO_DIR := .                        # or go/ for multi-language repos
PYTHON_DIR := .                    # or python/ for multi-language repos
```

### **Language Detection Logic**
```make
# Go Detection
# - Looks for go.mod in project root or go/ directory
# - Sets ENABLE_GO := yes automatically

# Python Detection  
# - Looks for pyproject.toml, requirements.txt, or setup.py
# - Sets ENABLE_PYTHON := yes automatically

# Nuitka Detection
# - Checks if nuitka is available in PATH
# - Sets ENABLE_NUITKA := yes if Python enabled and nuitka found
```

### **Build Target Detection**
```make
# CLI Target Detection
# - Searches cmd/cli/*/main.go (Go)
# - Searches cli/*.py or */run_client.py (Python)

# Server Target Detection  
# - Searches cmd/srv/*/main.go (Go)
# - Searches srv/*.py or */run_server.py (Python)

# Library Detection
# - Searches pkg/ (Go)
# - Searches lib/ (Python)
```

## 📂 **Directory Structure Configuration**

### **Single-Language Repository Configuration**
```make
# For single-language repos, directories are relative to project root
PROJECT_NAME := hsu-example1-go
INCLUDE_PREFIX := make/

# Auto-detected:
# REPO_TYPE := single-language-go
# GO_DIR := .
# CLI_TARGETS found in: cmd/cli/
# SRV_TARGETS found in: cmd/srv/
```

### **Multi-Language Repository Configuration**
```make
# For multi-language repos, directories are language-specific
PROJECT_NAME := hsu-example2
INCLUDE_PREFIX := make/

# Auto-detected:
# REPO_TYPE := multi-language
# GO_DIR := go
# PYTHON_DIR := python
# CLI_TARGETS found in: go/cmd/cli/ and python/cli/
# SRV_TARGETS found in: go/cmd/srv/ and python/srv/
```

### **Custom Directory Structure**
```make
# Override default directory detection
GO_DIR := golang
PYTHON_DIR := py
CLI_BUILD_DIR := applications/cli
SRV_BUILD_DIR := applications/srv
LIB_BUILD_DIR := shared/lib
```

## ⚡ **Protobuf/gRPC Configuration**

### **Auto-Detection**
```make
# Protobuf generation is auto-enabled when:
# - api/proto/*.proto files are found
# - GO_DIR/api/proto/*.proto files are found  
# - PYTHON_DIR/api/proto/*.proto files are found
```

### **Manual Configuration**
```make
# Manual protobuf configuration (optional)
ENABLE_PROTOBUF := yes
PROTO_SRC_DIR := api/proto
PROTO_GO_OUT := $(GO_DIR)/pkg/generated/api/proto
PROTO_PY_OUT := $(PYTHON_DIR)/lib/generated/api/proto
```

## 🛠️ **Development Tool Configuration**

### **Code Quality Tools**
```make
# Go Tools
GO_LINT_TOOL := golangci-lint       # Default: golangci-lint
GO_FORMAT_TOOL := gofmt             # Default: gofmt

# Python Tools  
PYTHON_LINT_TOOL := ruff            # Default: ruff (fallback: pylint)
PYTHON_FORMAT_TOOL := black         # Default: black
PYTHON_TEST_TOOL := pytest         # Default: pytest
```

### **Build Environment**
```make
# Cross-Platform Settings
SHELL_TYPE := auto                  # Default: auto-detected (powershell/bash/cmd)
EXECUTABLE_SUFFIX := auto          # Default: auto-detected (.exe on Windows)
PATH_SEPARATOR := auto             # Default: auto-detected (/ or \)

# Development Settings
WATCH_TOOL := entr                  # Default: entr
COVERAGE_TOOL := go-cover           # Go coverage tool
```

## 📋 **Configuration Examples**

### **Minimal Configuration (Recommended)**
```make
# Makefile.config - Works for 90% of projects
PROJECT_NAME := my-project
PROJECT_DOMAIN := example
INCLUDE_PREFIX := make/
```

### **Python with Nuitka Configuration**
```make
PROJECT_NAME := hsu-example-server
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# Nuitka Configuration
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := echo-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_BUILD_MODE := onefile
NUITKA_EXCLUDES_FILE := nuitka_excludes.txt
```

### **Multi-Language with Domain Imports**
```make
PROJECT_NAME := hsu-example2
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# Domain Import Configuration
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .

# Build Configuration
DEFAULT_PORT := 50055
GO_BUILD_FLAGS := -v -race
PYTHON_BUILD_TOOL := pip
```

### **Custom Directory Structure**
```make
PROJECT_NAME := custom-layout
PROJECT_DOMAIN := custom
INCLUDE_PREFIX := build/

# Custom Directory Structure
GO_DIR := backend/go
PYTHON_DIR := backend/python
CLI_BUILD_DIR := applications/client
SRV_BUILD_DIR := applications/server
```

## 🔍 **Configuration Validation**

### **Check Configuration**
```bash
# Show all detected/configured values
make info

# Show Go-specific configuration
make go-info

# Show Python-specific configuration  
make py-info
```

### **Common Configuration Issues**

#### **Wrong Include Path**
```bash
# Error: include HSU_MAKEFILE_GO.mk: No such file or directory
# Solution: Check INCLUDE_PREFIX in Makefile.config
INCLUDE_PREFIX := make/    # Ensure this matches where files are copied
```

#### **Language Not Detected**
```bash
# Error: No rule to make target 'go-build'
# Solution: Check auto-detection with make info
# Ensure go.mod exists and ENABLE_GO is set
```

#### **Nuitka Build Issues**
```bash
# Error: ModuleNotFoundError during Nuitka build
# Solution: Check package installation and NUITKA_EXTRA_* settings
NUITKA_EXTRA_PACKAGES := my_package
NUITKA_EXTRA_MODULES := specific.module.path
```

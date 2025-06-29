# HSU Python-Specific Makefile
# Handles Python operations for HSU Repository Portability Framework
# Version: 1.0.0

# Python Configuration (with defaults)
PYTHON_PACKAGE_NAME ?= $(subst -,_,$(PROJECT_NAME))
PYTHON_BUILD_TOOL ?= setuptools  # setuptools | poetry | pdm | pip
PYTHON_VERSION ?= 3.8
PYTHON_VENV ?= .venv

# Build directory configuration (relative to PYTHON_DIR)
PY_CLI_BUILD_DIR ?= cli
PY_SRV_BUILD_DIR ?= srv
PY_LIB_BUILD_DIR ?= lib

# Auto-detect Python executables and packages
PY_CLI_TARGETS := $(shell find $(PYTHON_DIR)/$(PY_CLI_BUILD_DIR) -name "*.py" -path "*/main.py" -o -name "run_*.py" 2>$(NULL_DEV) | head -10)
PY_SRV_TARGETS := $(shell find $(PYTHON_DIR)/$(PY_SRV_BUILD_DIR) -name "*.py" -path "*/main.py" -o -name "run_*.py" -o -name "*server*.py" 2>$(NULL_DEV) | head -10)

# Python command wrapper - runs from correct directory
ifeq ($(PYTHON_DIR),.)
    PY_CMD := 
    PY_MODULE_DIR := .
else
    PY_CMD := cd $(PYTHON_DIR) &&
    PY_MODULE_DIR := $(PYTHON_DIR)
endif

# Auto-detect Python build tool
ifndef PYTHON_BUILD_DETECTED
    ifneq ($(wildcard $(PYTHON_DIR)/uv.lock),)
        PYTHON_BUILD_DETECTED := uv
    else ifneq ($(wildcard $(PYTHON_DIR)/pyproject.toml),)
        # Check if it's Poetry, PDM, or UV
        ifneq ($(shell grep -l "\[tool.poetry\]" $(PYTHON_DIR)/pyproject.toml 2>$(NULL_DEV)),)
            PYTHON_BUILD_DETECTED := poetry
        else ifneq ($(shell grep -l "\[tool.pdm\]" $(PYTHON_DIR)/pyproject.toml 2>$(NULL_DEV)),)
            PYTHON_BUILD_DETECTED := pdm
        else ifneq ($(shell grep -l "\[tool.uv\]" $(PYTHON_DIR)/pyproject.toml 2>$(NULL_DEV)),)
            PYTHON_BUILD_DETECTED := uv
        else
            PYTHON_BUILD_DETECTED := setuptools
        endif
    else ifneq ($(wildcard $(PYTHON_DIR)/requirements.txt),)
        PYTHON_BUILD_DETECTED := pip
    else
        PYTHON_BUILD_DETECTED := pip
    endif
endif

# Set build tool
PYTHON_BUILD_TOOL := $(PYTHON_BUILD_DETECTED)

# Python-specific targets
.PHONY: py-setup py-deps py-build py-test py-lint py-format py-clean py-check py-info py-venv py-install

## Python Setup - Initialize Python development environment
py-setup: py-venv py-deps
	@echo "✓ Python development environment ready"

## Python Virtual Environment - Create/activate virtual environment
py-venv:
	@echo "Setting up Python virtual environment..."
ifeq ($(PYTHON_BUILD_TOOL),uv)
	$(PY_CMD) uv venv || echo "Virtual environment already exists or created by uv"
else ifeq ($(PYTHON_BUILD_TOOL),poetry)
	$(PY_CMD) poetry install --no-root
else ifeq ($(PYTHON_BUILD_TOOL),pdm)
	$(PY_CMD) pdm install
else
	@if [ ! -d "$(PYTHON_DIR)/$(PYTHON_VENV)" ]; then \
		echo "Creating virtual environment..."; \
		$(PY_CMD) python -m venv $(PYTHON_VENV); \
	fi
endif

## Python Dependencies - Install Python dependencies
py-deps:
	@echo "Installing Python dependencies..."
ifeq ($(PYTHON_BUILD_TOOL),uv)
	$(PY_CMD) uv sync
else ifeq ($(PYTHON_BUILD_TOOL),poetry)
	$(PY_CMD) poetry install
else ifeq ($(PYTHON_BUILD_TOOL),pdm)
	$(PY_CMD) pdm install
else ifneq ($(wildcard $(PYTHON_DIR)/requirements.txt),)
	$(PY_CMD) pip install -r requirements.txt
else
	@echo "No requirements.txt found, skipping dependency installation"
endif

## Python Build - Build Python packages
py-build:
	@echo "Building Python packages..."
ifeq ($(PYTHON_BUILD_TOOL),uv)
	$(PY_CMD) uv build
else ifeq ($(PYTHON_BUILD_TOOL),poetry)
	$(PY_CMD) poetry build
else ifeq ($(PYTHON_BUILD_TOOL),pdm)
	$(PY_CMD) pdm build
else ifneq ($(wildcard $(PYTHON_DIR)/setup.py),)
	$(PY_CMD) python setup.py build
else ifneq ($(wildcard $(PYTHON_DIR)/pyproject.toml),)
	$(PY_CMD) pip install build && python -m build
else
	@echo "No Python build configuration found (setup.py or pyproject.toml)"
endif

## Python Test - Run Python tests
py-test:
	@echo "Running Python tests..."
ifeq ($(PYTHON_BUILD_TOOL),uv)
	$(PY_CMD) uv run pytest
else ifeq ($(PYTHON_BUILD_TOOL),poetry)
	$(PY_CMD) poetry run python -m pytest
else ifeq ($(PYTHON_BUILD_TOOL),pdm)
	$(PY_CMD) pdm run python -m pytest
else ifeq ($(shell which pytest 2>$(NULL_DEV)),)
	$(PY_CMD) python -m unittest discover
else
	$(PY_CMD) python -m pytest
endif

## Python Lint - Run Python linting
py-lint:
	@echo "Running Python linting..."
ifeq ($(PYTHON_BUILD_TOOL),uv)
	$(PY_CMD) uv run ruff check . || echo "ruff not available"
	$(PY_CMD) uv run mypy . || echo "mypy not available"
else ifeq ($(PYTHON_BUILD_TOOL),poetry)
	$(PY_CMD) poetry run python -m flake8 . || echo "flake8 not available"
	$(PY_CMD) poetry run python -m mypy . || echo "mypy not available"
else ifeq ($(PYTHON_BUILD_TOOL),pdm)
	$(PY_CMD) pdm run python -m flake8 . || echo "flake8 not available"
	$(PY_CMD) pdm run python -m mypy . || echo "mypy not available"
else
	@echo "Running basic Python syntax check..."
	$(PY_CMD) python -m py_compile **/*.py || echo "Some Python files have syntax errors"
ifeq ($(shell which flake8 2>$(NULL_DEV)),)
	@echo "  Note: flake8 not found, install with: pip install flake8"
else
	$(PY_CMD) flake8 .
endif
ifeq ($(shell which mypy 2>$(NULL_DEV)),)
	@echo "  Note: mypy not found, install with: pip install mypy"
else
	$(PY_CMD) mypy .
endif
endif

## Python Format - Format Python code
py-format:
	@echo "Formatting Python code..."
ifeq ($(PYTHON_BUILD_TOOL),uv)
	$(PY_CMD) uv run black . || echo "black not available"
	$(PY_CMD) uv run isort . || echo "isort not available"
	$(PY_CMD) uv run ruff format . || echo "ruff format not available"
else ifeq ($(PYTHON_BUILD_TOOL),poetry)
	$(PY_CMD) poetry run python -m black . || echo "black not available"
	$(PY_CMD) poetry run python -m isort . || echo "isort not available"
else ifeq ($(PYTHON_BUILD_TOOL),pdm)
	$(PY_CMD) pdm run python -m black . || echo "black not available"
	$(PY_CMD) pdm run python -m isort . || echo "isort not available"
else
ifeq ($(shell which black 2>$(NULL_DEV)),)
	@echo "  Note: black not found, install with: pip install black"
else
	$(PY_CMD) black .
endif
ifeq ($(shell which isort 2>$(NULL_DEV)),)
	@echo "  Note: isort not found, install with: pip install isort"
else
	$(PY_CMD) isort .
endif
endif

## Python Clean - Clean Python artifacts
py-clean:
	@echo "Cleaning Python artifacts..."
	@find $(PYTHON_DIR) -type d -name "__pycache__" -exec $(RM_RF) {} + 2>$(NULL_DEV) || true
	@find $(PYTHON_DIR) -type d -name "*.egg-info" -exec $(RM_RF) {} + 2>$(NULL_DEV) || true
	@find $(PYTHON_DIR) -type d -name ".pytest_cache" -exec $(RM_RF) {} + 2>$(NULL_DEV) || true
	@find $(PYTHON_DIR) -type d -name ".mypy_cache" -exec $(RM_RF) {} + 2>$(NULL_DEV) || true
	@find $(PYTHON_DIR) -name "*.pyc" -delete 2>$(NULL_DEV) || true
	@find $(PYTHON_DIR) -name "*.pyo" -delete 2>$(NULL_DEV) || true
	-$(RM_RF) $(PYTHON_DIR)/build 2>$(NULL_DEV) || true
	-$(RM_RF) $(PYTHON_DIR)/dist 2>$(NULL_DEV) || true
	@echo "✓ Python clean complete"

## Python Check - Run all Python checks (lint + test)
py-check: py-lint py-test

## Python Install - Install package in development mode
py-install:
	@echo "Installing Python package in development mode..."
ifeq ($(PYTHON_BUILD_TOOL),poetry)
	$(PY_CMD) poetry install
else ifeq ($(PYTHON_BUILD_TOOL),pdm)
	$(PY_CMD) pdm install -e .
else ifneq ($(wildcard $(PYTHON_DIR)/setup.py),)
	$(PY_CMD) pip install -e .
else ifneq ($(wildcard $(PYTHON_DIR)/pyproject.toml),)
	$(PY_CMD) pip install -e .
else
	@echo "No Python package configuration found"
endif

## Python Info - Show Python environment information
py-info:
	@echo "=== Python Environment Information ==="
	@echo "Python Directory: $(PYTHON_DIR)"
	@echo "Python Module Directory: $(PY_MODULE_DIR)"
	@echo "Python Package Name: $(PYTHON_PACKAGE_NAME)"
	@echo "Python Build Tool: $(PYTHON_BUILD_TOOL) (detected: $(PYTHON_BUILD_DETECTED))"
	@echo "Python Version: $$($(PY_CMD) python --version 2>$(NULL_DEV) || echo 'Not available')"
	@echo "Python Executable: $$($(PY_CMD) which python 2>$(NULL_DEV) || echo 'Not found')"
ifeq ($(PYTHON_BUILD_TOOL),uv)
	@echo "UV Version: $$($(PY_CMD) uv --version 2>$(NULL_DEV) || echo 'Not available')"
else
	@echo "Pip Version: $$($(PY_CMD) pip --version 2>$(NULL_DEV) || echo 'Not available')"
endif
ifeq ($(ENABLE_NUITKA),yes)
	@echo "Nuitka Version: $$($(PY_CMD) python -m nuitka --version 2>$(NULL_DEV) || echo 'Not available')"
endif
	@echo ""
	@echo "Build Configuration:"
	@echo "Python Package: $(PYTHON_PACKAGE_NAME)"
	@echo "Build Tool: $(PYTHON_BUILD_TOOL)"
	@echo "Virtual Environment: $(PYTHON_VENV)"
ifeq ($(ENABLE_NUITKA),yes)
	@echo "Nuitka Enabled: $(ENABLE_NUITKA)"
	@echo "Nuitka Output: $(NUITKA_OUTPUT_NAME)"
	@echo "Nuitka Source: $(NUITKA_SOURCE_FILE)"
endif
	@echo ""
	@echo "Detected Targets:"
	@echo "CLI Targets: $(PY_CLI_TARGETS)"
	@echo "Server Targets: $(PY_SRV_TARGETS)"

# =============================================================================
# Nuitka Binary Compilation Support
# =============================================================================

ifeq ($(ENABLE_NUITKA),yes)

# Nuitka Configuration
NUITKA_BUILD_DIR := build/$(NUITKA_OUTPUT_NAME)
NUITKA_LOG_FILE := build-$(NUITKA_OUTPUT_NAME).log
NUITKA_EXECUTABLE := $(NUITKA_BUILD_DIR)/$(NUITKA_OUTPUT_NAME)$(EXECUTABLE_EXT)

# Dynamic patch_meta module name based on INCLUDE_PREFIX
ifneq ($(INCLUDE_PREFIX),)
    # Strip trailing slash and create module name (e.g., make/ → make.patch_meta)
    NUITKA_PATCH_META_MODULE := $(patsubst %/,%,$(INCLUDE_PREFIX)).patch_meta
else
    # Root directory case (INCLUDE_PREFIX := ) → patch_meta
    NUITKA_PATCH_META_MODULE := patch_meta
endif

# Read excluded packages from file
ifneq ($(wildcard $(PYTHON_DIR)/$(NUITKA_EXCLUDES_FILE)),)
    NUITKA_EXCLUDE_PACKAGES := $(shell grep -v '^\#' $(PYTHON_DIR)/$(NUITKA_EXCLUDES_FILE) | grep -v '^$$' | tr '\n' ' ')
    NUITKA_NOFOLLOW_OPTS := $(foreach pkg,$(NUITKA_EXCLUDE_PACKAGES),--nofollow-import-to=$(pkg))
else
    NUITKA_EXCLUDE_PACKAGES := 
    NUITKA_NOFOLLOW_OPTS := 
endif

# Core Nuitka options
NUITKA_COMMON_OPTS := \
    --assume-yes-for-downloads \
    --disable-ccache \
    --standalone \
    --show-progress \
    --show-memory \
    --include-package=grpc \
    --include-module=$(NUITKA_PATCH_META_MODULE) \
    --follow-import-to=hsu_core \
    --include-module=jaraco.text \
    --include-package=tqdm \
    --include-package=yaml \
    $(NUITKA_NOFOLLOW_OPTS) \
    --include-module=importlib.metadata \
    --remove-output \
    --follow-imports

# Add project-specific modules
ifneq ($(NUITKA_EXTRA_MODULES),)
    NUITKA_COMMON_OPTS += $(foreach mod,$(NUITKA_EXTRA_MODULES),--include-module=$(mod))
endif

ifneq ($(NUITKA_EXTRA_PACKAGES),)
    NUITKA_COMMON_OPTS += $(foreach pkg,$(NUITKA_EXTRA_PACKAGES),--include-package=$(pkg))
endif

# Build mode options
ifeq ($(NUITKA_BUILD_MODE),onefile)
    NUITKA_COMMON_OPTS += --onefile
else ifeq ($(NUITKA_BUILD_MODE),standalone)
    NUITKA_COMMON_OPTS += --standalone
endif

# Platform-specific options
ifeq ($(DETECTED_OS),Windows-NT)
    NUITKA_OPTS := $(NUITKA_COMMON_OPTS) --mingw64 --output-filename=$(NUITKA_OUTPUT_NAME).exe
else ifeq ($(DETECTED_OS),Windows-MSYS)
    NUITKA_OPTS := $(NUITKA_COMMON_OPTS) --mingw64 --output-filename=$(NUITKA_OUTPUT_NAME).exe
else
    NUITKA_OPTS := $(NUITKA_COMMON_OPTS) --output-filename=$(NUITKA_OUTPUT_NAME)
endif

# Output directory
NUITKA_OPTS += --output-dir=$(NUITKA_BUILD_DIR)

# Nuitka-specific targets
.PHONY: py-nuitka py-nuitka-clean py-nuitka-info py-nuitka-deps

## Python Nuitka - Build Python binary with Nuitka
py-nuitka: py-nuitka-deps
	@echo "Building $(NUITKA_OUTPUT_NAME) with Nuitka..."
	@echo "Detected OS: $(DETECTED_OS)"
	@echo "Source: $(NUITKA_SOURCE_FILE)"
	
	# Clean previous build
	@if [ -d "$(NUITKA_BUILD_DIR)" ]; then \
		echo "Removing previous build directory..."; \
		$(RM_RF) "$(NUITKA_BUILD_DIR)" 2>$(NULL_DEV) || true; \
	fi
	
	# patch_meta.py is now part of the HSU Makefile System package ($(NUITKA_PATCH_META_MODULE))
	
	# Run Nuitka build
	@echo "Running Nuitka compilation..."
	$(PY_CMD) python -m nuitka $(NUITKA_OPTS) $(NUITKA_SOURCE_FILE) > $(NUITKA_LOG_FILE) 2>&1 || \
		(echo "❌ Nuitka build failed! Check $(NUITKA_LOG_FILE) for details." && exit 1)
	
	@echo "Build completed. Check $(NUITKA_LOG_FILE) for details."
	
	# No cleanup needed - patch_meta.py stays in make/ package
	
	# Check if build was successful
	@if [ -f "$(NUITKA_EXECUTABLE)" ]; then \
		echo "✅ Nuitka build successful!"; \
		echo "📦 Executable created: $(NUITKA_EXECUTABLE)"; \
		echo "📏 Size: $$(du -h '$(NUITKA_EXECUTABLE)' | cut -f1)"; \
	else \
		echo "❌ Nuitka build failed! No executable was created."; \
		exit 1; \
	fi

## Python Nuitka Dependencies - Install Nuitka and requirements
py-nuitka-deps:
	@echo "Installing Nuitka dependencies..."
ifeq ($(shell $(PY_CMD) python -c "import nuitka" 2>$(NULL_DEV); echo $$?),0)
	@echo "✅ Nuitka already installed"
else
	@echo "📦 Installing Nuitka..."
	$(PY_CMD) pip install nuitka
endif

## Python Nuitka Clean - Clean Nuitka build artifacts
py-nuitka-clean:
	@echo "Cleaning Nuitka build artifacts..."
	@$(RM_RF) "$(NUITKA_BUILD_DIR)" 2>$(NULL_DEV) || true
	@$(RM_RF) "$(NUITKA_LOG_FILE)" 2>$(NULL_DEV) || true
	@echo "✅ Nuitka clean complete"

## Python Nuitka Info - Show Nuitka configuration
py-nuitka-info:
	@echo "=== Nuitka Build Configuration ==="
	@echo "Enabled: $(ENABLE_NUITKA)"
	@echo "Output Name: $(NUITKA_OUTPUT_NAME)"
	@echo "Source File: $(NUITKA_SOURCE_FILE)"
	@echo "Build Mode: $(NUITKA_BUILD_MODE)"
	@echo "Build Directory: $(NUITKA_BUILD_DIR)"
	@echo "Executable: $(NUITKA_EXECUTABLE)"
	@echo "Log File: $(NUITKA_LOG_FILE)"
	@echo "Excludes File: $(NUITKA_EXCLUDES_FILE)"
	@echo "Excluded Packages: $(NUITKA_EXCLUDE_PACKAGES)"
	@echo "Extra Modules: $(NUITKA_EXTRA_MODULES)"
	@echo "Extra Packages: $(NUITKA_EXTRA_PACKAGES)"
	@echo "Patch Meta Module: $(NUITKA_PATCH_META_MODULE)"
	@echo "Include Prefix: '$(INCLUDE_PREFIX)'"


            

endif  # ENABLE_NUITKA 
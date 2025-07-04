# HSU Make System - Advanced Usage

Advanced topics including migration, extensibility, and custom workflows.

## 🔄 **Migration Guide**

### **From Existing Makefile**

Migrating an existing project to use the HSU Make System:

#### **Step 1: Backup Current Setup**
```bash
# Backup existing build configuration
cp Makefile Makefile.backup
cp -r build/ build.backup/  # If you have a build directory
```

#### **Step 2: Add HSU System via Git Submodule**
```bash
# Add HSU makefile system as submodule
git submodule add https://github.com/Core-Tools/make.git make
git submodule update --init --recursive
```

#### **Step 3: Replace Makefile**
```make
# New Makefile (minimal)
include make/HSU_MAKEFILE_ROOT.mk
```

#### **Step 4: Create Configuration**
```make
# Makefile.config
PROJECT_NAME := my-project
PROJECT_DOMAIN := my-domain
INCLUDE_PREFIX := make/

# Add any custom settings needed
```

#### **Step 5: Test Migration**
```bash
# Verify system loads
make help

# Check auto-detection
make info

# Test basic functionality
make build
```

#### **Step 6: Migrate Custom Targets**
If you have custom build logic, add it to `Makefile.config`:
```make
# Migrate custom targets to Makefile.config
.PHONY: custom-deploy custom-integration-test

custom-deploy: build
	@echo "Deploying $(PROJECT_NAME)..."
	# Your custom deployment logic

custom-integration-test: build
	# Your integration test logic
```

### **From Manual Scripts**

Migrating from shell scripts and manual build processes:

#### **Identify Current Commands**
```bash
# Map existing commands to HSU system
# go build ./cmd/...        → make go-build
# python -m pytest         → make py-test
# ./scripts/lint.sh         → make lint
# ./scripts/format.sh       → make format
# ./scripts/deploy.sh       → Custom target in Makefile.config
```

#### **Create HSU Configuration**
```make
# Makefile.config - map your existing workflow
PROJECT_NAME := my-project
PROJECT_DOMAIN := my-domain
INCLUDE_PREFIX := make/

# Custom targets for existing scripts
.PHONY: deploy integration-test

deploy: build
	@echo "Running deployment..."
	./scripts/deploy.sh

integration-test: build
	@echo "Running integration tests..."
	./scripts/integration-test.sh
```

### **From Other Build Systems**

#### **From Poetry (Python)**
```make
# If migrating from Poetry
PYTHON_BUILD_TOOL := poetry  # Keep using Poetry if desired

# Or migrate to pip-based workflow
PYTHON_BUILD_TOOL := pip
# Then create requirements.txt from pyproject.toml
```

#### **From Docker-based Builds**
```make
# Integration with Docker builds
.PHONY: docker-build docker-run

docker-build: build
	docker build -t $(PROJECT_NAME) .

docker-run: docker-build
	docker run -p $(DEFAULT_PORT):$(DEFAULT_PORT) $(PROJECT_NAME)
```

## 🔧 **Extensibility**

### **Adding New Languages**

To add support for a new language (e.g., Rust):

#### **Step 1: Create Language-Specific File**
```make
# HSU_MAKEFILE_RUST.mk (would be added to canonical repository)
# Rust-specific targets and operations

ifdef ENABLE_RUST

.PHONY: rust-setup rust-build rust-test rust-clean rust-fmt rust-clippy

rust-setup:
	@echo "Setting up Rust environment..."
	rustup update

rust-build:
	@echo "Building Rust components..."
	cargo build --release

rust-test:
	@echo "Running Rust tests..."
	cargo test

rust-clean:
	@echo "Cleaning Rust artifacts..."
	cargo clean

rust-fmt:
	@echo "Formatting Rust code..."
	cargo fmt

rust-clippy:
	@echo "Running Rust linter..."
	cargo clippy

# Add to universal targets
build: rust-build
test: rust-test
clean: rust-clean
format: rust-fmt
lint: rust-clippy

endif
```

#### **Step 2: Add Auto-Detection Logic**
```make
# In HSU_MAKEFILE_ROOT.mk, add Rust detection
ifndef ENABLE_RUST
ifeq ($(shell test -f Cargo.toml && echo yes || echo no),yes)
ENABLE_RUST := yes
RUST_DIR := .
endif
endif

# Include Rust makefile if enabled
ifdef ENABLE_RUST
include $(INCLUDE_PREFIX)HSU_MAKEFILE_RUST.mk
endif
```

#### **Step 3: Add Configuration Options**
```make
# In HSU_MAKE_CONFIG_TMPL.mk, add Rust defaults
# Rust Configuration
RUST_BUILD_FLAGS ?= --release
RUST_TEST_FLAGS ?= --
RUST_TARGET_DIR ?= target
```

### **Custom Target Integration**

#### **Pre/Post Build Hooks**
```make
# In Makefile.config
.PHONY: pre-build post-build

pre-build:
	@echo "Running pre-build steps..."
	# Custom pre-build logic

post-build:
	@echo "Running post-build steps..."
	# Custom post-build logic

# Override default build to add hooks
build: pre-build system-build post-build

system-build:
	@$(MAKE) -f $(INCLUDE_PREFIX)HSU_MAKEFILE_ROOT.mk build
```

#### **Environment-Specific Targets**
```make
# Development vs Production builds
.PHONY: build-dev build-prod

build-dev:
	@echo "Building for development..."
	GO_BUILD_FLAGS="-v -race" $(MAKE) go-build
	PYTHON_BUILD_TOOL="pip" $(MAKE) py-install

build-prod:
	@echo "Building for production..."
	GO_BUILD_FLAGS="-ldflags='-s -w'" $(MAKE) go-build
	$(MAKE) py-nuitka-build
```

### **Plugin System**

Create a plugin system for reusable extensions:

#### **Plugin Structure**
```make
# plugins/docker.mk
ifdef ENABLE_DOCKER

DOCKER_IMAGE_NAME ?= $(PROJECT_NAME)
DOCKER_TAG ?= latest

.PHONY: docker-build docker-run docker-push

docker-build: build
	docker build -t $(DOCKER_IMAGE_NAME):$(DOCKER_TAG) .

docker-run: docker-build
	docker run -p $(DEFAULT_PORT):$(DEFAULT_PORT) $(DOCKER_IMAGE_NAME):$(DOCKER_TAG)

docker-push: docker-build
	docker push $(DOCKER_IMAGE_NAME):$(DOCKER_TAG)

endif
```

#### **Plugin Integration**
```make
# In Makefile.config
ENABLE_DOCKER := yes

# Include plugins
-include plugins/*.mk
```

## 🚀 **Advanced Configuration Patterns**

### **Multi-Environment Configuration**
```make
# Makefile.config with environment support
PROJECT_NAME := my-project
PROJECT_DOMAIN := example
INCLUDE_PREFIX := make/

# Environment-specific settings
ifdef PROD
DEFAULT_PORT := 80
GO_BUILD_FLAGS := -ldflags="-s -w"
ENABLE_NUITKA := yes
NUITKA_BUILD_MODE := onefile
else
# Development defaults
DEFAULT_PORT := 8080
GO_BUILD_FLAGS := -v -race
ENABLE_NUITKA := no
endif
```

Usage:
```bash
# Development build
make build

# Production build
PROD=1 make build
```

### **Conditional Feature Enabling**
```make
# Feature flags in Makefile.config
PROJECT_NAME := my-project
PROJECT_DOMAIN := example
INCLUDE_PREFIX := make/

# Conditional features
ifeq ($(shell which nuitka 2>/dev/null),)
ENABLE_NUITKA := no
else
ENABLE_NUITKA := yes
endif

ifeq ($(shell which docker 2>/dev/null),)
ENABLE_DOCKER := no
else
ENABLE_DOCKER := yes
endif
```

### **Complex Dependency Management**
```make
# Advanced dependency configuration
PROJECT_NAME := complex-project
PROJECT_DOMAIN := example
INCLUDE_PREFIX := make/

# Nuitka with complex dependencies
ENABLE_NUITKA := yes
NUITKA_EXTRA_MODULES := \
	srv.domain.handler \
	srv.utils.logger \
	lib.shared.config

NUITKA_EXTRA_PACKAGES := \
	hsu_core \
	shared_lib \
	business_logic

NUITKA_EXTRA_FOLLOW_IMPORTS := \
	hsu_core.* \
	external_dep.* \
	third_party.*

# Multiple exclusion files
NUITKA_EXCLUDES_FILE := nuitka_excludes.txt
NUITKA_BUILD_FLAGS := \
	--enable-plugin=anti-bloat \
	--include-data-dir=assets=assets \
	--include-data-dir=config=config
```

## 🔍 **Custom Workflow Examples**

### **Microservices Workflow**
```make
# Makefile.config for microservices
PROJECT_NAME := my-microservices
PROJECT_DOMAIN := microservices
INCLUDE_PREFIX := make/

# Custom microservice targets
.PHONY: build-all-services deploy-services test-integration

SERVICES := user-service order-service payment-service

build-all-services:
	@for service in $(SERVICES); do \
		echo "Building $$service..."; \
		$(MAKE) -C services/$$service build; \
	done

deploy-services: build-all-services
	@for service in $(SERVICES); do \
		echo "Deploying $$service..."; \
		$(MAKE) -C services/$$service deploy; \
	done

test-integration: build-all-services
	@echo "Running integration tests..."
	docker-compose up -d
	pytest tests/integration/
	docker-compose down
```

### **Library Development Workflow**
```make
# Makefile.config for library development
PROJECT_NAME := my-library
PROJECT_DOMAIN := lib
INCLUDE_PREFIX := make/

# Library-specific targets
.PHONY: build-docs publish-lib check-api

build-docs: build
	@echo "Building documentation..."
	sphinx-build -b html docs/ docs/_build/

publish-lib: build test
	@echo "Publishing library..."
	python -m build
	python -m twine upload dist/*

check-api: build
	@echo "Checking API compatibility..."
	api-checker --baseline api-baseline.json
```

### **Multi-Language Coordination**
```make
# Advanced multi-language coordination
PROJECT_NAME := full-stack-app
PROJECT_DOMAIN := fullstack
INCLUDE_PREFIX := make/

# Coordinated build process
.PHONY: build-frontend build-backend build-mobile

build-frontend:
	@echo "Building frontend..."
	$(MAKE) -C frontend build

build-backend: go-build py-build
	@echo "Backend built successfully"

build-mobile:
	@echo "Building mobile app..."
	$(MAKE) -C mobile build

# Full application build
build-all: proto build-backend build-frontend build-mobile

# Integration testing
test-integration: build-all
	@echo "Starting integration test environment..."
	docker-compose -f docker-compose.test.yml up -d
	@echo "Running integration tests..."
	pytest tests/integration/
	@echo "Cleaning up test environment..."
	docker-compose -f docker-compose.test.yml down
```

## 🔧 **System File Customization**

### **Local System File Modifications**

If you need project-specific modifications that can't be handled through configuration:

#### **Create Local Override Files**
```make
# project/make/HSU_MAKEFILE_LOCAL.mk
# Project-specific overrides

# Override specific targets
go-build:
	@echo "Custom Go build for $(PROJECT_NAME)..."
	# Custom build logic
	@$(MAKE) -f $(INCLUDE_PREFIX)HSU_MAKEFILE_GO.mk go-build-original

# Add project-specific targets
.PHONY: custom-integration-test
custom-integration-test:
	@echo "Running custom integration tests..."
	# Custom test logic
```

#### **Include Local Overrides**
```make
# At the end of Makefile
include make/HSU_MAKEFILE_ROOT.mk

# Include local overrides if they exist
-include make/HSU_MAKEFILE_LOCAL.mk
```

### **Version-Specific Adaptations**

For projects that need to work with different versions of the HSU system:

```make
# Makefile.config with version checking
HSU_VERSION_REQUIRED := 1.1.0

# Check version compatibility
HSU_VERSION_CHECK := $(shell grep "^# Version:" $(INCLUDE_PREFIX)HSU_MAKEFILE_ROOT.mk | head -1 | awk '{print $$3}')

ifneq ($(HSU_VERSION_CHECK),$(HSU_VERSION_REQUIRED))
$(error HSU version mismatch: required $(HSU_VERSION_REQUIRED), found $(HSU_VERSION_CHECK))
endif
```

## 🎯 **Performance Optimization**

### **Parallel Builds**
```make
# Enable parallel builds
MAKEFLAGS += -j$(shell nproc)

# Parallel language builds
.PHONY: build-parallel
build-parallel:
	@echo "Building in parallel..."
	$(MAKE) go-build &
	$(MAKE) py-build &
	wait
```

### **Incremental Builds**
```make
# Incremental build tracking
.PHONY: build-incremental

BUILD_MARKER := .build-marker

build-incremental: $(BUILD_MARKER)

$(BUILD_MARKER): $(shell find . -name "*.go" -o -name "*.py" | head -20)
	@echo "Source files changed, rebuilding..."
	$(MAKE) build
	@touch $(BUILD_MARKER)
```

### **Caching Strategies**
```make
# Build caching
CACHE_DIR := .cache

.PHONY: build-cached clean-cache

build-cached:
	@mkdir -p $(CACHE_DIR)
	@if [ ! -f $(CACHE_DIR)/deps-installed ]; then \
		echo "Installing dependencies..."; \
		$(MAKE) py-install; \
		touch $(CACHE_DIR)/deps-installed; \
	fi
	$(MAKE) build

clean-cache:
	rm -rf $(CACHE_DIR)

clean: clean-cache
```

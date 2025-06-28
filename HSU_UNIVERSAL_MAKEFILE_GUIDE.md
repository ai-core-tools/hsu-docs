# HSU Universal Makefile System

**Version**: 1.0.0  
**Date**: December 28, 2024  
**Context**: Canonical build system for HSU Repository Portability Framework

## Overview

The **HSU Universal Makefile System** provides a standardized, cross-platform build system that works seamlessly across all 3 approaches in the HSU Repository Portability Framework:

- ✅ **Approach 1**: Single-Repository + Single-Language
- ✅ **Approach 2**: Single-Repository + Multi-Language  
- ✅ **Approach 3**: Multi-Repository Architecture

## Key Features

🎯 **Auto-Detection**: Automatically detects repository structure and enables appropriate languages  
🌐 **Cross-Platform**: Works on Windows, macOS, and Linux with proper shell detection  
🔧 **Modular Design**: Language-specific functionality in separate, includable files  
⚙️ **Configurable**: Project-specific settings via configuration files  
🚀 **Comprehensive**: Covers build, test, lint, format, clean, and development workflows  

## Quick Start

### 1. Install the System

Copy these files to your project root or `/docs/` directory:

```bash
# Core system files
HSU_MAKEFILE_ROOT.mk      # Main coordinator
HSU_MAKEFILE_CONFIG.mk    # Configuration template
HSU_MAKEFILE_GO.mk        # Go-specific operations
HSU_MAKEFILE_PYTHON.mk    # Python-specific operations
```

### 2. Create Your Project Makefile

```make
# Include the HSU Universal Makefile system
include docs/HSU_MAKEFILE_ROOT.mk
# OR include HSU_MAKEFILE_ROOT.mk (if in same directory)
```

### 3. Configure Your Project (Optional)

Create `Makefile.config` in your project root:

```make
# Project Configuration
PROJECT_NAME := my-hsu-project
PROJECT_DOMAIN := my-domain
DEFAULT_PORT := 8080

# Language Support
ENABLE_GO := yes
ENABLE_PYTHON := yes

# Go Configuration
GO_MODULE_NAME := github.com/myorg/$(PROJECT_NAME)
GO_BUILD_FLAGS := -v -race

# Python Configuration
PYTHON_BUILD_TOOL := poetry
```

### 4. Use the System

```bash
# Get help
make help

# Initialize development environment
make setup

# Build everything
make build

# Run tests
make test

# Language-specific commands
make go-build
make py-test
```

## Repository Structure Support

### Approach 1: Single-Language Repository

```
my-hsu-project-go/
├── Makefile                 # include docs/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # Optional project config
├── go.mod                   # ← Auto-detected
├── api/proto/               # API definitions
├── pkg/                     # Shared libraries
├── cmd/
│   ├── cli/echogrpccli/
│   └── srv/echogrpcsrv/
└── docs/
    ├── HSU_MAKEFILE_ROOT.mk    # ← System files
    ├── HSU_MAKEFILE_GO.mk
    └── HSU_MAKEFILE_CONFIG.mk
```

**Auto-Detection**: `REPO_TYPE := single-language-go`, `GO_DIR := .`

### Approach 2: Multi-Language Repository

```
my-hsu-project/
├── Makefile                 # include docs/HSU_MAKEFILE_ROOT.mk  
├── Makefile.config          # Optional project config
├── api/proto/               # Shared API definitions
├── go/                      # ← Auto-detected
│   ├── go.mod
│   ├── pkg/
│   └── cmd/cli/ cmd/srv/
├── python/                  # ← Auto-detected
│   ├── pyproject.toml
│   ├── lib/ srv/ cli/
└── docs/
    ├── HSU_MAKEFILE_ROOT.mk    # ← System files
    ├── HSU_MAKEFILE_GO.mk
    ├── HSU_MAKEFILE_PYTHON.mk
    └── HSU_MAKEFILE_CONFIG.mk
```

**Auto-Detection**: `REPO_TYPE := multi-language`, `GO_DIR := go`, `PYTHON_DIR := python`

### Approach 3: Multi-Repository (Common)

```
my-hsu-project-common/
├── Makefile                 # include docs/HSU_MAKEFILE_ROOT.mk
├── api/proto/               # Shared APIs
├── go/ python/              # Shared libraries only
└── docs/HSU_MAKEFILE_*.mk   # System files
```

### Approach 3: Multi-Repository (Implementation)

```
my-hsu-project-srv-go/
├── Makefile                 # include docs/HSU_MAKEFILE_ROOT.mk
├── go.mod                   # ← Auto-detected
├── srv/                     # Server implementation
└── docs/HSU_MAKEFILE_*.mk   # System files
```

## Configuration Options

### Core Configuration (`Makefile.config`)

```make
# Project Information
PROJECT_NAME := hsu-example-project
PROJECT_DOMAIN := example  
PROJECT_VERSION := 1.0.0

# Build Configuration
DEFAULT_PORT := 50055
BUILD_CLI := yes
BUILD_SRV := yes
BUILD_LIB := yes

# Language Support (auto-detected if not set)
ENABLE_GO := yes
ENABLE_PYTHON := no
```

### Go-Specific Configuration

```make
# Go Configuration
GO_MODULE_NAME := github.com/core-tools/$(PROJECT_NAME)
GO_BUILD_FLAGS := -v -race
GO_TEST_FLAGS := -v -race -cover
GO_TEST_TIMEOUT := 5m

# Domain Import Configuration
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .

# Directory Structure (relative to GO_DIR)
CLI_BUILD_DIR := cmd/cli
SRV_BUILD_DIR := cmd/srv
LIB_BUILD_DIR := pkg
```

### Python-Specific Configuration

```make
# Python Configuration
PYTHON_PACKAGE_NAME := $(subst -,_,$(PROJECT_NAME))
PYTHON_BUILD_TOOL := poetry  # poetry | pdm | pip | setuptools
PYTHON_VERSION := 3.9
PYTHON_VENV := .venv

# Directory Structure (relative to PYTHON_DIR)  
PY_CLI_BUILD_DIR := cli
PY_SRV_BUILD_DIR := srv
PY_LIB_BUILD_DIR := lib
```

## Command Reference

### Universal Commands

| Command | Description | Scope |
|---------|-------------|-------|
| `make help` | Show available targets | All |
| `make info` | Show build environment | All |
| `make setup` | Initialize development environment | All |
| `make build` | Build all enabled languages | All |
| `make test` | Run tests for all languages | All |
| `make lint` | Run linting for all languages | All |
| `make format` | Format code for all languages | All |
| `make clean` | Clean all build artifacts | All |
| `make check` | Run lint + test for all languages | All |
| `make all` | Run setup + build + check | All |

### Go Commands

| Command | Description | Requirements |
|---------|-------------|--------------|
| `make go-setup` | Initialize Go environment | `ENABLE_GO=yes` |
| `make go-build` | Build all Go components | Go code exists |
| `make go-build-cli` | Build CLI executables | `cmd/cli/*/main.go` |
| `make go-build-srv` | Build server executables | `cmd/srv/*/main.go` |
| `make go-test` | Run Go tests | `*_test.go` files |
| `make go-lint` | Run Go linting | Go code exists |
| `make go-format` | Format Go code | Go code exists |
| `make go-clean` | Clean Go artifacts | Go binaries exist |
| `make go-run-cli` | Run first CLI found | Built CLI exists |
| `make go-run-srv` | Run first server found | Built server exists |

### Python Commands

| Command | Description | Requirements |
|---------|-------------|--------------|
| `make py-setup` | Initialize Python environment | `ENABLE_PYTHON=yes` |
| `make py-build` | Build Python packages | Python code exists |
| `make py-test` | Run Python tests | Test files exist |
| `make py-lint` | Run Python linting | Python code exists |
| `make py-format` | Format Python code | Python code exists |
| `make py-clean` | Clean Python artifacts | Python code exists |
| `make py-run-cli` | Run first CLI found | Python CLI exists |
| `make py-run-srv` | Run first server found | Python server exists |

### Development Commands

| Command | Description | Tool Required |
|---------|-------------|---------------|
| `make go-watch` | Watch Go files for changes | `entr` |
| `make py-watch` | Watch Python files for changes | `entr` |
| `make go-cover` | Generate Go coverage report | Go test files |
| `make py-jupyter` | Start Jupyter notebook | `jupyter` |

## Advanced Usage

### Custom Configuration Files

The system looks for configuration in this order:
1. `HSU_MAKEFILE_CONFIG.mk` (template/defaults)
2. `Makefile.config` (project-specific)
3. `config.mk` (alternative name)

### Multi-Repository Coordination

For Approach 3 (multi-repo), you can coordinate builds:

```make
# In parent directory Makefile
.PHONY: build-all
build-all:
	$(MAKE) -C common build
	$(MAKE) -C srv-go build  
	$(MAKE) -C srv-py build
	$(MAKE) -C cli build
```

### Custom Domain Import Handling

For projects using domain-based imports:

```make
# Makefile.config
PROJECT_DOMAIN := echo
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-echo
DOMAIN_REPLACE_TARGET := .

# Automatic go.mod configuration
# replace github.com/core-tools/hsu-echo => .
```

### CI/CD Integration

```yaml
# .github/workflows/build.yml
name: Build
on: [push, pull_request]
jobs:
  build:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - run: make setup
      - run: make check
      - run: make build
```

## Troubleshooting

### Common Issues

**Issue**: `make: *** No rule to make target 'go-build'`  
**Solution**: Ensure `ENABLE_GO=yes` and Go code exists

**Issue**: Build artifacts in wrong directory  
**Solution**: Check auto-detection with `make info`

**Issue**: Cross-platform path issues  
**Solution**: System handles this automatically, but verify with `make info`

### Diagnostics

```bash
# Show complete environment
make info

# Go-specific diagnostics  
make go-info
make go-lint-diag

# Python-specific diagnostics
make py-info
```

### Domain Import Issues

```bash
# Diagnose domain import problems
make go-lint-diag

# Attempt automatic fixes
make go-lint-fix
```

## Migration Guide

### From Existing Makefile

1. **Backup** your current Makefile
2. **Install** HSU system files
3. **Replace** Makefile content with: `include docs/HSU_MAKEFILE_ROOT.mk`
4. **Configure** project-specific settings in `Makefile.config`
5. **Test** with `make info` and `make help`

### From Manual Scripts

1. **Identify** current build/test/lint commands
2. **Map** to HSU system commands:
   - `go build ./cmd/...` → `make go-build`
   - `python -m pytest` → `make py-test`
   - Custom scripts → Custom targets in `Makefile.config`

## Integration Examples

### hsu-example1-go (Approach 1)

```make
# Makefile
include docs/HSU_MAKEFILE_ROOT.mk

# Custom targets
.PHONY: run-integration-test
run-integration-test: build
	./cmd/srv/echogrpcsrv/echogrpcsrv --port 50055 &
	sleep 2
	./cmd/cli/echogrpccli/echogrpccli --port 50055
	pkill echogrpcsrv
```

### hsu-example4 (Approach 2)

```make
# Makefile  
include docs/HSU_MAKEFILE_ROOT.mk

# The system auto-detects multi-language structure
# No additional configuration needed!
```

### hsu-echo-common (Approach 3)

```make
# Makefile
include docs/HSU_MAKEFILE_ROOT.mk

# Custom protobuf generation
.PHONY: proto
proto:
	cd api/proto && ./generate-go.sh && ./generate-py.sh

build: proto go-build py-build
```

## Best Practices

### 1. Configuration Management
- ✅ Use `Makefile.config` for project-specific settings
- ✅ Keep `HSU_MAKEFILE_*.mk` files in `/docs/` directory
- ✅ Version control configuration files
- ❌ Don't modify system files directly

### 2. Directory Structure
- ✅ Follow language conventions (`cmd/`, `pkg/` for Go)
- ✅ Use consistent naming across projects
- ✅ Keep APIs in shared `/api/` directory
- ❌ Don't mix languages in same directory

### 3. Build Automation
- ✅ Always run `make setup` in new environments
- ✅ Use `make check` for comprehensive validation
- ✅ Leverage auto-detection when possible
- ❌ Don't hardcode paths or commands

### 4. Multi-Language Coordination
- ✅ Keep language boundaries clear
- ✅ Share APIs and documentation
- ✅ Use consistent port numbers and conventions
- ❌ Don't tightly couple language implementations

## Extensibility

### Adding New Languages

1. Create `HSU_MAKEFILE_NEWLANG.mk`
2. Add auto-detection logic to `HSU_MAKEFILE_ROOT.mk`
3. Add configuration options to `HSU_MAKEFILE_CONFIG.mk`
4. Follow naming convention: `newlang-*` targets

### Custom Target Integration

```make
# In Makefile.config
.PHONY: deploy
deploy: build
	@echo "Deploying $(PROJECT_NAME)..."
	# Custom deployment logic

# Override default behavior
go-build: custom-pre-build
	@$(MAKE) -f docs/HSU_MAKEFILE_ROOT.mk go-build
	@$(MAKE) custom-post-build
```

## Conclusion

The HSU Universal Makefile System provides a **production-ready, extensible foundation** for building HSU Repository Portability Framework projects. It eliminates the need for custom build scripts while maintaining full compatibility with existing language tooling.

Key benefits:
- 🎯 **Zero configuration** for standard layouts
- 🔧 **Full customization** when needed  
- 🚀 **Cross-platform compatibility**
- 📈 **Consistent developer experience**

This system serves as the **canonical build foundation** for all HSU projects, enabling developers to focus on domain logic rather than build infrastructure. 
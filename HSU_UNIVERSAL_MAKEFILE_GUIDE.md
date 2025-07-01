# HSU Universal Makefile System

**Version**: 1.1.0  
**Date**: December 29, 2024  
**Context**: Canonical build system for HSU Repository Portability Framework

## Overview

The **HSU Universal Makefile System** provides a standardized, cross-platform build system that works seamlessly across all 3 approaches in the HSU Repository Portability Framework:

- ✅ **Approach 1**: Single-Repository + Single-Language
- ✅ **Approach 2**: Single-Repository + Multi-Language  
- ✅ **Approach 3**: Multi-Repository Architecture

## Key Features

🎯 **Auto-Detection**: Automatically detects repository structure and enables appropriate languages  
🌐 **Cross-Platform**: Works on Windows-MSYS, PowerShell, macOS, and Linux with intelligent shell detection  
🔧 **Modular Design**: Language-specific functionality in separate, includable files  
⚙️ **Configuration-Driven**: Include paths and project settings via minimal configuration files  
🔄 **Master → Replica Architecture**: Clean deployment with true file replication from `docs/make/`  
🚀 **Comprehensive**: Covers build, test, lint, format, clean, and development workflows  
🛠️ **Windows-MSYS Compatible**: Handles Windows PowerShell vs MSYS context correctly  
📦 **Compact Master Packaging**: All system files organized in single `docs/make/` folder  
🐍 **Nuitka Binary Compilation**: Full support for Python binary packaging with Nuitka  
⚡ **Protobuf/gRPC Integration**: Built-in support for protocol buffer generation  
🧹 **Flexible Cleanup**: Comprehensive clean targets with language-specific cleanup  
📋 **Minimal Configuration**: Extensive defaults with project-specific overrides only when needed

## Quick Start

### 1. Install the System (Master → Rollout Process)

**Step 1**: Copy master files from `docs/make/` (true replication):

```bash
# Copy all HSU system files from master docs/make/ location
cp docs/make/HSU_MAKEFILE_*.mk project/make/

# Core system files deployed:
# HSU_MAKEFILE_ROOT.mk      - Main coordinator
# HSU_MAKEFILE_CONFIG.mk    - Configuration template with extensive defaults
# HSU_MAKEFILE_GO.mk        - Go-specific operations
# HSU_MAKEFILE_PYTHON.mk    - Python-specific operations (includes Nuitka support)
```

**Step 2**: Configure include path in `Makefile.config`:

```make
# Minimal Project Configuration
PROJECT_NAME := my-hsu-project
PROJECT_DOMAIN := my-domain

# Include Path Configuration
INCLUDE_PREFIX := make/    # Folder where HSU files are located
```

### 2. Create Your Project Makefile

```make
# Include the HSU Universal Makefile system
include make/HSU_MAKEFILE_ROOT.mk
# System will automatically use INCLUDE_PREFIX from config
```

### 3. Configure Your Project (Optional - Extensive Defaults)

Create `Makefile.config` in your project root. Most settings have sensible defaults:

```make
# Project Configuration (required)
PROJECT_NAME := my-hsu-project
PROJECT_DOMAIN := my-domain

# Include Path (required)
INCLUDE_PREFIX := make/

# Everything else is optional with intelligent defaults:
# DEFAULT_PORT := 50055
# ENABLE_GO := auto-detected
# ENABLE_PYTHON := auto-detected
# ENABLE_NUITKA := auto-detected if Python present
```

### 4. Use the System

```bash
# Get help
make help

# Build everything (auto-detects languages)
make build

# Language-specific commands (if detected)
make go-build
make py-install
make py-nuitka-build    # Binary compilation
make py-test
```

## Repository Structure Support

### Approach 1: Single-Language Repository

```
my-hsu-project-go/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # INCLUDE_PREFIX := make/
├── go.mod                   # ← Auto-detected
├── api/proto/               # API definitions
├── pkg/                     # Shared libraries
├── cmd/
│   ├── cli/echogrpccli/
│   └── srv/echogrpcsrv/
└── make/
    ├── HSU_MAKEFILE_ROOT.mk    # ← System files (true replicas)
    ├── HSU_MAKEFILE_GO.mk
    ├── HSU_MAKEFILE_PYTHON.mk
    └── HSU_MAKEFILE_CONFIG.mk
```

**Auto-Detection**: `REPO_TYPE := single-language-go`, `GO_DIR := .`

### Approach 2: Multi-Language Repository

```
my-hsu-project/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk  
├── Makefile.config          # INCLUDE_PREFIX := make/
├── api/proto/               # Shared API definitions
├── go/                      # ← Auto-detected
│   ├── go.mod
│   ├── pkg/
│   └── cmd/cli/ cmd/srv/
├── python/                  # ← Auto-detected
│   ├── pyproject.toml
│   ├── lib/ srv/ cli/
└── make/
    ├── HSU_MAKEFILE_ROOT.mk    # ← System files (true replicas)
    ├── HSU_MAKEFILE_GO.mk
    ├── HSU_MAKEFILE_PYTHON.mk
    └── HSU_MAKEFILE_CONFIG.mk
```

**Auto-Detection**: `REPO_TYPE := multi-language`, `GO_DIR := go`, `PYTHON_DIR := python`

### Approach 3: Multi-Repository (Common)

```
my-hsu-project-common/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # INCLUDE_PREFIX := make/
├── api/proto/               # Shared APIs
├── go/ python/              # Shared libraries only
└── make/HSU_MAKEFILE_*.mk   # System files (true replicas)
```

### Approach 3: Multi-Repository (Implementation)

```
my-hsu-project-srv-go/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # INCLUDE_PREFIX := make/
├── go.mod                   # ← Auto-detected
├── srv/                     # Server implementation
└── make/HSU_MAKEFILE_*.mk   # System files (true replicas)
```

## Configuration Options

### Core Configuration (`Makefile.config`)

```make
# Project Information
PROJECT_NAME := hsu-example-project
PROJECT_DOMAIN := example  
PROJECT_VERSION := 1.0.0

# Include Path Configuration (NEW!)
INCLUDE_PREFIX := make/      # Where HSU system files are located
                            # Common: make/ build/ scripts/ or empty

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

**Issue**: "No CLI targets found" on Windows  
**Solution**: Fixed in v1.0+ with cross-platform auto-detection. System automatically detects Windows-MSYS and uses `bash -c` for find commands.

**Issue**: Cross-platform path issues  
**Solution**: System handles this automatically, but verify with `make info`

**Issue**: `include HSU_MAKEFILE_GO.mk: No such file or directory`  
**Solution**: Configure `INCLUDE_PREFIX` in `Makefile.config` to point to your HSU files location

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

## Master → Rollout Architecture

The HSU Universal Makefile System uses a **Master → Replica deployment model** for maximum maintainability and consistency.

### Architecture Overview

```
📁 /master/location/ (SOURCE OF TRUTH)
├── HSU_MAKEFILE_ROOT.mk      # Generic includes: $(INCLUDE_PREFIX)HSU_MAKEFILE_GO.mk
├── HSU_MAKEFILE_CONFIG.mk    # Template with INCLUDE_PREFIX := 
├── HSU_MAKEFILE_GO.mk        # Language-specific logic
└── HSU_MAKEFILE_PYTHON.mk    # Language-specific logic

                    ⬇️ TRUE REPLICATION ⬇️

📁 project/make/ (ROLLOUT REPLICAS)
├── HSU_MAKEFILE_ROOT.mk      # Identical to master
├── HSU_MAKEFILE_CONFIG.mk    # Identical to master  
├── HSU_MAKEFILE_GO.mk        # Identical to master
└── HSU_MAKEFILE_PYTHON.mk    # Identical to master

📁 project/ (PROJECT CUSTOMIZATION)
├── Makefile                  # include make/HSU_MAKEFILE_ROOT.mk
└── Makefile.config           # INCLUDE_PREFIX := make/
```

### Rollout Process

1. **Deploy Master Files** (true replication - no modifications):
   ```bash
   cp /master/HSU_MAKEFILE_*.mk project/make/
   ```

2. **Configure Include Path** in `project/Makefile.config`:
   ```make
   INCLUDE_PREFIX := make/   # Point to rollout location
   ```

3. **Test Deployment**:
   ```bash
   make help    # Verify system loads
   make info    # Verify configuration
   ```

### Benefits

- ✅ **Master files remain pure** and reusable across all projects
- ✅ **No file modifications** during rollout (true replicas)
- ✅ **All customization** through configuration files
- ✅ **Easy updates** - just replace replica files from master
- ✅ **Flexible folder structure** - use any `INCLUDE_PREFIX`

## Migration Guide

### From Existing Makefile

1. **Backup** your current Makefile
2. **Deploy** HSU system files: `cp /master/HSU_MAKEFILE_*.mk project/make/`
3. **Replace** Makefile content with: `include make/HSU_MAKEFILE_ROOT.mk`
4. **Configure** `INCLUDE_PREFIX := make/` in `Makefile.config`
5. **Configure** project-specific settings in `Makefile.config`
6. **Test** with `make info` and `make help`

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
include make/HSU_MAKEFILE_ROOT.mk

# Custom targets
.PHONY: run-integration-test
run-integration-test: build
	./cmd/srv/echogrpcsrv/echogrpcsrv --port 50055 &
	sleep 2
	./cmd/cli/echogrpccli/echogrpccli --port 50055
	pkill echogrpcsrv
```

```make
# Makefile.config
PROJECT_NAME := hsu-example1-go
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/
```

### hsu-example2 (Approach 2)

```make
# Makefile  
include make/HSU_MAKEFILE_ROOT.mk

# The system auto-detects multi-language structure
# No additional configuration needed!
```

```make
# Makefile.config
PROJECT_NAME := hsu-example2
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/
```

### hsu-echo-common (Approach 3)

```make
# Makefile
include make/HSU_MAKEFILE_ROOT.mk

# Custom protobuf generation
.PHONY: proto
proto:
	cd api/proto && ./generate-go.sh && ./generate-py.sh

build: proto go-build py-build
```

```make
# Makefile.config
PROJECT_NAME := hsu-echo-common
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/
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

### 5. Cross-Platform Development
- ✅ System automatically detects Windows-MSYS vs PowerShell context
- ✅ Use `make info` to verify environment detection
- ✅ Configure `INCLUDE_PREFIX` for flexible folder structures
- ❌ Don't hardcode shell-specific commands in custom targets

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
- 🔧 **Configuration-driven customization** via `INCLUDE_PREFIX` and `Makefile.config`
- 🚀 **True cross-platform compatibility** (Windows-MSYS, macOS, Linux)
- 🔄 **Master → Replica architecture** for clean deployments
- 📈 **Consistent developer experience** across all 3 HSU approaches
- 🛠️ **Intelligent auto-detection** of repository structure and build targets

**Recent Improvements (v1.0+)**:
- ✅ **Cross-platform auto-detection** fixes for Windows-MSYS environments
- ✅ **Configuration-driven include paths** with `INCLUDE_PREFIX`
- ✅ **True replica deployment** without file modifications
- ✅ **Enhanced CLI/SRV target detection** using conditional shell commands

This system serves as the **canonical build foundation** for all HSU projects, enabling developers to focus on domain logic rather than build infrastructure. 
# HSU Universal Makefile System - Quick Start

Get up and running with the HSU Universal Makefile System in minutes.

## 🚀 **Prerequisites**

### **Required Tools**
- `make` - Build automation tool
- `git` - Version control system

### **Language-Specific Tools** (if applicable)
- **Go Projects**: `go` toolchain (1.19+)
- **Python Projects**: `python` (3.8+), `pip`

### **Optional Tools**
- **Nuitka**: For Python binary compilation (`pip install nuitka`)
- **protoc**: For protocol buffer generation

## 📦 **Step 1: Deploy the System**

Copy the HSU system files from the master location to your project:

```bash
# Copy all HSU system files from docs/make/
cp docs/make/HSU_MAKEFILE_*.mk project/make/

# Files deployed:
# HSU_MAKEFILE_ROOT.mk      - Main coordinator
# HSU_MAKEFILE_CONFIG.mk    - Template with extensive defaults
# HSU_MAKEFILE_GO.mk        - Go-specific operations
# HSU_MAKEFILE_PYTHON.mk    - Python-specific operations + Nuitka support
```

## ⚙️ **Step 2: Create Project Makefile**

Create a minimal `Makefile` in your project root:

```make
# Makefile
include make/HSU_MAKEFILE_ROOT.mk
```

That's it! The system will automatically use the configuration from `Makefile.config`.

## 🔧 **Step 3: Configure Your Project**

Create `Makefile.config` in your project root with minimal settings:

```make
# Makefile.config - Minimal configuration
PROJECT_NAME := my-hsu-project
PROJECT_DOMAIN := my-domain
INCLUDE_PREFIX := make/

# Everything else is auto-detected with intelligent defaults!
```

### **Optional: Language-Specific Configuration**

If you need to override defaults, add language-specific settings:

```make
# Go Configuration (optional)
GO_MODULE_NAME := github.com/myorg/$(PROJECT_NAME)
GO_BUILD_FLAGS := -v -race

# Python Configuration (optional)
PYTHON_PACKAGE_NAME := $(subst -,_,$(PROJECT_NAME))
ENABLE_NUITKA := yes
```

## 🎯 **Step 4: Test the System**

Verify everything is working:

```bash
# Check system status
make help

# Show auto-detected configuration
make info

# Build everything (auto-detects your languages)
make build
```

## 📋 **Common Commands**

Once deployed, these commands work across all project types:

### **Universal Commands**
```bash
make help        # Show available targets
make info        # Show build environment
make build       # Build all enabled languages
make test        # Run tests for all languages
make clean       # Clean all build artifacts
make check       # Run lint + test
```

### **Language-Specific Commands** (if auto-detected)
```bash
# Go Commands
make go-build        # Build Go components
make go-test         # Run Go tests
make go-run-srv      # Run first server found

# Python Commands  
make py-install      # Install Python dependencies
make py-test         # Run Python tests
make py-nuitka-build # Build binary executable (if ENABLE_NUITKA=yes)
make py-run-srv      # Run first server found
```

## 🏗️ **Repository Structure Examples**

The system auto-detects your repository structure:

### **Single-Language Go Repository**
```
my-hsu-project-go/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # PROJECT_NAME, INCLUDE_PREFIX, etc.
├── go.mod                   # ← Auto-detected: Go project
├── cmd/
│   ├── cli/mycli/main.go   # ← Auto-detected: CLI targets
│   └── srv/mysrv/main.go   # ← Auto-detected: Server targets
├── pkg/                     # ← Auto-detected: Library components
└── make/
    └── HSU_MAKEFILE_*.mk   # ← System files (replicas)
```

**Auto-Detection Result**: `REPO_TYPE=single-language-go`, `GO_DIR=.`

### **Single-Language Python Repository**
```
my-hsu-project-py/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # PROJECT_NAME, INCLUDE_PREFIX, ENABLE_NUITKA, etc.
├── pyproject.toml           # ← Auto-detected: Python project
├── requirements.txt         # ← Auto-detected: Dependencies
├── srv/run_server.py        # ← Auto-detected: Server targets
├── cli/run_client.py        # ← Auto-detected: CLI targets
├── lib/                     # ← Auto-detected: Library components
└── make/
    └── HSU_MAKEFILE_*.mk   # ← System files (replicas)
```

**Auto-Detection Result**: `REPO_TYPE=single-language-python`, `PYTHON_DIR=.`

### **Multi-Language Repository**
```
my-hsu-project/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # PROJECT_NAME, INCLUDE_PREFIX, etc.
├── api/proto/               # ← Auto-detected: Protobuf generation
├── go/                      # ← Auto-detected: Go components
│   ├── go.mod
│   └── cmd/srv/main.go
├── python/                  # ← Auto-detected: Python components
│   ├── pyproject.toml
│   └── srv/run_server.py
└── make/
    └── HSU_MAKEFILE_*.mk   # ← System files (replicas)
```

**Auto-Detection Result**: `REPO_TYPE=multi-language`, `GO_DIR=go`, `PYTHON_DIR=python`

## 🐍 **Python with Nuitka Binary Compilation**

For Python projects that need standalone executables:

```make
# Makefile.config - Add Nuitka configuration
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := my-app-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_BUILD_MODE := onefile
```

Then build:
```bash
make py-install      # Install dependencies (non-editable for Nuitka)
make py-nuitka-build # Create standalone executable
```

## ⚡ **Protobuf/gRPC Integration**

If your project has `.proto` files in `api/proto/`, the system automatically enables protobuf generation:

```bash
make proto          # Generate protobuf stubs for all languages
make go-proto       # Generate Go stubs only
make py-proto       # Generate Python stubs only
```

## 🔍 **Verification**

Confirm everything is working:

```bash
# Show detected configuration
make info

# Example output:
# REPO_TYPE: single-language-go
# GO_DIR: .
# ENABLE_GO: yes
# ENABLE_PYTHON: no
# CLI_TARGETS: cmd/cli/mycli
# SRV_TARGETS: cmd/srv/mysrv
```

## 🚨 **Common Issues**

### **"No rule to make target 'go-build'"**
- **Cause**: Go not auto-detected or disabled
- **Solution**: Check `make info` output, ensure `go.mod` exists

### **"include HSU_MAKEFILE_*.mk: No such file or directory"**
- **Cause**: System files not deployed or wrong `INCLUDE_PREFIX`
- **Solution**: Verify files copied to correct location, check `INCLUDE_PREFIX` in `Makefile.config`

### **Windows: "No CLI targets found"**
- **Cause**: Windows-MSYS path detection issues
- **Solution**: Fixed in v1.1.0 - update system files from `docs/make/`

## 📚 **Next Steps**

- **Understand the Architecture**: [Master Rollout Architecture](master-rollout.md)
- **Advanced Configuration**: [Configuration Options](configuration.md)
- **Complete Command List**: [Command Reference](commands.md)
- **Real-World Examples**: [Integration Examples](examples.md)
- **Best Practices**: [Best Practices](best-practices.md)

---

**Back to**: [Documentation Index](index.md) | **Up Next**: [Master Rollout Architecture](master-rollout.md) 
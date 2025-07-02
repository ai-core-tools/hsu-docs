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

## 📦 **Step 1: Add the HSU Makefile System**

Add the HSU Universal Makefile System to your project as a git submodule:

```bash
# Navigate to your project root
cd your-project/

# Add the HSU makefile system as a submodule
git submodule add https://github.com/Core-Tools/make.git make

# Initialize and update the submodule
git submodule update --init --recursive

# Files available in make/:
# HSU_MAKEFILE_ROOT.mk      - Main coordinator
# HSU_MAKE_CONFIG_TMPL.mk   - Configuration template with extensive defaults
# HSU_MAKEFILE_GO.mk        - Go-specific operations
# HSU_MAKEFILE_PYTHON.mk    - Python-specific operations + Nuitka support
```

**Alternative (Direct Download)**:
```bash
# For projects that cannot use git submodules
mkdir make
curl -L https://github.com/Core-Tools/make/archive/main.zip -o make.zip
unzip make.zip -d make --strip-components=1
rm make.zip
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
GENERATED_PREFIX := generated/

# Everything else is auto-detected with intelligent defaults!
# See make/HSU_MAKE_CONFIG_TMPL.mk for all available options
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
└── make/ (git submodule)    # ← HSU makefile system submodule
    ├── HSU_MAKEFILE_ROOT.mk
    ├── HSU_MAKE_CONFIG_TMPL.mk
    ├── HSU_MAKEFILE_GO.mk
    └── HSU_MAKEFILE_PYTHON.mk
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
└── make/ (git submodule)    # ← HSU makefile system submodule
    ├── HSU_MAKEFILE_ROOT.mk
    ├── HSU_MAKE_CONFIG_TMPL.mk
    ├── HSU_MAKEFILE_GO.mk
    └── HSU_MAKEFILE_PYTHON.mk
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
└── make/ (git submodule)    # ← HSU makefile system submodule
    ├── HSU_MAKEFILE_ROOT.mk
    ├── HSU_MAKE_CONFIG_TMPL.mk
    ├── HSU_MAKEFILE_GO.mk
    └── HSU_MAKEFILE_PYTHON.mk
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

## 🔄 **Updating the System**

Keep your HSU makefile system up to date:

```bash
# Update to latest version
git submodule update --remote

# Commit the update
git add make
git commit -m "Update HSU makefile system to latest version"

# Alternative: Update and reset to specific version
cd make
git checkout v1.2.0  # or specific commit/tag
cd ..
git add make
git commit -m "Update HSU makefile system to v1.2.0"
```

## 🚨 **Common Issues**

### **"No rule to make target 'go-build'"**
- **Cause**: Go not auto-detected or disabled
- **Solution**: Check `make info` output, ensure `go.mod` exists

### **"include HSU_MAKEFILE_*.mk: No such file or directory"**
- **Cause**: Git submodule not initialized or wrong `INCLUDE_PREFIX`
- **Solution**: Run `git submodule update --init --recursive`, check `INCLUDE_PREFIX` in `Makefile.config`

### **"fatal: not a git repository" during submodule add**
- **Cause**: Project is not a git repository
- **Solution**: Run `git init` first, or use the direct download alternative

## 📚 **Next Steps**

- **Understand the Architecture**: [Master Rollout Architecture](master-rollout.md)
- **Advanced Configuration**: [Configuration Options](configuration.md)
- **Complete Command List**: [Command Reference](commands.md)
- **Real-World Examples**: [Integration Examples](examples.md)
- **Best Practices**: [Best Practices](best-practices.md)

---

**Back to**: [Documentation Index](index.md) | **Up Next**: [Master Rollout Architecture](master-rollout.md) 
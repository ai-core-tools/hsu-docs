# HSU Make System - Command Reference

Complete reference for all available commands and targets in the HSU Make System.

## 🎯 **Universal Commands**

These commands work across all project types and languages:

| Command | Description | Requirements |
|---------|-------------|--------------|
| `make help` | Show available targets and help | None |
| `make info` | Show build environment and configuration | None |
| `make setup` | Initialize development environment | Language tools installed |
| `make build` | Build all enabled languages | Source code exists |
| `make test` | Run tests for all enabled languages | Test files exist |
| `make lint` | Run linting for all enabled languages | Source code exists |
| `make format` | Format code for all enabled languages | Source code exists |
| `make clean` | Clean all build artifacts | Build artifacts exist |
| `make check` | Run lint + test for all languages | Source code exists |
| `make all` | Run setup + build + check | Source code exists |

## 🐹 **Go Commands**

Available when Go is detected or `ENABLE_GO=yes`:

### **Core Go Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make go-setup` | Initialize Go environment | Go toolchain installed |
| `make go-build` | Build all Go components | Go source code |
| `make go-build-cli` | Build CLI executables only | `cmd/cli/*/main.go` files |
| `make go-build-srv` | Build server executables only | `cmd/srv/*/main.go` files |
| `make go-test` | Run Go tests | `*_test.go` files |
| `make go-lint` | Run Go linting | Go source code |
| `make go-format` | Format Go code | Go source code |
| `make go-clean` | Clean Go build artifacts | Go binaries exist |

### **Go Execution Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make go-run-cli` | Run first CLI executable found | Built CLI exists |
| `make go-run-srv` | Run first server executable found | Built server exists |

### **Go Development Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make go-watch` | Watch Go files for changes | `entr` tool installed |
| `make go-cover` | Generate Go test coverage report | Go test files exist |
| `make go-info` | Show Go-specific configuration | Go enabled |
| `make go-lint-diag` | Diagnose Go linting issues | Go source code |
| `make go-lint-fix` | Attempt to fix Go linting issues | Go source code |

### **Go Protobuf Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make go-proto` | Generate Go protobuf stubs | `.proto` files, `protoc`, `protoc-gen-go` |

## 🐍 **Python Commands**

Available when Python is detected or `ENABLE_PYTHON=yes`:

### **Core Python Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make py-setup` | Initialize Python environment | Python toolchain installed |
| `make py-install` | Install Python dependencies | `requirements.txt` or `pyproject.toml` |
| `make py-build` | Build Python packages | Python source code |
| `make py-test` | Run Python tests | Test files exist |
| `make py-lint` | Run Python linting | Python source code |
| `make py-format` | Format Python code | Python source code |
| `make py-clean` | Clean Python build artifacts | Python artifacts exist |

### **Python Execution Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make py-run-cli` | Run first CLI script found | Python CLI exists |
| `make py-run-srv` | Run first server script found | Python server exists |

### **Python Development Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make py-watch` | Watch Python files for changes | `entr` tool installed |
| `make py-jupyter` | Start Jupyter notebook | `jupyter` installed |
| `make py-info` | Show Python-specific configuration | Python enabled |

### **Nuitka Binary Compilation Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make py-nuitka-build` | Build binary executable with Nuitka | `ENABLE_NUITKA=yes`, `nuitka` installed |
| `make py-nuitka-clean` | Clean Nuitka build artifacts | Nuitka builds exist |

### **Python Protobuf Commands**
| Command | Description | Requirements |
|---------|-------------|--------------|
| `make py-proto` | Generate Python protobuf stubs | `.proto` files, `grpcio-tools` |

## ⚡ **Protobuf/gRPC Commands**

Available when `.proto` files are detected in `api/proto/`:

| Command | Description | Requirements |
|---------|-------------|--------------|
| `make proto` | Generate protobuf stubs for all enabled languages | `.proto` files |
| `make go-proto` | Generate Go protobuf stubs only | Go enabled, `protoc`, `protoc-gen-go` |
| `make py-proto` | Generate Python protobuf stubs only | Python enabled, `grpcio-tools` |

## 🔍 **Information Commands**

### **System Information**
| Command | Description | Output |
|---------|-------------|--------|
| `make info` | Complete build environment information | All configuration variables |
| `make go-info` | Go-specific configuration | Go settings and detection results |
| `make py-info` | Python-specific configuration | Python settings and detection results |

### **Example `make info` Output**
```bash
$ make info
HSU Make System v1.1.0
=====================================
REPO_TYPE: single-language-go
PROJECT_NAME: hsu-example1-go
PROJECT_DOMAIN: echo
GO_DIR: .
PYTHON_DIR: (not detected)
ENABLE_GO: yes
ENABLE_PYTHON: no
ENABLE_NUITKA: no
CLI_TARGETS: cmd/cli/echogrpccli
SRV_TARGETS: cmd/srv/echogrpcsrv
INCLUDE_PREFIX: make/
```

## 🧪 **Testing Commands**

### **Language-Specific Testing**
```bash
# Run Go tests with coverage
make go-test

# Run Python tests
make py-test  

# Run all tests
make test
```

### **Test Configuration**
```make
# Customize test behavior in Makefile.config
GO_TEST_FLAGS := -v -race -cover
GO_TEST_TIMEOUT := 5m
PYTHON_TEST_TOOL := pytest
```

## 🎨 **Code Quality Commands**

### **Linting**
```bash
# Lint all enabled languages
make lint

# Language-specific linting
make go-lint
make py-lint

# Diagnose and fix Go linting issues
make go-lint-diag
make go-lint-fix
```

### **Code Formatting**
```bash
# Format all enabled languages
make format

# Language-specific formatting
make go-format
make py-format
```

## 🧹 **Cleanup Commands**

### **Universal Cleanup**
```bash
# Clean all build artifacts
make clean
```

### **Language-Specific Cleanup**
```bash
# Clean Go artifacts
make go-clean

# Clean Python artifacts  
make py-clean

# Clean Nuitka build artifacts
make py-nuitka-clean
```

### **What Gets Cleaned**

#### **Go Clean (`make go-clean`)**
- Compiled binaries in `cmd/cli/*/`
- Compiled binaries in `cmd/srv/*/`
- Test coverage files (`coverage.out`)
- Module cache (if configured)

#### **Python Clean (`make py-clean`)**
- `.pyc` files and `__pycache__` directories
- `*.egg-info` directories  
- `build/` and `dist/` directories
- Virtual environment (if configured)

#### **Nuitka Clean (`make py-nuitka-clean`)**
- Nuitka build directories
- Generated wrapper scripts
- Standalone executables
- Nuitka cache files

## 🔄 **Development Workflow Commands**

### **Complete Development Cycle**
```bash
# Initial setup
make setup

# Development cycle
make check      # lint + test
make build      # compile/package
make test       # run tests

# Production preparation
make clean      # clean artifacts
make all        # setup + build + check
```

### **Watch Mode (Continuous Development)**
```bash
# Watch Go files for changes
make go-watch

# Watch Python files for changes  
make py-watch
```

## 🚀 **Production Commands**

### **Binary Compilation**
```bash
# Create Python standalone executable
make py-nuitka-build

# The resulting binary will be created as:
# ${NUITKA_OUTPUT_NAME}[.exe]  (e.g., echo-server.exe on Windows)
```

### **Package Building**
```bash
# Build all components
make build

# Language-specific builds
make go-build
make py-build
```

## 🔧 **Advanced Commands**

### **Target Discovery**
The system automatically discovers build targets based on file patterns:

#### **Go Target Discovery**
- **CLI Targets**: Files matching `cmd/cli/*/main.go`
- **Server Targets**: Files matching `cmd/srv/*/main.go`
- **Library Packages**: Directories in `pkg/`

#### **Python Target Discovery**
- **CLI Targets**: Files matching `cli/*.py` or `*/run_client.py`
- **Server Targets**: Files matching `srv/*.py` or `*/run_server.py`
- **Library Packages**: Directories in `lib/`

### **Custom Target Integration**
Add custom targets to `Makefile.config`:

```make
# Custom deployment target
.PHONY: deploy
deploy: build
	@echo "Deploying $(PROJECT_NAME)..."
	# Custom deployment logic

# Override default behavior
go-build: custom-pre-build
	@$(MAKE) -f $(INCLUDE_PREFIX)HSU_MAKEFILE_ROOT.mk go-build
	@$(MAKE) custom-post-build
```

## ⚙️ **Configuration-Dependent Commands**

Some commands are only available based on configuration:

### **Nuitka Commands** (require `ENABLE_NUITKA=yes`)
- `make py-nuitka-build`
- `make py-nuitka-clean`

### **Protobuf Commands** (require `.proto` files)
- `make proto`
- `make go-proto`  
- `make py-proto`

### **Domain Import Commands** (require `DOMAIN_IMPORT_PREFIX`)
- `make go-lint-fix` (with domain import resolution)

## 🛠️ **Debugging Commands**

### **Troubleshooting**
```bash
# Show all configuration
make info

# Diagnose Go issues
make go-info
make go-lint-diag

# Show available targets
make help

# Verbose build output
GO_BUILD_FLAGS=-v make go-build
```

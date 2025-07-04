# HSU Make System Integration

This document explains how the [HSU Make System](../system/make/index.md) automatically adapts to all three repository approaches, providing consistent build automation.

## Automatic Approach Detection

The HSU make system **automatically detects** your repository approach and provides appropriate commands:

```makefile
# Auto-detection logic (simplified)
if [ -d "go" ] && [ -d "python" ]; then
    APPROACH="multi-language"           # Approach 2
elif [ -f "go.mod" ] && [ ! -d "go" ]; then
    APPROACH="single-language-go"       # Approach 1
elif [ -f "pyproject.toml" ] && [ ! -d "python" ]; then
    APPROACH="single-language-python"   # Approach 1
else
    APPROACH="multi-repository"         # Approach 3
fi
```

## Approach 1: Single-Language Integration

### Go Project Example (hsu-example1-go)

**Configuration (`Makefile.config`):**
```makefile
PROJECT_NAME = hsu-example1-go
PROJECT_TYPE = single-language-go
HSU_APPROACH = 1
GO_MODULE_NAME = github.com/core-tools/hsu-example1-go
```

**Available Commands:**
```bash
make build              # Build all Go components
make run-srv            # Run gRPC server
make test               # Run Go tests
make proto-gen          # Generate gRPC code
make clean              # Clean build artifacts
```

### Python Project Example (hsu-example1-py)

**Configuration (`Makefile.config`):**
```makefile
PROJECT_NAME = hsu-example1-py
PROJECT_TYPE = single-language-python
HSU_APPROACH = 1
PYTHON_PACKAGE_NAME = hsu_echo
NUITKA_ENABLED = true
```

**Available Commands:**
```bash
make build              # Install Python package
make run-srv            # Run Python server
make py-nuitka-build    # Compile to binary
make test               # Run Python tests
make proto-gen          # Generate gRPC code
```

## Approach 2: Multi-Language Integration

### Coordinated Build Example (hsu-example2)

**Configuration (`Makefile.config`):**
```makefile
PROJECT_NAME = hsu-example2
PROJECT_TYPE = multi-language
HSU_APPROACH = 2
GO_MODULE_PATH = go
PYTHON_PACKAGE_PATH = python
```

**Available Commands:**
```bash
# Cross-language commands
make build              # Build all languages
make test               # Test all languages
make proto-gen          # Generate code for all languages

# Language-specific commands
make go-build           # Build Go only
make py-build           # Build Python only
make go-run-srv         # Run Go server
make py-run-srv         # Run Python server
```

## Approach 3: Multi-Repository Integration

### Common Repository Example (hsu-example3-common)

**Configuration (`Makefile.config`):**
```makefile
PROJECT_NAME = hsu-example3-common
PROJECT_TYPE = common-multi-language
HSU_APPROACH = 3
PROVIDES_SHARED_API = true
```

**Available Commands:**
```bash
make build              # Build shared libraries
make proto-gen          # Generate language bindings
make run-go-cli         # Run Go test client
make run-py-cli         # Run Python test client
make tag-release        # Tag version for release
```

### Implementation Repository Examples

**Go Server (hsu-example3-srv-go):**
```makefile
PROJECT_NAME = hsu-example3-srv-go
PROJECT_TYPE = implementation-go
HSU_APPROACH = 3
COMMON_DEPENDENCY = github.com/core-tools/hsu-example3-common
```

**Python Server (hsu-example3-srv-py):**
```makefile
PROJECT_NAME = hsu-example3-srv-py
PROJECT_TYPE = implementation-python
HSU_APPROACH = 3
COMMON_DEPENDENCY = hsu-example3-common
```

**Available Commands (both):**
```bash
make build              # Build this implementation
make run-srv            # Run this server
make update-deps        # Update common dependencies
make test               # Test this implementation
```

## Command Adaptation Examples

### Build Commands

```bash
# Approach 1: Direct build
make build → go build ./cmd/srv/

# Approach 2: Multi-language build
make build → make go-build && make py-build

# Approach 3: Dependency-aware build
make build → go get -u common-repo && go build ./cmd/srv/
```

### Development Commands

```bash
# Approach 1: Simple development
make dev → go run ./cmd/srv/

# Approach 2: Language selection
make go-dev → cd go && go run ./cmd/srv/
make py-dev → cd python && python -m srv.run_server

# Approach 3: Local dependency mode
make dev-local → go mod edit -replace common=../common
```

## Cross-Platform Support

All approaches support **Windows, macOS, and Linux** through automatic platform detection:

```makefile
# Windows adaptation
ifeq ($(OS),Windows_NT)
    EXECUTABLE_EXT = .exe
    PROTO_GEN_SCRIPT = generate-go.bat
else
    EXECUTABLE_EXT = 
    PROTO_GEN_SCRIPT = generate-go.sh
endif
```

## Template System Integration

**Automatic file generation** based on approach:

```bash
# Generated files adapt to approach
make generate-wrappers

# Approach 1: Direct wrappers
# srv/run_server_wrapper.py

# Approach 2: Language-specific wrappers  
# python/srv/run_server_wrapper.py

# Approach 3: Implementation-specific wrappers
# srv/run_server_wrapper.py (depends on common repo)
```

## Configuration Reference

### Required Settings

**All Approaches:**
```makefile
PROJECT_NAME = your-project-name
PROJECT_TYPE = single-language-go|single-language-python|multi-language|implementation-*|common-*
HSU_APPROACH = 1|2|3
```

**Approach-Specific:**
```makefile
# Approach 1 Go
GO_MODULE_NAME = github.com/org/your-project

# Approach 1 Python  
PYTHON_PACKAGE_NAME = your_package

# Approach 2
GO_MODULE_PATH = go
PYTHON_PACKAGE_PATH = python

# Approach 3
COMMON_DEPENDENCY = github.com/org/your-common-repo
```

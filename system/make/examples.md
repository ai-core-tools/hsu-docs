# HSU Make System - Integration Examples

Real-world usage patterns and integration examples from tested HSU repositories.

## 🎯 **Overview**

These examples are based on actual working repositories that have been battle-tested across all 3 HSU repository approaches. Each example demonstrates different aspects of the HSU Make System.

## 📋 **Example Repository Summary**

| Repository | Repository Approach | Languages | Key Features |
|------------|----------|-----------|--------------|
| [hsu-example1-go](#hsu-example1-go) | 1: Single-Repo + Single-Language | Go | Standard Go project, domain imports |
| [hsu-example1-py](#hsu-example1-py) | 1: Single-Repo + Single-Language | Python | Nuitka binary compilation |
| [hsu-example2](#hsu-example2) | 2: Single-Repo + Multi-Language | Go + Python | Coordinated multi-language builds |
| [hsu-example3-common](#hsu-example3-common) | 3: Multi-Repo + Shared | Go + Python | Shared libraries and APIs |
| [hsu-example3-srv-go](#hsu-example3-srv-go) | 3: Multi-Repo + Implementation | Go | Focused Go server implementation |
| [hsu-example3-srv-py](#hsu-example3-srv-py) | 3: Multi-Repo + Implementation | Python | Python server with Nuitka |

## 🐹 **hsu-example1-go**
*Repository Approach 1: Single-Repository + Single-Language (Go)*

### **Repository Structure**
```
hsu-example1-go/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # Minimal configuration
├── go.mod                   # ← Auto-detected: Go project
├── api/proto/               # Protocol buffer definitions
├── cmd/
│   ├── cli/echogrpccli/    # ← Auto-detected: CLI target
│   └── srv/echogrpcsrv/    # ← Auto-detected: Server target
├── pkg/                     # Shared library code
└── make/                    # System files (replicas)
    └── HSU_MAKEFILE_*.mk
```

### **Configuration** (`Makefile.config`)
```make
# HSU Example1 Go - HSU Universal Makefile System
# HSU Repository Portability Framework - Approach 1 (Single-Repository + Single-Language)

PROJECT_NAME := hsu-example1-go
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# Domain Import Configuration (enables repo-portable import patterns)
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .
```

### **Makefile Integration**
```make
# Makefile
include make/HSU_MAKEFILE_ROOT.mk

# Legacy target aliases for backward compatibility
.PHONY: build-all build-cli build-srv lint-diag lint-fix

build-all: build
build-cli: go-build-cli
build-srv: go-build-srv
lint-diag: go-lint-diag
lint-fix: go-lint-fix
```

### **Usage Examples**
```bash
# Build everything
make build

# Run server and client
make go-build-srv && make go-run-srv &
make go-build-cli && make go-run-cli

# Development workflow
make go-watch   # Watch for changes
make go-test    # Run tests
make go-lint    # Check code quality
```

## 🐍 **hsu-example1-py**
*Repository Approach 1: Single-Repository + Single-Language (Python with Nuitka)*

### **Repository Structure**
```
hsu-example1-py/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # Configuration with Nuitka settings
├── pyproject.toml           # ← Auto-detected: Python project
├── requirements.txt         # Dependencies
├── nuitka_excludes.txt      # Nuitka exclusion configuration
├── srv/                     # ← Auto-detected: Server targets
│   ├── run_server.py
│   └── domain/
├── cli/                     # ← Auto-detected: CLI targets
│   └── run_client.py
├── lib/                     # Shared library code
└── make/                    # System files (replicas)
    └── HSU_MAKEFILE_*.mk
```

### **Configuration** (`Makefile.config`)
```make
# HSU Example1 Py - HSU Universal Makefile System
# HSU Repository Portability Framework - Approach 1 (Single-Repository + Single-Language)

PROJECT_NAME := hsu-example1-py
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# Domain Import Configuration
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .

# Nuitka Build Configuration
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := hsu-example-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_EXCLUDES_FILE := nuitka_excludes.txt
NUITKA_EXTRA_MODULES := srv.domain.simple_handler
NUITKA_EXTRA_PACKAGES := hsu_echo hsu_echo_simple
NUITKA_EXTRA_FOLLOW_IMPORTS := hsu_core
NUITKA_BUILD_MODE := onefile
```

### **Makefile Integration**
```make
# Makefile
include make/HSU_MAKEFILE_ROOT.mk

# Legacy target alias for backward compatibility
.PHONY: build-all

build-all: build
```

### **Usage Examples**
```bash
# Install dependencies
make py-install

# Development workflow
make py-test
make py-lint
make py-format

# Binary compilation
make py-nuitka-build    # Creates hsu-example-server.exe

# Run the binary
./hsu-example-server.exe   # Windows
./hsu-example-server       # Linux/macOS
```

### **Nuitka Configuration Details**
The `nuitka_excludes.txt` file excludes heavy dependencies:
```
tensorflow
torch
scipy
sklearn
pandas
numpy
matplotlib
```

## 🔄 **hsu-example2**
*Repository Approach 2: Single-Repository + Multi-Language (Go + Python)*

### **Repository Structure**
```
hsu-example2/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # Multi-language configuration
├── api/proto/               # ← Auto-detected: Shared protobuf APIs
├── go/                      # ← Auto-detected: Go components
│   ├── go.mod
│   ├── cmd/cli/ cmd/srv/
│   └── pkg/
├── python/                  # ← Auto-detected: Python components
│   ├── pyproject.toml
│   ├── srv/ cli/ lib/
│   └── requirements.txt
└── make/                    # System files (replicas)
    └── HSU_MAKEFILE_*.mk
```

### **Configuration** (`Makefile.config`)
```make
# HSU Example2 - HSU Universal Makefile System
# HSU Repository Portability Framework - Approach 2 (Single-Repository + Multi-Language)

PROJECT_NAME := hsu-example2
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# Domain Import Configuration (applies to both languages)
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .

# Nuitka Build Configuration for Python component
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := hsu-example-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_EXCLUDES_FILE := nuitka_excludes.txt
NUITKA_EXTRA_MODULES := srv.domain.simple_handler
NUITKA_EXTRA_PACKAGES := hsu_echo hsu_echo_simple
NUITKA_EXTRA_FOLLOW_IMPORTS := hsu_core
NUITKA_BUILD_MODE := onefile
```

### **Usage Examples**
```bash
# Build all languages
make build              # Builds both Go and Python

# Language-specific builds
make go-build          # Build Go components only
make py-install        # Install Python dependencies
make py-build          # Build Python packages

# Protobuf generation
make proto             # Generate stubs for both languages
make go-proto          # Generate Go stubs only
make py-proto          # Generate Python stubs only

# Multi-language testing
make test              # Run tests for both languages
make go-test           # Run Go tests only
make py-test           # Run Python tests only

# Binary compilation
make py-nuitka-build   # Create Python binary

# Coordinated development
make check             # Lint and test both languages
make clean             # Clean all artifacts
```

### **Auto-Detection Results**
```bash
$ make info
REPO_TYPE: multi-language
GO_DIR: go
PYTHON_DIR: python
ENABLE_GO: yes
ENABLE_PYTHON: yes
ENABLE_PROTOBUF: yes (api/proto/ detected)
```

## 🔗 **hsu-example3-common**
*Repository Approach 3: Multi-Repository + Multi-Language (Shared Components)*

### **Repository Structure**
```
hsu-example3-common/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # Shared component configuration
├── api/proto/               # ← Shared API definitions
├── go/                      # ← Shared Go libraries
│   ├── go.mod
│   ├── pkg/
│   └── cmd/cli/            # Client-only (no servers)
├── python/                  # ← Shared Python libraries
│   ├── pyproject.toml
│   ├── lib/
│   └── cli/                # Client-only (no servers)
└── make/                    # System files (replicas)
    └── HSU_MAKEFILE_*.mk
```

### **Configuration** (`Makefile.config`)
```make
# HSU Example3 Common - HSU Universal Makefile System
# HSU Repository Portability Framework - Approach 3 (Multi-Repository + Multi-Language)

PROJECT_NAME := hsu-example3-common
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# Domain Import Configuration
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .
```

### **Usage Examples**
```bash
# Build shared libraries
make build             # Build Go and Python libraries

# Generate shared APIs
make proto             # Generate protobuf stubs for both languages

# Test shared components
make test              # Run tests for shared libraries

# Client applications only (no servers in common repo)
make go-run-cli        # Run Go client
make py-run-cli        # Run Python client
```

## 🚀 **hsu-example3-srv-go** & **hsu-example3-srv-py**
*Repository Approach 3: Multi-Repository + Single-Language (Implementation)*

### **Go Server Repository** (`hsu-example3-srv-go`)
```
hsu-example3-srv-go/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # Go server configuration
├── go.mod                   # ← Auto-detected: Go project
├── cmd/srv/                 # ← Server implementation only
│   └── echogrpcsrv/
└── make/                    # System files (replicas)
    └── HSU_MAKEFILE_*.mk
```

### **Python Server Repository** (`hsu-example3-srv-py`)
```
hsu-example3-srv-py/
├── Makefile                 # include make/HSU_MAKEFILE_ROOT.mk
├── Makefile.config          # Python server configuration with Nuitka
├── pyproject.toml           # ← Auto-detected: Python project
├── requirements.txt
├── nuitka_excludes.txt
├── srv/                     # ← Server implementation only
│   ├── run_server.py
│   └── domain/
└── make/                    # System files (replicas)
    └── HSU_MAKEFILE_*.mk
```

### **Configuration Examples**
```make
# hsu-example3-srv-go/Makefile.config
PROJECT_NAME := hsu-example3-srv-go
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# hsu-example3-srv-py/Makefile.config  
PROJECT_NAME := hsu-example3-srv-py
PROJECT_DOMAIN := echo
INCLUDE_PREFIX := make/

# Nuitka Configuration for Python server
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := hsu-example-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_BUILD_MODE := onefile
```

## 🔄 **Multi-Repository Coordination**

For Repository Approach 3, you can coordinate builds across repositories:

### **Parent Directory Coordination**
```make
# In parent directory Makefile (optional)
.PHONY: build-all test-all clean-all

build-all:
	$(MAKE) -C hsu-example3-common build
	$(MAKE) -C hsu-example3-srv-go build
	$(MAKE) -C hsu-example3-srv-py build

test-all:
	$(MAKE) -C hsu-example3-common test
	$(MAKE) -C hsu-example3-srv-go test
	$(MAKE) -C hsu-example3-srv-py test

clean-all:
	$(MAKE) -C hsu-example3-common clean
	$(MAKE) -C hsu-example3-srv-go clean
	$(MAKE) -C hsu-example3-srv-py clean
```

## 🎯 **Common Integration Patterns**

### **1. Legacy Target Compatibility**
Maintain backward compatibility with existing scripts:
```make
# In Makefile
.PHONY: build-all build-cli build-srv

build-all: build
build-cli: go-build-cli  
build-srv: go-build-srv
```

### **2. Custom Development Workflows**
```make
# In Makefile.config
.PHONY: dev-setup integration-test deploy

dev-setup: setup
	# Additional development setup

integration-test: build
	./cmd/srv/echogrpcsrv/echogrpcsrv --port 50055 &
	sleep 2
	./cmd/cli/echogrpccli/echogrpccli --port 50055
	pkill echogrpcsrv

deploy: build test
	@echo "Deploying $(PROJECT_NAME) to production..."
	# Custom deployment logic
```

### **3. CI/CD Integration**
```yaml
# .github/workflows/build.yml
name: Build and Test
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v4
        with:
          go-version: '1.21'
      - name: Setup HSU Build System
        run: make setup
      - name: Run Tests
        run: make check
      - name: Build
        run: make build
```

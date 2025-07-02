# Single-Repository Multi-Language HSU Implementation Guide

This guide walks you through creating a single-repository HSU implementation that supports both Go and Python in one unified codebase. This approach is perfect for teams that need both languages but want coordinated development.

## Overview

**Repository Approach 2** combines multiple languages in a single repository:
- **Single repository** with Go and Python implementations
- **Shared protocol definitions** and API contracts
- **Coordinated builds** with unified makefile commands
- **Cross-language testing** and deployment

This approach is ideal for:
- Full-stack teams needing both Go and Python
- Services requiring multi-language client libraries
- Coordinated API evolution across languages
- Unified deployment and version management

## Prerequisites

- Go 1.22+
- Python 3.8+
- Protocol Buffers compiler (`protoc`)
- GNU Make or compatible
- Basic understanding of gRPC

## 🎯 Quick Start: Copy Working Example

The fastest way to get started is to copy the proven working example:

```bash
# Copy the working multi-language example (without make system)
cp -r hsu-example2/ my-multi-service/
cd my-multi-service/
rm -rf make/  # Remove make directory (will be added as submodule)

# Add HSU makefile system as git submodule
git init
git submodule add https://github.com/core-tools/make.git make

# Test that everything works immediately
make setup && make build && make test

# Start both servers
make go-run-server    # Terminal 1: Go server
make py-run-server    # Terminal 2: Python server
make run-client       # Terminal 3: Test both
```

**Expected output:**
```
✓ Go server: go-echo: Hello World!
✓ Python server: py-echo: Hello World!
✓ Both servers working simultaneously!
```

## 📁 Actual Directory Structure

The working `hsu-example2` uses this proven structure:

```
my-multi-service/                    # Root directory
├── Makefile                         # Universal makefile entry point
├── Makefile.config                  # Project configuration
├── make/                            # HSU Universal Makefile System (git submodule)
│   ├── HSU_MAKEFILE_ROOT.mk         # Main makefile system
│   ├── HSU_MAKEFILE_GO.mk           # Go-specific targets
│   ├── HSU_MAKEFILE_PYTHON.mk       # Python-specific targets
│   ├── HSU_MAKE_CONFIG_TMPL.mk      # Configuration template
│   └── README.md                    # Makefile system documentation
├── api/
│   └── proto/
│       ├── echoservice.proto        # Shared gRPC service definition
│       ├── generate-go.bat          # Windows Go code generation
│       ├── generate-go.sh           # Unix Go code generation
│       ├── generate-py.bat          # Windows Python code generation
│       └── generate-py.sh           # Unix Python code generation
├── go/
│   ├── go.mod                       # Go module
│   ├── pkg/
│   │   ├── control/
│   │   │   ├── gateway.go           # Go client gateway
│   │   │   ├── handler.go           # Go gRPC ↔ domain adapter
│   │   │   └── main_echo.go         # Go server setup helper
│   │   ├── domain/
│   │   │   └── contract.go          # Go domain interface
│   │   ├── generated/
│   │   │   └── api/proto/           # Generated Go gRPC code
│   │   └── logging/
│   │       └── logging.go           # Go logging interface
│   └── cmd/
│       ├── cli/echogrpccli/
│       │   └── main.go              # Go test client
│       └── srv/echogrpcsrv/
│           └── main.go              # Go server entry point
├── python/
│   ├── pyproject.toml               # Python project configuration
│   ├── lib/
│   │   ├── control/
│   │   │   ├── gateway.py           # Python client gateway
│   │   │   ├── handler.py           # Python gRPC ↔ domain adapter
│   │   │   └── serve_echo.py        # Python server setup helper
│   │   ├── domain/
│   │   │   └── contract.py          # Python domain interface
│   │   └── generated/
│   │       └── api/proto/           # Generated Python gRPC code
│   ├── cli/
│   │   └── run_client.py            # Python test client
│   └── srv/
│       └── run_server.py            # Python server entry point
├── requirements.txt
└── README.md
```

## 🛠️ Real Makefile Commands

The working example provides these **universal commands**:

### Core Development Commands
```bash
make setup          # Install Go modules + Python packages
make build          # Build both Go and Python components
make test           # Run tests for both languages
make clean          # Clean all build artifacts
make proto          # Generate gRPC code for both languages
```

### Language-Specific Commands
```bash
# Go commands
make go-build       # Build Go components only
make go-test        # Run Go tests
make go-protoc      # Generate Go gRPC code

# Python commands
make py-build       # Build Python components only
make py-test        # Run Python tests
make py-protoc      # Generate Python gRPC code
make py-nuitka      # Build optimized Python binary
```

### Runtime Commands
```bash
make go-run-server  # Start Go server
make py-run-server  # Start Python server
make run-client     # Test both servers
```

## ⚙️ Configuration System

The working example uses `Makefile.config` for project settings:

```makefile
# Project Information
PROJECT_NAME := my-multi-service
PROJECT_DOMAIN := echo
PROJECT_VERSION := 1.0.0

# Repository Structure
GO_DIR := go
PYTHON_DIR := python
ENABLE_GO := yes
ENABLE_PYTHON := yes

# Go Configuration
GO_MODULE_NAME := github.com/myorg/my-multi-service
GO_BUILD_FLAGS := -v

# Build Targets
DEFAULT_PORT := 50055
BUILD_CLI := yes
BUILD_SRV := yes
BUILD_LIB := yes

# Nuitka Configuration (Python binary compilation)
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := my-service-server
NUITKA_ENTRY_POINT := srv/run_server.py
```

## 🔄 Step-by-Step Customization

### Step 1: Initial Setup

```bash
# Copy and rename the working example
cp -r hsu-example2/ my-multi-service/
cd my-multi-service/
rm -rf make/  # Remove make directory (will be added as submodule)

# Initialize git and add HSU makefile system
git init
git submodule add https://github.com/core-tools/make.git make

# Verify everything works out of the box
make setup && make build && make test
echo "✓ Base system working!"
```

### Step 2: Configure Your Project

Edit `Makefile.config`:
```makefile
# Update project identification
PROJECT_NAME := my-multi-service
PROJECT_DOMAIN := myservice
GO_MODULE_NAME := github.com/myorg/my-multi-service
```

Update `go/go.mod`:
```go
module github.com/myorg/my-multi-service

go 1.22
// ... rest stays the same
```

Update `python/pyproject.toml`:
```toml
[project]
name = "my-multi-service"
// ... rest stays the same
```

### Step 3: Customize Protocol Definition

Edit `api/proto/myservice.proto`:
```protobuf
syntax = "proto3";

package myservice;
option go_package = "github.com/myorg/my-multi-service/pkg/generated/api/proto";

service MyService {
    rpc ProcessData(DataRequest) returns (DataResponse) {}
}

message DataRequest {
    string input = 1;
    int32 count = 2;
}

message DataResponse {
    string result = 1;
    bool success = 2;
}
```

### Step 4: Regenerate Code

```bash
make proto          # Regenerates gRPC code for both languages
make build          # Verify compilation
```

### Step 5: Implement Business Logic

**Go Implementation** (`go/pkg/domain/contract.go`):
```go
package domain

import "context"

type Contract interface {
    ProcessData(ctx context.Context, input string, count int32) (string, bool, error)
}
```

**Python Implementation** (`python/lib/domain/contract.py`):
```python
from abc import ABC, abstractmethod

class Contract(ABC):
    @abstractmethod
    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        pass
```

### Step 6: Test Your Changes

```bash
make build && make test
make go-run-server   # Terminal 1
make py-run-server   # Terminal 2
make run-client      # Terminal 3: Test both
```

## 🏗️ Key Architecture Patterns

### Shared Protocol Definition
- Single `.proto` file defines the API contract
- Generated code for both languages automatically
- API evolution coordinated across languages

### Language-Specific Directories
- `go/` contains all Go code with standard structure
- `python/` contains all Python code with standard structure
- Each language follows its own conventions

### Universal Build System
- Same makefile commands work for both languages
- Cross-language build coordination
- Consistent development experience

### Independent Language Implementation
- Go and Python implementations can differ internally
- Both implement the same gRPC contract
- Language-specific optimizations possible

## 🚀 Production Deployment

### Build Production Artifacts

```bash
# Build optimized Go binary
make go-build

# Build optimized Python binary (with Nuitka)
make py-nuitka

# Results:
# - go/bin/myservice-server (Go executable)
# - python/build/my-service-server (Python executable)
```

### Docker Deployment

The makefile system supports Docker builds:
```bash
make docker-go      # Build Go container
make docker-py      # Build Python container
```

### Language-Specific Deployment

Deploy one or both implementations based on needs:
- **Go**: Better performance, smaller memory footprint
- **Python**: Richer ecosystem, easier ML integration
- **Both**: A/B testing, gradual migration, redundancy

## 🔍 Development Workflow

### Daily Development Cycle
```bash
make clean                   # Start fresh
make setup                   # Update dependencies
make proto                   # Regenerate any protocol changes
make build && make test      # Build and verify both languages
```

### Language-Specific Development
```bash
# Go-focused development
make go-build && make go-test && make go-run-server

# Python-focused development
make py-build && make py-test && make py-run-server
```

### Cross-Language Testing
```bash
make build                   # Build both
make go-run-server &         # Start Go server
make py-run-server &         # Start Python server
make run-client              # Test against both
```

## 🏆 Advantages of This Approach

### ✅ **Coordinated Development**
- Single repository for version control
- Shared protocol definitions
- Unified build and test process

### ✅ **Language Choice Flexibility**
- Deploy Go for performance-critical services
- Deploy Python for ML/data processing services
- Switch between implementations transparently

### ✅ **Team Efficiency**
- Go and Python developers work in same codebase
- Cross-language code reviews
- Shared understanding of business logic

### ✅ **Future-Proof Architecture**
- Can evolve to multi-repository when needed
- Migration path to Approach 3 exists
- Supports team growth and scaling

## 🔄 Migration Paths

### From Single-Language (Approach 1)
```bash
# Merge existing single-language repos
mkdir my-multi-service/
cp -r my-go-service/* my-multi-service/go/
cp -r my-py-service/* my-multi-service/python/
cd my-multi-service/

# Setup git and makefile system for new multi-language project
git init
git submodule add https://github.com/core-tools/make.git make

# Configure Makefile.config for multi-language
edit Makefile.config  # Set ENABLE_GO=yes, ENABLE_PYTHON=yes
```

### To Multi-Repository (Approach 3)
```bash
# Extract shared components when teams grow
mkdir my-service-common/
mv api/ my-service-common/
# Create separate implementation repositories
```

## 📚 Next Steps

### Advanced Topics
- **[Multi-Language Best Practices](../guides/MULTI_LANGUAGE.md)** - Cross-language coordination
- **[Protocol Buffer Evolution](../guides/HSU_PROTOCOL_BUFFERS.md)** - API versioning strategies
- **[Multi-Repository Migration](../repositories/migration-patterns.md)** - Scaling to Approach 3

### Production Considerations
- **[Testing and Deployment](../guides/HSU_TESTING_DEPLOYMENT.md)** - Production deployment
- **[Configuration Management](../deployment/configuration.md)** - Environment management
- **[Performance Optimization](../guides/HSU_BEST_PRACTICES.md)** - Language-specific tuning

### Related Approaches
- **[Single-Repository Go](INTEGRATED_HSU_SINGLE_REPO_GO_GUIDE.md)** - Go-only implementation
- **[Single-Repository Python](INTEGRATED_HSU_SINGLE_REPO_PYTHON_GUIDE.md)** - Python-only implementation
- **[Multi-Repository Go](INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md)** - Independent Go services
- **[Multi-Repository Python](INTEGRATED_HSU_MULTI_REPO_PYTHON_GUIDE.md)** - Independent Python services

---

**🎉 You now have a production-ready multi-language HSU service!**

*This approach provides the best of both worlds: coordinated development with language flexibility, backed by the HSU Platform's universal build system.* 
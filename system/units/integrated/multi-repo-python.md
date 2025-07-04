# Multi-Repository HSU Python Implementation Guide

This guide shows you how to create a Python-based HSU server using the **"copy working example"** approach for multi-repository architecture. You'll start with working systems and customize them for your needs.

## Overview

**Repository Approach 3 (Python)** provides independent Python microservices:
- **Separate repositories** for shared components and implementations  
- **Independent deployment cycles** for each service
- **Shared protocol definitions** via common repository
- **Universal makefile commands** across all repositories
- **Team independence** with controlled dependencies

This approach is perfect for:
- Large teams requiring independence
- Multiple Python service implementations
- ML/data processing microservices  
- Independent deployment cycles
- Language-specific optimizations per service

## Prerequisites

- Python 3.8+
- Protocol Buffers compiler (`protoc`)
- GNU Make or compatible
- Git (for repository management)
- Basic understanding of gRPC and microservices

## Quick Start: Copy Working Examples

The fastest way to get started is to copy the proven working examples:

```bash
# Copy the working common repository (without make system)
cp -r hsu-example3-common/ my-service-common/
cd my-service-common/
rm -rf make/  # Remove make directory (will be added as submodule)

# Add HSU makefile system as git submodule
git init
git submodule add https://github.com/core-tools/make.git make

# Test common repository works
make setup && make build && make test

# Copy the working Python service implementation (without make system)
cd ..
cp -r hsu-example3-srv-py/ my-service-py/
cd my-service-py/
rm -rf make/  # Remove make directory (will be added as submodule)

# Add HSU makefile system as git submodule
git init
git submodule add https://github.com/core-tools/make.git make

# Test Python service works
make setup && make build && make test
make run-server
```

**Expected output:**
```
✓ Common repository: Protocol generation and client working
✓ Python service: Server running on port 50055
✓ Integration: Client can connect to server
```

## Actual Directory Structure

The working examples use this proven multi-repository structure:

### Common Repository (`my-service-common/`)
```
my-service-common/                   # Shared components repository
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
│       ├── generate-go.sh           # Go code generation
│       └── generate-py.sh           # Python code generation
├── go/
│   ├── go.mod                       # Go module for common components
│   ├── pkg/
│   │   ├── control/
│   │   │   ├── gateway.go           # Client gateway
│   │   │   ├── handler.go           # gRPC ↔ domain adapter
│   │   │   └── main_echo.go         # Server setup helper
│   │   ├── domain/
│   │   │   └── contract.go          # Domain interface
│   │   ├── generated/
│   │   │   └── api/proto/           # Generated gRPC code
│   │   └── logging/
│   │       └── logging.go           # Logging interface
│   └── cmd/
│       └── cli/echogrpccli/
│           └── main.go              # Shared test client
├── python/                          # Python bindings (optional)
└── README.md
```

### Python Service Repository (`my-service-py/`)
```
my-service-py/                       # Python service implementation
├── Makefile                         # Universal makefile entry point
├── Makefile.config                  # Service-specific configuration
├── make/                            # HSU Universal Makefile System (git submodule)
│   ├── HSU_MAKEFILE_ROOT.mk         # Main makefile system
│   ├── HSU_MAKEFILE_GO.mk           # Go-specific targets
│   ├── HSU_MAKEFILE_PYTHON.mk       # Python-specific targets
│   ├── HSU_MAKE_CONFIG_TMPL.mk      # Configuration template
│   └── README.md                    # Makefile system documentation
├── srv/
│   ├── domain/
│   │   └── simple_handler.py        # Service-specific business logic
│   └── run_server.py                # Service entry point
├── pyproject.toml                   # Python project configuration
├── requirements.txt
└── README.md
```

## Real Makefile Commands

Both repositories provide these **universal commands**:

### Common Repository Commands
```bash
make setup          # Install Python dependencies for common components
make build          # Build shared libraries and client
make test           # Run tests for shared components
make proto          # Generate gRPC code for all languages
make py-build       # Build Python components only
make run-client     # Run shared test client
```

### Service Repository Commands
```bash
make setup          # Install service dependencies
make build          # Build service components
make test           # Run service tests
make run-server     # Start service server
make py-nuitka      # Build optimized binary
make package        # Create service deployment package
```

## Configuration System

### Common Repository (`Makefile.config`)
```makefile
# Project Information
PROJECT_NAME := my-service-common
PROJECT_DOMAIN := echo
PROJECT_VERSION := 1.0.0

# Repository Structure
REPO_TYPE := multi-language
GO_DIR := go
PYTHON_DIR := python
ENABLE_GO := yes
ENABLE_PYTHON := yes

# Build Targets
DEFAULT_PORT := 50055
BUILD_CLI := yes
BUILD_LIB := yes
```

### Service Repository (`Makefile.config`)
```makefile
# Project Information
PROJECT_NAME := my-service-py
PROJECT_DOMAIN := echo
PROJECT_VERSION := 1.0.0

# Repository Structure
REPO_TYPE := implementation-py
PYTHON_DIR := .

# Language Support
ENABLE_GO := no
ENABLE_PYTHON := yes

# Dependencies
COMMON_DEPENDENCY := my-service-common

# Nuitka Configuration
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := my-service-server
NUITKA_ENTRY_POINT := srv/run_server.py
```

## Step-by-Step Customization

### Step 1: Setup Common Repository

```bash
# Copy and customize common repository
cp -r hsu-example3-common/ my-service-common/
cd my-service-common/
rm -rf make/  # Remove make directory (will be added as submodule)

# Initialize git and add HSU makefile system
git init
git submodule add https://github.com/core-tools/make.git make

# Update configuration
edit Makefile.config  # Update PROJECT_NAME, GO_MODULE_NAME

# Update Go module
cd go/
go mod edit -module github.com/myorg/my-service-common

# Test common components
make setup && make build && make test
echo "✓ Common repository working!"
```

### Step 2: Setup Service Repository

```bash
# Copy and customize service repository
cd ..
cp -r hsu-example3-srv-py/ my-service-py/
cd my-service-py/
rm -rf make/  # Remove make directory (will be added as submodule)

# Initialize git and add HSU makefile system
git init
git submodule add https://github.com/core-tools/make.git make

# Update configuration
edit Makefile.config  # Update PROJECT_NAME, GO_MODULE_NAME

# Update Python project settings
edit pyproject.toml  # Update package name and dependencies

# Test service
make setup && make build && make test
echo "✓ Service repository working!"
```

### Step 3: Customize Protocol Definition

Edit `my-service-common/api/proto/myservice.proto`:
```protobuf
syntax = "proto3";

package myservice;

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
# In common repository
cd my-service-common/
make proto          # Regenerates gRPC code
make build          # Verify compilation
```

### Step 5: Implement Business Logic

Edit `my-service-common/python/lib/domain/contract.py`:
```python
from abc import ABC, abstractmethod

class Contract(ABC):
    @abstractmethod
    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        pass
```

Edit `my-service-py/srv/domain/simple_handler.py`:
```python
# Import from common repository (adjust path as needed)
from my_service_common.lib.domain.contract import Contract

class SimpleHandler(Contract):
    def __init__(self):
        pass

    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        print(f"Python service processing: {input} (count: {count})")
        
        result = f"py-processed-{input}-{count}"
        success = True
        
        print(f"Python service result: {result}")
        return result, success
```

### Step 6: Test Integration

```bash
# Start service
cd my-service-py/
make run-server     # Terminal 1: Start Python service

# Test with shared client
cd ../my-service-common/python/
make run-client     # Terminal 2: Test service
```

## Key Architecture Patterns

### Repository Separation
- **Common Repository**: Shared protocols, interfaces, client libraries
- **Service Repository**: Implementation-specific business logic and optimizations
- **Independent Versioning**: Each repository can evolve independently

### Python Dependency Management
```toml
# Common repository pyproject.toml
[project]
name = "my-service-common"
version = "1.2.3"

# Service repository pyproject.toml
[project]
name = "my-service-py"
dependencies = [
    "my-service-common>=1.2.0,<2.0.0",  # Released version
]
```

### Shared Contract Pattern
```python
# Common repository defines ABC
class Contract(ABC):
    @abstractmethod
    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        pass

# Service repository implements ABC
class SimpleHandler(Contract):
    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        # Service-specific implementation
        pass
```

## Production Deployment

### Repository Versioning

```bash
# Release common repository
cd my-service-common/
python -m build      # Build wheel
twine upload dist/*  # Upload to PyPI
git tag v1.2.3

# Update service dependency
cd ../my-service-py/
pip install my-service-common==1.2.3
```

### Independent Service Deployment

```bash
# Build optimized service binary
cd my-service-py/
make py-nuitka      # Create optimized binary
make package        # Create deployment package

# Deploy independently of other services
```

### Docker Deployment

```bash
# Each repository has independent Docker builds
cd my-service-py/
make docker         # Build service container

cd ../my-service-common/
make docker         # Build client tools container
```

## Development Workflow

### Daily Development (Common Components)
```bash
cd my-service-common/
make clean && make setup && make proto && make build && make test
```

### Daily Development (Service Implementation)
```bash
cd my-service-py/
make clean && make setup && make build && make test
make run-server     # Local testing
```

### Cross-Repository Integration
```bash
# Test with latest common components
cd my-service-common/
make build && pip install -e python/

cd ../my-service-py/
make setup          # Picks up latest common components
make run-server     # Test integration
```

## Advantages of This Approach

### **Team Independence**
- Teams can work on services independently
- Different release cycles for different components
- Clear ownership boundaries

### **Python Ecosystem Optimization**
- Service-specific Python package dependencies
- ML/data processing library isolation
- Independent Python version management

### **Controlled API Evolution**
- Common repository manages API versioning
- Python package versioning for backward compatibility
- Clear migration paths

### **Production Flexibility**
- Independent scaling and deployment
- Service-specific optimizations (Nuitka, dependencies)
- Separate monitoring and alerting

## Migration Paths

### From Single-Repository (Approach 1 or 2)
```bash
# Extract shared components
mkdir my-service-common/
mv my-single-service/api/ my-service-common/
mv my-single-service/lib/domain/ my-service-common/python/lib/

# Create service repository
mkdir my-service-py/
mv my-single-service/srv/ my-service-py/
# Update dependencies to point to common repository
```

### Adding More Services
```bash
# Create additional service repositories
cp -r my-service-py/ my-service-ml-py/
cd my-service-ml-py/

# Reinitialize git submodule (copying converts submodule to regular directory)
rm -rf make/
git init
git submodule add https://github.com/core-tools/make.git make

# Customize for ML workloads while keeping same common dependency
```

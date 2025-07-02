# Single-Repository HSU Python Implementation Guide

This guide shows you how to create a Python-based HSU server using the proven **"copy working example"** approach. You'll start with a working system and customize it for your needs.

## Overview

**Repository Approach 1 (Python)** provides a self-contained Python implementation:
- **Single repository** with everything included
- **Standard Python project structure** with modern packaging
- **Universal makefile commands** for consistent development
- **Nuitka binary compilation** for optimized deployment
- **Immediate working example** you can run and modify

This approach is perfect for:
- Learning the HSU platform with Python
- Python-focused development teams
- ML/data processing services
- Rapid prototyping with Python ecosystem

## Prerequisites

- Python 3.8+
- Protocol Buffers compiler (`protoc`)
- GNU Make or compatible
- Basic understanding of gRPC and Python

## 🎯 Quick Start: Copy Working Example

The fastest way to get started is to copy the proven working example:

```bash
# Copy the working Python example (without make system)
cp -r hsu-example1-py/ my-python-service/
cd my-python-service/
rm -rf make/  # Remove make directory (will be added as submodule)

# Add HSU makefile system as git submodule
git init
git submodule add https://github.com/core-tools/make.git make

# Test that everything works immediately
make setup && make build && make test

# Start the server
make py-run-server

# In another terminal, test it
make run-client
```

**Expected output:**
```
✓ Core service health check passed
✓ Echo response: py-simple-echo: Hello World!
✓ All tests passed!
```

## 📁 Actual Directory Structure

The working `hsu-example1-py` uses this proven structure:

```
my-python-service/                   # Root directory
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
│       ├── echoservice.proto        # gRPC service definition
│       ├── generate-py.bat          # Windows code generation
│       └── generate-py.sh           # Unix code generation
├── lib/
│   ├── control/
│   │   ├── gateway.py               # Client gateway
│   │   ├── handler.py               # gRPC ↔ domain adapter
│   │   └── serve_echo.py            # Server setup helper
│   ├── domain/
│   │   ├── contract.py              # Domain interface
│   │   └── simple_handler.py        # Business logic implementation
│   └── generated/
│       └── api/proto/               # Generated gRPC code
├── cli/
│   └── run_client.py                # Test client
├── srv/
│   └── run_server.py                # Server entry point
├── pyproject.toml
├── requirements.txt
└── README.md
```

## 🛠️ Real Makefile Commands

The working example provides these **universal commands**:

### Core Development Commands
```bash
make setup          # Install Python packages and dependencies
make build          # Build Python components
make test           # Run Python tests
make clean          # Clean all build artifacts
make proto          # Generate gRPC code from .proto files
```

### Python-Specific Commands
```bash
make py-build       # Build Python components
make py-test        # Run Python tests
make py-lint        # Lint Python code with flake8
make py-format      # Format Python code with black
make py-protoc      # Generate Python gRPC code
make py-nuitka      # Build optimized binary with Nuitka
make nuitka         # Alias for py-nuitka
```

### Runtime Commands
```bash
make py-run-server  # Start Python server
make run-client     # Run test client
make run-server     # Alias for py-run-server
```

## ⚙️ Configuration System

The working example uses `Makefile.config` for project settings:

```makefile
# Project Information
PROJECT_NAME := my-python-service
PROJECT_DOMAIN := echo
PROJECT_VERSION := 1.0.0

# Repository Structure
REPO_TYPE := single-language-py
PYTHON_DIR := .

# Language Support
ENABLE_GO := no
ENABLE_PYTHON := yes

# Build Targets
DEFAULT_PORT := 50055

# Nuitka Configuration (Python binary compilation)
ENABLE_NUITKA := yes
NUITKA_OUTPUT_NAME := my-service-server
NUITKA_ENTRY_POINT := srv/run_server.py
NUITKA_EXCLUDES_FILE := nuitka_excludes.txt
NUITKA_EXTRA_MODULES := srv.domain.simple_handler
NUITKA_BUILD_MODE := onefile
```

## 🔄 Step-by-Step Customization

### Step 1: Initial Setup

```bash
# Copy and rename the working example
cp -r hsu-example1-py/ my-python-service/
cd my-python-service/
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
PROJECT_NAME := my-python-service
PROJECT_DOMAIN := myservice
NUITKA_OUTPUT_NAME := my-service-server
```

Update `pyproject.toml`:
```toml
[project]
name = "my-python-service"
version = "1.0.0"
description = "My Python HSU Service"

[project.dependencies]
# Keep existing dependencies
```

### Step 3: Customize Protocol Definition

Edit `api/proto/myservice.proto`:
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
make proto          # Regenerates Python gRPC code
make build          # Verify compilation
```

### Step 5: Implement Business Logic

Edit `lib/domain/contract.py`:
```python
from abc import ABC, abstractmethod

class Contract(ABC):
    @abstractmethod
    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        pass
```

Edit `srv/domain/simple_handler.py`:
```python
from lib.domain.contract import Contract

class SimpleHandler(Contract):
    def __init__(self):
        pass

    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        print(f"Processing data: {input} (count: {count})")
        
        result = f"processed-{input}-{count}"
        success = True
        
        print(f"Process result: {result}")
        return result, success
```

### Step 6: Test Your Changes

```bash
make build && make test
make py-run-server   # Terminal 1: Start server
make run-client      # Terminal 2: Test server
```

## 🏗️ Key Python Patterns

### ABC Contract Pattern
```python
from abc import ABC, abstractmethod

class Contract(ABC):
    @abstractmethod
    def process_data(self, input: str, count: int) -> tuple[str, bool]:
        pass
```

### gRPC Handler Pattern
- Convert between gRPC types and Python types
- Exception handling with proper gRPC status codes
- Clean separation of concerns

### Server Helper Function
```python
from lib.control.serve_echo import serve_echo
from srv.domain.simple_handler import SimpleHandler

def serve():
    handler = SimpleHandler()
    serve_echo(handler)
```

## 🚀 Production Deployment

### Build Optimized Binary with Nuitka

```bash
# Build optimized Python binary
make py-nuitka

# Result: build/my-service-server (or .exe on Windows)
```

### Package Management

```bash
# Install as package
pip install -e .

# Build wheel
python -m build
```

### Docker Deployment

The makefile system supports Docker builds:
```bash
make docker         # Build Python container
```

## 🔍 Development Workflow

### Daily Development Cycle
```bash
make clean                   # Start fresh
make setup                   # Update dependencies
make proto                   # Regenerate any protocol changes
make build && make test      # Build and verify
make py-format && make py-lint  # Code quality
```

### Testing and Debugging
```bash
make py-test               # Run Python tests
make py-run-server         # Start server for debugging
make run-client            # Test client functionality
```

### Code Quality
```bash
make py-format             # Format code with black
make py-lint               # Lint with flake8
make py-test               # Run tests
```

## 🏆 Advantages of This Approach

### ✅ **Immediate Working System**
- Copy and run - everything works immediately
- Modern Python packaging with pyproject.toml
- Real makefile commands that actually work

### ✅ **Python Ecosystem Integration**
- Full access to Python packages (NumPy, TensorFlow, etc.)
- Modern async/await support
- Rich data processing libraries

### ✅ **Optimized Deployment**
- Nuitka compilation for performance
- Single binary deployment
- Cross-platform compatibility

### ✅ **Development Friendly**
- Fast iteration cycles
- Interactive debugging
- Comprehensive testing tools

## 🔄 Migration Paths

### To Multi-Language (Approach 2)
```bash
# Restructure to multi-language
mkdir my-multi-service/
mv my-python-service/* my-multi-service/python/
# Add Go implementation
# Update Makefile.config for multi-language
```

### To Multi-Repository (Approach 3)
```bash
# Extract shared components
mkdir my-service-common/
mv api/ my-service-common/
# Create separate implementation repository
```

## 📚 Next Steps

### Advanced Python Topics
- **[Python Best Practices](../guides/HSU_BEST_PRACTICES.md)** - Production Python patterns
- **[Multi-Language Support](../guides/MULTI_LANGUAGE.md)** - Python + Go coordination
- **[Performance Optimization](../guides/HSU_BEST_PRACTICES.md)** - Python-specific tuning

### Production Considerations
- **[Testing and Deployment](../guides/HSU_TESTING_DEPLOYMENT.md)** - Production deployment
- **[Configuration Management](../deployment/configuration.md)** - Environment management
- **[Python Package Deployment](../deployment/python_package_deployment_guide.md)** - PyPI publishing

### Related Approaches
- **[Single-Repository Multi-Language](INTEGRATED_HSU_SINGLE_REPO_MULTI_LANG_GUIDE.md)** - Add Go support
- **[Single-Repository Go](INTEGRATED_HSU_SINGLE_REPO_GO_GUIDE.md)** - Go implementation
- **[Multi-Repository Python](INTEGRATED_HSU_MULTI_REPO_PYTHON_GUIDE.md)** - Independent Python services

---

**🎉 You now have a production-ready Python HSU service!**

*This approach provides a solid foundation for Python development with the HSU Platform, leveraging the rich Python ecosystem and universal build system.* 
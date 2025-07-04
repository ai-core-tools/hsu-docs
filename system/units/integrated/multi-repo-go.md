# Multi-Repository HSU Go Implementation Guide

This guide shows you how to create a Go-based HSU server using the proven **"copy working example"** approach for multi-repository architecture. You'll start with working systems and customize them for your needs.

## Overview

**Repository Approach 3 (Go)** provides independent Go microservices:
- **Separate repositories** for shared components and implementations
- **Independent deployment cycles** for each service
- **Shared protocol definitions** via common repository
- **Universal makefile commands** across all repositories
- **Team independence** with controlled dependencies

This approach is perfect for:
- Large teams requiring independence
- Multiple Go service implementations
- Independent deployment cycles
- Microservice architectures
- Controlled API evolution

## Prerequisites

- Go 1.22+
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

# Copy the working Go service implementation (without make system)
cd ..
cp -r hsu-example3-srv-go/ my-service-go/
cd my-service-go/
rm -rf make/  # Remove make directory (will be added as submodule)

# Add HSU makefile system as git submodule
git init
git submodule add https://github.com/core-tools/make.git make

# Test Go service works
make setup && make build && make test
make run-server
```

**Expected output:**
```
✓ Common repository: Protocol generation and client working
✓ Go service: Server running on port 50055
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

### Go Service Repository (`my-service-go/`)
```
my-service-go/                       # Go service implementation
├── Makefile                         # Universal makefile entry point
├── Makefile.config                  # Service-specific configuration
├── make/                            # HSU Universal Makefile System (git submodule)
│   ├── HSU_MAKEFILE_ROOT.mk         # Main makefile system
│   ├── HSU_MAKEFILE_GO.mk           # Go-specific targets
│   ├── HSU_MAKEFILE_PYTHON.mk       # Python-specific targets
│   ├── HSU_MAKE_CONFIG_TMPL.mk      # Configuration template
│   └── README.md                    # Makefile system documentation
├── cmd/
│   └── srv/
│       ├── domain/
│       │   └── simple_handler.go    # Service-specific business logic
│       └── echogrpcsrv/
│           └── main.go              # Service entry point
├── go.mod                           # Service dependencies
├── go.sum
└── README.md
```

## Real Makefile Commands

Both repositories provide these **universal commands**:

### Common Repository Commands
```bash
make setup          # Install Go dependencies for common components
make build          # Build shared libraries and client
make test           # Run tests for shared components
make proto          # Generate gRPC code for all languages
make go-build       # Build Go components only
make run-client     # Run shared test client
```

### Service Repository Commands
```bash
make setup          # Install service dependencies
make build          # Build service components
make test           # Run service tests
make run-server     # Start service server
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

# Go Configuration
GO_MODULE_NAME := github.com/myorg/my-service-common
GO_BUILD_FLAGS := -v

# Build Targets
DEFAULT_PORT := 50055
BUILD_CLI := yes
BUILD_LIB := yes
```

### Service Repository (`Makefile.config`)
```makefile
# Project Information
PROJECT_NAME := my-service-go
PROJECT_DOMAIN := echo
PROJECT_VERSION := 1.0.0

# Repository Structure
REPO_TYPE := implementation-go
GO_DIR := .

# Language Support
ENABLE_GO := yes
ENABLE_PYTHON := no

# Go Configuration
GO_MODULE_NAME := github.com/myorg/my-service-go
GO_BUILD_FLAGS := -v

# Dependencies
COMMON_DEPENDENCY := my-service-common

# Build Targets
BUILD_SRV := yes
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
cp -r hsu-example3-srv-go/ my-service-go/
cd my-service-go/
rm -rf make/  # Remove make directory (will be added as submodule)

# Initialize git and add HSU makefile system
git init
git submodule add https://github.com/core-tools/make.git make

# Update configuration
edit Makefile.config  # Update PROJECT_NAME, GO_MODULE_NAME

# Update Go module and dependencies
go mod edit -module github.com/myorg/my-service-go
go mod edit -replace github.com/myorg/my-service-common=../my-service-common

# Test service
make setup && make build && make test
echo "✓ Service repository working!"
```

### Step 3: Customize Protocol Definition

Edit `my-service-common/api/proto/myservice.proto`:
```protobuf
syntax = "proto3";

package myservice;
option go_package = "github.com/myorg/my-service-common/go/pkg/generated/api/proto";

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

Edit `my-service-common/go/pkg/domain/contract.go`:
```go
package domain

import "context"

type Contract interface {
    ProcessData(ctx context.Context, input string, count int32) (string, bool, error)
}
```

Edit `my-service-go/cmd/srv/domain/simple_handler.go`:
```go
package domain

import (
    "context"
    "fmt"

    "github.com/myorg/my-service-common/go/pkg/domain"
    "github.com/myorg/my-service-common/go/pkg/logging"
)

func NewSimpleHandler(logger logging.Logger) domain.Contract {
    return &simpleHandler{
        logger: logger,
    }
}

type simpleHandler struct {
    logger logging.Logger
}

func (h *simpleHandler) ProcessData(ctx context.Context, input string, count int32) (string, bool, error) {
    h.logger.Infof("Go service processing: %s (count: %d)", input, count)
    
    result := fmt.Sprintf("go-processed-%s-%d", input, count)
    success := true
    
    h.logger.Debugf("Go service result: %s", result)
    return result, success, nil
}
```

### Step 6: Test Integration

```bash
# Start service
cd my-service-go/
make run-server     # Terminal 1: Start Go service

# Test with shared client
cd ../my-service-common/go/
make run-client     # Terminal 2: Test service
```

## Key Architecture Patterns

### Repository Separation
- **Common Repository**: Shared protocols, interfaces, client libraries
- **Service Repository**: Implementation-specific business logic
- **Independent Versioning**: Each repository can evolve independently

### Dependency Management
```go
// In service go.mod
module github.com/myorg/my-service-go

require (
    github.com/myorg/my-service-common v1.2.3  // Released version
)

// For development
replace github.com/myorg/my-service-common => ../my-service-common
```

### Shared Contract Pattern
```go
// Common repository defines interface
type Contract interface {
    ProcessData(ctx context.Context, input string, count int32) (string, bool, error)
}

// Service repository implements interface
func NewSimpleHandler(logger logging.Logger) domain.Contract {
    return &simpleHandler{logger: logger}
}
```

## 🚀 Production Deployment

### Repository Versioning

```bash
# Release common repository
cd my-service-common/
git tag v1.2.3
git push origin v1.2.3

# Update service dependency
cd ../my-service-go/
go get github.com/myorg/my-service-common@v1.2.3
```

### Independent Service Deployment

```bash
# Build service for production
cd my-service-go/
make build
make package        # Create deployment package

# Deploy independently of other services
```

### Docker Deployment

```bash
# Each repository has independent Docker builds
cd my-service-go/
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
cd my-service-go/
make clean && make setup && make build && make test
make run-server     # Local testing
```

### Cross-Repository Integration
```bash
# Test with latest common components
cd my-service-common/
make build

cd ../my-service-go/
make setup          # Picks up latest common components
make run-server     # Test integration
```

## Advantages of This Approach

### **Team Independence**
- Teams can work on services independently
- Different release cycles for different components
- Clear ownership boundaries

### **Microservice Scaling**
- Independent deployment of services
- Separate scaling and monitoring
- Technology choice flexibility per service

### **Controlled API Evolution**
- Common repository manages API versioning
- Backward compatibility enforcement
- Clear migration paths

### **Production Robustness**
- Independent failure domains
- Separate monitoring and alerting
- Independent security updates

## Migration Paths

### From Single-Repository (Approach 1 or 2)
```bash
# Extract shared components
mkdir my-service-common/
mv my-single-service/api/ my-service-common/
mv my-single-service/pkg/domain/ my-service-common/go/pkg/

# Create service repository
mkdir my-service-go/
mv my-single-service/cmd/ my-service-go/
# Update dependencies to point to common repository
```

### Adding More Services
```bash
# Create additional service repositories
cp -r my-service-go/ my-service-advanced-go/
cd my-service-advanced-go/

# Reinitialize git submodule (copying converts submodule to regular directory)
rm -rf make/
git init
git submodule add https://github.com/core-tools/make.git make

# Customize business logic while keeping same common dependency
```

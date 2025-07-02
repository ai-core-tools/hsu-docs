# Single-Repository HSU Go Implementation Guide

This guide shows you how to create a Go-based HSU server using the proven **"copy working example"** approach. You'll start with a working system and customize it for your needs.

## Overview

**Repository Approach 1 (Go)** provides a self-contained Go implementation:
- **Single repository** with everything included  
- **Standard Go project structure** (`pkg/`, `cmd/`, `api/`)
- **Universal makefile commands** for consistent development
- **Immediate working example** you can run and modify

This approach is perfect for:
- Learning the HSU platform with Go
- Go-focused development teams
- Single-language microservices
- Rapid prototyping and development

## Prerequisites

- Go 1.22+
- Protocol Buffers compiler (`protoc`)
- GNU Make or compatible
- Basic understanding of gRPC

## 🎯 Quick Start: Copy Working Example

The fastest way to get started is to copy the proven working example:

```bash
# Copy the working Go example
cp -r hsu-example1-go/ my-go-service/
cd my-go-service/

# Test that everything works immediately
make setup && make build && make test

# Start the server
make go-run-server

# In another terminal, test it
make run-client
```

**Expected output:**
```
✓ Core service health check passed
✓ Echo response: go-simple-echo: Hello World!
✓ All tests passed!
```

## 📁 Actual Directory Structure

The working `hsu-example1-go` uses this proven structure:

```
my-go-service/                       # Root directory
├── Makefile                         # Universal makefile entry point
├── Makefile.config                  # Project configuration
├── make/                            # HSU Universal Makefile System
├── api/
│   └── proto/
│       ├── echoservice.proto        # gRPC service definition
│       ├── generate-go.bat          # Windows code generation
│       └── generate-go.sh           # Unix code generation
├── pkg/
│   ├── control/
│   │   ├── gateway.go               # Client gateway
│   │   ├── handler.go               # gRPC ↔ domain adapter
│   │   └── main_echo.go             # Server setup helper
│   ├── domain/
│   │   ├── contract.go              # Domain interface
│   │   └── simple_handler.go        # Business logic implementation
│   ├── generated/
│   │   └── api/proto/               # Generated gRPC code
│   └── logging/
│       └── logging.go               # Logging interface
├── cmd/
│   ├── cli/echogrpccli/
│   │   └── main.go                  # Test client
│   └── srv/echogrpcsrv/
│       └── main.go                  # Server entry point
├── go.mod
├── go.sum
└── README.md
```

## 🛠️ Real Makefile Commands

The working example provides these **universal commands**:

### Core Development Commands
```bash
make setup          # Install Go modules and dependencies
make build          # Build all Go components
make test           # Run Go tests with race detection
make clean          # Clean all build artifacts
make proto          # Generate gRPC code from .proto files
```

### Go-Specific Commands
```bash
make go-build       # Build Go components
make go-test        # Run Go tests
make go-lint        # Lint Go code with golangci-lint
make go-format      # Format Go code with go fmt
make go-protoc      # Generate Go gRPC code
```

### Runtime Commands
```bash
make go-run-server  # Start Go server
make run-client     # Run test client
make run-server     # Alias for go-run-server
```

## ⚙️ Configuration System

The working example uses `Makefile.config` for project settings:

```makefile
# Project Information
PROJECT_NAME := my-go-service
PROJECT_DOMAIN := echo
PROJECT_VERSION := 1.0.0

# Repository Structure
REPO_TYPE := single-language-go
GO_DIR := .

# Language Support  
ENABLE_GO := yes
ENABLE_PYTHON := no

# Go Configuration
GO_MODULE_NAME := github.com/myorg/my-go-service
GO_BUILD_FLAGS := -v
GO_TEST_FLAGS := -v -race
GO_TEST_TIMEOUT := 10m

# Build Targets
DEFAULT_PORT := 50055
BUILD_CLI := yes
BUILD_SRV := yes
BUILD_LIB := yes

# Development Tools
ENABLE_LINTING := yes
ENABLE_FORMATTING := yes
ENABLE_BENCHMARKS := yes
```

## 🔄 Step-by-Step Customization

### Step 1: Initial Setup

```bash
# Copy and rename the working example
cp -r hsu-example1-go/ my-go-service/
cd my-go-service/

# Verify everything works out of the box
make setup && make build && make test
echo "✓ Base system working!"
```

### Step 2: Configure Your Project

Edit `Makefile.config`:
```makefile
# Update project identification
PROJECT_NAME := my-go-service
PROJECT_DOMAIN := myservice
GO_MODULE_NAME := github.com/myorg/my-go-service
```

Update `go.mod`:
```go
module github.com/myorg/my-go-service

go 1.22

require (
    github.com/core-tools/hsu-core v0.0.0
    github.com/jessevdk/go-flags v1.5.0
    google.golang.org/grpc v1.64.0
    google.golang.org/protobuf v1.34.1
)
```

### Step 3: Customize Protocol Definition

Edit `api/proto/myservice.proto`:
```protobuf
syntax = "proto3";

package myservice;
option go_package = "github.com/myorg/my-go-service/pkg/generated/api/proto";

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
make proto          # Regenerates Go gRPC code
make build          # Verify compilation
```

### Step 5: Implement Business Logic

Edit `pkg/domain/contract.go`:
```go
package domain

import "context"

type Contract interface {
    ProcessData(ctx context.Context, input string, count int32) (string, bool, error)
}
```

Edit `pkg/domain/simple_handler.go`:
```go
package domain

import (
    "context"
    "fmt"

    "github.com/myorg/my-go-service/pkg/logging"
)

func NewSimpleHandler(logger logging.Logger) Contract {
    return &simpleHandler{
        logger: logger,
    }
}

type simpleHandler struct {
    logger logging.Logger
}

func (h *simpleHandler) ProcessData(ctx context.Context, input string, count int32) (string, bool, error) {
    h.logger.Infof("Processing data: %s (count: %d)", input, count)
    
    result := fmt.Sprintf("processed-%s-%d", input, count)
    success := true
    
    h.logger.Debugf("Process result: %s", result)
    return result, success, nil
}
```

### Step 6: Test Your Changes

```bash
make build && make test
make go-run-server   # Terminal 1: Start server
make run-client      # Terminal 2: Test server
```

## 🏗️ Key Go Patterns

### Domain Contract Interface
- Clean separation between business logic and gRPC transport
- Easy to test and mock
- Interface-driven design

### Factory Function Pattern
```go
func NewSimpleHandler(logger logging.Logger) Contract {
    return &simpleHandler{logger: logger}
}
```

### gRPC Adapter Pattern
- Convert between gRPC types and domain types
- Keep domain logic pure and testable
- Error handling at the gRPC boundary

### Helper Function Usage
```go
func main() {
    control.MainEcho(domain.NewSimpleHandler)
}
```

## 🚀 Production Deployment

### Build Production Binary

```bash
# Build optimized binary
make go-build

# Result: cmd/srv/echogrpcsrv/echogrpcsrv (or .exe on Windows)
```

### Docker Deployment

The makefile system supports Docker builds:
```bash
make docker         # Build Go container
```

### Performance Optimizations

```bash
# Build with optimizations
GO_BUILD_FLAGS="-ldflags='-s -w'" make go-build

# Build for specific platforms
GOOS=linux GOARCH=amd64 make go-build
```

## 🔍 Development Workflow

### Daily Development Cycle
```bash
make clean                   # Start fresh
make setup                   # Update dependencies
make proto                   # Regenerate any protocol changes
make build && make test      # Build and verify
make go-format && make go-lint  # Code quality
```

### Testing and Debugging
```bash
make go-test               # Run tests with race detection
make go-run-server         # Start server for debugging
make run-client            # Test client functionality
```

### Code Quality
```bash
make go-format             # Format code with go fmt
make go-lint               # Lint with golangci-lint
make go-test               # Run tests with coverage
```

## 🏆 Advantages of This Approach

### ✅ **Immediate Working System**
- Copy and run - everything works immediately
- No complex setup or configuration
- Real makefile commands that actually work

### ✅ **Standard Go Structure**
- Follows Go best practices
- Familiar `pkg/`, `cmd/`, `api/` layout
- Easy for Go developers to understand

### ✅ **Self-Contained**
- Everything in one repository
- No external dependencies to manage
- Complete control over the codebase

### ✅ **Production Ready**
- Based on proven working example
- Includes proper logging, error handling
- Ready for containerization and deployment

## 🔄 Migration Paths

### To Multi-Language (Approach 2)
```bash
# Restructure to multi-language
mkdir my-multi-service/
mv my-go-service/* my-multi-service/go/
# Add Python implementation
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

### Advanced Go Topics
- **[Go Best Practices](../guides/HSU_BEST_PRACTICES.md)** - Production Go patterns
- **[Protocol Buffer Evolution](../guides/HSU_PROTOCOL_BUFFERS.md)** - API versioning
- **[Performance Optimization](../guides/HSU_BEST_PRACTICES.md)** - Go-specific tuning

### Production Considerations
- **[Testing and Deployment](../guides/HSU_TESTING_DEPLOYMENT.md)** - Production deployment
- **[Configuration Management](../deployment/configuration.md)** - Environment management
- **[Monitoring and Observability](../guides/HSU_BEST_PRACTICES.md)** - Production monitoring

### Related Approaches
- **[Single-Repository Multi-Language](INTEGRATED_HSU_SINGLE_REPO_MULTI_LANG_GUIDE.md)** - Add Python support
- **[Single-Repository Python](INTEGRATED_HSU_SINGLE_REPO_PYTHON_GUIDE.md)** - Python implementation
- **[Multi-Repository Go](INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md)** - Independent Go services

---

**🎉 You now have a production-ready Go HSU service!**

*This approach provides a solid foundation for Go development with the HSU Platform, using proven patterns and the universal build system.* 
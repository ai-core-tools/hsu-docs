# HSU Repository Structure

This document explains the HSU platform's repository organization philosophy and how to structure your code across multiple repositories for maximum flexibility and maintainability.

## Overview

The HSU platform separates code into two types of repositories:
1. **Common Domain Repositories** - Shared components for a specific domain
2. **Server Implementation Repositories** - Individual server implementations

This separation enables multiple server implementations in different languages while sharing common components.

## Repository Types

### 1. Common Domain Repository

A common domain repository (e.g., `hsu-echo`, `hsu-llm`, `hsu-data-processor`) contains all shared components for a specific domain:

**Structure:**
```
hsu-{domain}/
├── api/
│   └── proto/
│       ├── {domain}service.proto      # gRPC service definition
│       ├── generate-go.sh             # Go code generation
│       ├── generate-go.bat            # Windows Go generation
│       ├── generate-py.sh             # Python code generation
│       └── generate-py.bat            # Windows Python generation
├── go/
│   ├── api/proto/                     # Generated Go gRPC code
│   ├── control/
│   │   ├── handler.go                 # gRPC ↔ domain adapter
│   │   └── main_{domain}.go           # Helper function for servers
│   ├── domain/
│   │   └── contract.go                # Go interface definition
│   └── logging/
│       └── logging.go                 # Logging interface
├── py/
│   ├── api/proto/                     # Generated Python gRPC code
│   ├── control/
│   │   ├── handler.py                 # Python gRPC ↔ domain adapter
│   │   └── serve_{domain}.py          # Helper function for servers
│   └── domain/
│       └── contract.py                # Python ABC definition
├── cmd/
│   └── {domain}grpccli/               # Test client application
├── internal/
│   └── logging/                       # Common logging utilities
├── go.mod                             # Go module definition
└── README.md
```

**Contents:**
- **Protocol Buffers**: gRPC service definitions and message types
- **Generated Code**: Go and Python gRPC client/server stubs
- **Domain Contracts**: Language-specific interface definitions
- **gRPC Adapters**: Code to convert between gRPC and domain types
- **Helper Functions**: Utilities to simplify server creation
- **Client Applications**: Test and utility clients
- **Documentation**: Usage examples and API documentation

### 2. Server Implementation Repository

Server implementation repositories contain the actual business logic for a specific variant:

**Go Server Structure:**
```
hsu-{domain}-{variant}-srv-go/
├── cmd/
│   └── {domain}grpcsrv/
│       └── main.go                    # Entry point
├── internal/
│   └── domain/
│       └── {variant}_handler.go       # Business logic implementation
├── go.mod                             # Module with domain dependency
├── go.sum
└── README.md
```

**Python Server Structure:**
```
hsu-{domain}-{variant}-srv-py/
├── hsu_core/                          # Git submodule to hsu-core
├── hsu_{domain}/                      # Git submodule to common domain repo
├── {variant}_handler.py               # Business logic implementation
├── run_server.py                      # Entry point
├── requirements.txt                   # Python dependencies
├── Makefile                           # Build automation
├── .gitmodules                        # Git submodule configuration
└── README.md
```

## Design Rationale

### Why Separate Repositories?

1. **Multiple Implementations Support**
   - Different server variants can use different technologies
   - Example: `hsu-llm-llamacpp-srv-go` vs `hsu-llm-onnx-srv-go` vs `hsu-llm-transformers-srv-py`
   - Each implementation can optimize for different use cases

2. **Dependency Isolation**
   - Server implementations can have heavy dependencies without affecting common code
   - ML libraries, graphics processing, etc., stay isolated to specific implementations

3. **Independent Development**
   - Teams can work on different implementations independently
   - Different release cycles for common vs implementation code

4. **Language Flexibility**
   - Common components are minimal and work across languages
   - Implementations can use language-specific best practices and libraries

### Why Git Submodules for Python?

Git submodules are used for Python servers as a temporary solution:

```bash
# In hsu-{domain}-{variant}-srv-py/
git submodule add https://github.com/yourorg/hsu-core.git hsu_core
git submodule add https://github.com/yourorg/hsu-{domain}.git hsu_{domain}
```

**Advantages:**
- Guarantees exact versions of dependencies
- Enables offline development
- Simple setup for development environments

**Future Migration:**
The platform will migrate to Python package-based distribution later, but submodules provide a quick setup for local development teams.

## Example: Echo Domain

The `hsu-echo` domain demonstrates this structure:

### Common Repository: `hsu-echo/`

**Protocol Buffer Definition** (`api/proto/echoservice.proto`):
```proto
syntax = "proto3";
option go_package = "github.com/core-tools/hsu-echo/api/proto";
package proto;

service EchoService {
  rpc Echo(EchoRequest) returns (EchoResponse) {}
}

message EchoRequest {
  string message = 1;
}

message EchoResponse {
  string message = 1;
}
```

**Go Domain Contract** (`go/domain/contract.go`):
```go
package domain

import "context"

type Contract interface {
    Echo(ctx context.Context, message string) (string, error)
}
```

**Python Domain Contract** (`py/domain/contract.py`):
```python
from abc import ABC, abstractmethod

class Contract(ABC):
    @abstractmethod
    def Echo(self, message: str) -> str:
        pass
```

### Server Implementations

**Go Server**: `hsu-echo-super-srv-go/`
- Minimal structure with just business logic
- Uses the common domain's `MainEcho()` helper function
- Entry point: `main()` calls `echoControl.MainEcho(domain.NewSuperHandler)`

**Python Server**: `hsu-echo-super-srv-py/`
- Uses git submodules for dependencies
- Uses the common domain's `serve_echo()` helper function
- Entry point: `serve_echo(SuperHandler())`

## Best Practices

### Version Management
- **Tag releases** in common domain repositories using semantic versioning
- **Update submodules** when upgrading dependencies
- **Use replace directives** in Go during development:
  ```bash
  go mod edit -replace github.com/core-tools/hsu-echo=../hsu-echo
  ```

### Development Workflow
1. **Start with the domain contract** - Define the interface first
2. **Create protocol buffers** - Design the gRPC API
3. **Generate code** - Use the provided scripts
4. **Implement adapters** - Connect gRPC to domain types
5. **Create helper functions** - Simplify server creation
6. **Build implementations** - Create specific server variants

### Repository Naming
- **Domain repos**: `hsu-{domain}` (e.g., `hsu-echo`, `hsu-llm`)
- **Go servers**: `hsu-{domain}-{variant}-srv-go`
- **Python servers**: `hsu-{domain}-{variant}-srv-py`

### Dependency Management

**Go Servers:**
```go
// go.mod
module github.com/yourorg/hsu-echo-super-srv-go

require (
    github.com/core-tools/hsu-echo v0.1.0
)
```

**Python Servers:**
```bash
# Update all submodules
git submodule update --init --recursive
git submodule foreach git pull origin main
```

## Creating New Domains

When creating a new domain:

1. **Create the common domain repository**
   - Define protocol buffers
   - Create domain contracts for Go and Python
   - Implement gRPC adapters
   - Add helper functions
   - Create test client

2. **Create server implementation repositories**
   - Go: Use Go modules to depend on common repo
   - Python: Use git submodules to include common repo
   - Implement the domain contract
   - Create entry point using helper functions

3. **Test across implementations**
   - Use the common test client
   - Verify both Go and Python servers work
   - Test with HSU master processes

## Migration Path

The current structure supports the platform's evolution:

1. **Current**: Git submodules for Python dependencies
2. **Future**: Python packages distributed through package managers
3. **Always**: Go modules for Go dependencies

The common domain repository structure remains stable, enabling smooth migration of dependency management approaches without affecting server implementations.

## Next Steps

- [Go Implementation Guide](INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md) - Create Go servers
- [Python Implementation Guide](INTEGRATED_HSU_MULTI_REPO_PYTHON_GUIDE.md) - Create Python servers
- [Testing and Deployment](HSU_TESTING_DEPLOYMENT.md) - Test your implementations 
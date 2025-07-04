# HSU Repository Best Practices

This document provides development workflow guidelines, naming conventions, and best practices derived from successful implementation of the HSU Repository Portability Framework.

## General Principles

### 1. Start Simple, Scale Progressively
- ✅ **Begin with Approach 1** (single-language) for new domains
- ✅ **Evolve to Approach 2** when multi-language coordination is needed
- ✅ **Scale to Approach 3** when team independence becomes essential
- ❌ **Don't over-engineer** - choose the simplest approach that meets current needs

### 2. Maintain Repo-Portability
- ✅ **Preserve logical boundaries** - keep `/pkg`, `/cmd/srv`, `/cmd/cli` separation
- ✅ **Use consistent imports** - identical across all approaches
- ✅ **Follow naming conventions** - enable automatic migration tools
- ❌ **Don't break portability** with approach-specific code

### 3. API-First Design
- ✅ **Define Protocol Buffers first** - establish contracts before implementation
- ✅ **Version APIs carefully** - consider backward compatibility
- ✅ **Generate code consistently** - use provided scripts
- ❌ **Don't skip API design** - even for internal services

## Naming Conventions

### Repository Naming

**Pattern: `hsu-{domain}-{variant}-{type}-{lang}`**

```bash
# Approach 1: Single-Repository + Single-Language
hsu-example1-go                # Go implementation
hsu-example1-py                # Python implementation  
hsu-llm-go                     # LLM service in Go
hsu-data-processor-py          # Data processing service in Python

# Approach 2: Single-Repository + Multi-Language
hsu-example2                   # Multi-language echo service
hsu-llm                        # Multi-language LLM service
hsu-data-processor             # Multi-language data processor

# Approach 3: Multi-Repository Architecture
hsu-example3-common            # Shared components
hsu-example3-srv-go            # Go server implementation
hsu-example3-srv-py            # Python server implementation
hsu-llm-llamacpp-srv-go        # LlamaCP implementation
hsu-llm-transformers-srv-py    # Transformers implementation
```

### Module and Package Naming

**Go Modules:**
```go
// Approach 1
module github.com/org/hsu-example1-go

// Approach 2  
module github.com/org/hsu-example2/go

// Approach 3
module github.com/org/hsu-example3-srv-go
module github.com/org/hsu-example3-common
```

**Python Packages:**
```python
# Approach 1
name = "hsu-example1-py"           # Package name
"hsu_echo"                     # Import name

# Approach 2
name = "hsu-example2"              # Package name
"hsu_echo"                     # Import name (shared)

# Approach 3  
name = "hsu-example3-srv-py"       # Implementation package
name = "hsu-example3-common"       # Common package
```

### File and Folder Naming

**Standard Structure:**
```bash
api/proto/                     # Protocol buffer definitions
  {domain}service.proto        # Main service definition
  generate-go.sh               # Go generation script
  generate-py.sh               # Python generation script

pkg/ (Go) or lib/ (Python)    # Shared libraries
  domain/                      # Business logic interfaces
    contract.go/.py            # Main interface definition
  control/                     # gRPC ↔ domain adapters  
    handler.go/.py             # Request/response handling
    gateway.go/.py             # Service coordination
  generated/                   # Generated code
    api/proto/                 # Generated gRPC stubs

cmd/ (Go) or srv/ (Python)     # Executable implementations
  srv/{domain}grpcsrv/         # Server executable
    main.go                    # Go entry point
  run_server.py                # Python entry point
```

## Development Workflow

### Repository Setup

**1. Choose Approach Based on Team Size:**
```bash
# 1-3 developers: Approach 1
mkdir hsu-{domain}-{lang}
cd hsu-{domain}-{lang}
git submodule add https://github.com/Core-Tools/make.git make
git submodule update --init --recursive

# 3-8 developers: Approach 2  
mkdir hsu-{domain}
cd hsu-{domain}
mkdir go python api
git submodule add https://github.com/Core-Tools/make.git make
git submodule update --init --recursive

# 8+ developers: Approach 3
mkdir hsu-{domain}-common hsu-{domain}-srv-go hsu-{domain}-srv-py
# Set up each repository separately
```

**2. Configure Project:**
```makefile
# Makefile.config - adapt to your approach
PROJECT_NAME = your-project-name
PROJECT_TYPE = single-language-go|multi-language|implementation-go
HSU_APPROACH = 1|2|3
```

**3. Set Up Build System:**
```bash
# Add HSU makefile system as git submodule
git submodule add https://github.com/Core-Tools/make.git make
git submodule update --init --recursive

# Verify setup
make validate-setup
make debug-config
```

### API Development

**1. Define Protocol Buffers:**
```proto
// api/proto/{domain}service.proto
syntax = "proto3";
option go_package = "github.com/org/hsu-{domain}/api/proto";

service {Domain}Service {
  rpc {Operation}({OperationRequest}) returns ({OperationResponse}) {}
}
```

**2. Generate Code:**
```bash
# Generate for all languages in project
make proto-gen

# Or generate per language
cd api/proto
./generate-go.sh
./generate-py.sh
```

**3. Implement Contracts:**
```go
// Go: pkg/domain/contract.go
type Contract interface {
    Operation(ctx context.Context, req *Request) (*Response, error)
}
```

```python
# Python: lib/domain/contract.py
from abc import ABC, abstractmethod

class Contract(ABC):
    @abstractmethod
    def operation(self, request: Request) -> Response:
        pass
```

### Implementation Development

**1. Implement Business Logic:**
```go
// cmd/srv/domain/{variant}_handler.go
type {Variant}Handler struct{}

func (h *{Variant}Handler) Operation(ctx context.Context, req *Request) (*Response, error) {
    // Business logic here
    return &Response{}, nil
}
```

**2. Create Server Entry Point:**
```go
// cmd/srv/{domain}grpcsrv/main.go
func main() {
    handler := domain.New{Variant}Handler()
    {domain}Control.Main{Domain}(handler)
}
```

**3. Test Implementation:**
```bash
# Build and run
make build
make run-srv

# Test with client
make run-cli
```

### Migration Workflow

**From Approach 1 to Approach 2:**
```bash
# 1. Create language folders
mkdir go python

# 2. Move existing code  
mv pkg cmd go/               # Go code to go/
mv *.mod go/                 # Move go.mod

# 3. Update go.mod replace directive
cd go
go mod edit -replace github.com/org/hsu-{domain}=..

# 4. Add Python implementation
cd ../python
# Create Python structure: lib/, srv/, cli/

# 5. Update Makefile.config
PROJECT_TYPE = multi-language
GO_MODULE_PATH = go
PYTHON_PACKAGE_PATH = python
```

**From Approach 2 to Approach 3:**
```bash
# 1. Create common repository
mkdir ../hsu-{domain}-common
mv api/ ../hsu-{domain}-common/
mv go/pkg/domain ../hsu-{domain}-common/go/pkg/
mv python/lib/domain ../hsu-{domain}-common/python/lib/

# 2. Create implementation repositories
mkdir ../hsu-{domain}-srv-go
mv go/cmd/srv ../hsu-{domain}-srv-go/cmd/

# 3. Update dependencies
cd ../hsu-{domain}-srv-go
go mod init github.com/org/hsu-{domain}-srv-go
go mod edit -require github.com/org/hsu-{domain}-common@v1.0.0
```

## Language-Specific Best Practices

### Go Development

**Module Management:**
```bash
# Use replace directives for local development
go mod edit -replace github.com/org/common=../common

# Switch to versioned dependencies for production
go mod edit -dropreplace github.com/org/common
go get github.com/org/common@v1.2.3

# Keep dependencies tidy
go mod tidy
```

**Code Organization:**
```go
// Separate interfaces from implementations
pkg/domain/contract.go          # Interface definitions
cmd/srv/domain/handler.go       # Implementation

// Use clear naming
type EchoContract interface     # Domain interface
type SimpleEchoHandler struct   # Specific implementation
```

### Python Development

**Package Management:**
```bash
# Use editable installs for development
pip install -e .

# Use regular installs for Nuitka builds
pip install .

# Keep requirements clean
pip freeze > requirements.txt
```

**Import Organization:**
```python
# Clear import structure
from lib.domain import Contract          # Domain interfaces
from srv.domain import SimpleHandler     # Implementation
from hsu_core.control import Gateway     # External dependencies
```

## Testing Best Practices

### Unit Testing

**Go Testing:**
```go
// pkg/domain/handler_test.go
func TestHandler_Operation(t *testing.T) {
    handler := &SimpleHandler{}
    result, err := handler.Operation(context.Background(), &Request{})
    assert.NoError(t, err)
    assert.NotNil(t, result)
}
```

**Python Testing:**
```python
# tests/test_handler.py
import pytest
from srv.domain import SimpleHandler

def test_handler_operation():
    handler = SimpleHandler()
    result = handler.operation(Request())
    assert result is not None
```

### Integration Testing

**Cross-Language Testing:**
```bash
# Approach 2: Test both languages
make go-test
make py-test

# Or run together
make test
```

**Multi-Repository Testing:**
```bash
# Approach 3: Test with latest common version
make update-deps
make test

# Test with local common changes
make dev-local
make test
```

## Deployment Best Practices

### Binary Compilation

**Go Compilation:**
```bash
# Standard Go build
make go-build

# Cross-platform builds
GOOS=windows GOARCH=amd64 make go-build
GOOS=linux GOARCH=amd64 make go-build
```

**Python Compilation (Nuitka):**
```bash
# Enable Nuitka in Makefile.config
NUITKA_ENABLED = true

# Build standalone binary
make py-nuitka-build

# Configure Nuitka options
NUITKA_EXTRA_MODULES = torch,transformers
NUITKA_EXTRA_PACKAGES = sklearn
```

### Dependency Management

**Version Pinning:**
```bash
# Pin major versions, allow minor updates
require github.com/org/common v1.2.3    # Exact version
require github.com/org/common v1.2       # Allow patch updates  
require github.com/org/common v1         # Allow minor updates
```

**Dependency Updates:**
```bash
# Regular update workflow
make update-deps        # Update to latest compatible
make test              # Verify compatibility
git commit -m "Update dependencies"
```

## Common Pitfalls and Solutions

### Pitfall 1: Breaking Repo-Portability

**Problem:** Adding approach-specific code that doesn't work elsewhere.

**Solution:**
```go
// ❌ Don't do this - breaks portability
#ifdef APPROACH_2
    import "../go/pkg/domain"
#else
    import "./pkg/domain"  
#endif

// ✅ Do this - works everywhere
import "github.com/org/hsu-{domain}/pkg/domain"
```

### Pitfall 2: Inconsistent Naming

**Problem:** Using different naming patterns across repositories.

**Solution:**
```bash
# ✅ Consistent naming enables automation
hsu-example1-go              # Clear approach and language
hsu-example1-py              # Same pattern
hsu-example2                 # Multi-language version
hsu-example3-common          # Shared components
hsu-example3-srv-go          # Implementation

# ❌ Inconsistent naming breaks tools  
echo-service-go          # Different pattern
hsu_echo_python          # Wrong separators
echo-multi               # Unclear purpose
```

### Pitfall 3: Editable Packages with Nuitka

**Problem:** Nuitka fails with editable Python packages.

**Solution:**
```bash
# ❌ Don't use editable packages for Nuitka
pip install -e .         # Development only
make py-nuitka-build     # Will fail

# ✅ Use regular packages for Nuitka
pip install .            # Production build
make py-nuitka-build     # Will succeed
```

### Pitfall 4: Import Inconsistency

**Problem:** Different imports across approaches break migration.

**Solution:**
```python
# ✅ Use consistent logical imports
from hsu_echo.lib.domain import Contract

# Configure pyproject.toml to map correctly:
# Approach 1: packages = ["lib", "srv"]  
# Approach 2: packages = ["python.lib", "python.srv"]
```

## Monitoring and Maintenance

### Health Checks

```bash
# Regular repository health checks
make validate-setup      # Verify configuration
make test               # Run all tests
make build              # Verify builds
make doctor             # Comprehensive check
```

### Documentation Maintenance

```bash
# Keep documentation current
make update-readme      # Regenerate README from template
make validate-docs      # Check documentation links
```

### Dependency Auditing

```bash
# Security and compatibility checks
go mod audit            # Go dependency audit
pip audit              # Python dependency audit (if available)
make check-versions     # HSU version compatibility
```

## Team Collaboration

### Repository Ownership

**Approach 1:** Single team owns entire repository
**Approach 2:** Coordinated teams with language specialization  
**Approach 3:** Independent teams with shared component coordination

### Communication Patterns

**API Changes:**
1. Propose changes in common repository
2. Get approval from all implementation teams
3. Update shared APIs first
4. Coordinate implementation updates

**Release Coordination:**
1. **Approach 1:** Simple semantic versioning
2. **Approach 2:** Coordinated releases with shared version
3. **Approach 3:** Independent releases with compatibility matrix

# Repository Portability Mechanics

This document explains the technical implementation details that enable true repo-portability in the HSU framework - the ability to move code between repository architectures without modification.

## Core Technical Innovation

### The Import Consistency Problem

Traditional multi-repository approaches force different import paths in different architectures:

```go
// ❌ Traditional approach - imports change per architecture
// Single repo:     import "./pkg/domain"
// Multi-language:  import "../go/pkg/domain"  
// Multi-repo:      import "github.com/org/common/pkg/domain"
```

This breaks repo-portability because code must be rewritten for each architecture.

### The HSU Solution: Import Path Magic

HSU achieves **identical imports across all architectures** through clever build configuration:

```go
// ✅ HSU approach - IDENTICAL imports everywhere
import "github.com/org/hsu-example2/pkg/domain"
import "github.com/org/hsu-example2/pkg/control"

// This works in ALL three approaches through build magic!
```

## Technical Implementation

### Approach 1: Single-Language Repository

**File Structure:**
```
hsu-example1-go/
├── go.mod                 # Module definition
├── pkg/domain/handler.go  # Source code
└── cmd/srv/main.go        # Application code
```

**Build Configuration (`go.mod`):**
```go
module github.com/org/hsu-example2-go

go 1.21

// Key magic: Map logical import to local directory
replace github.com/org/hsu-example2 => .

require (
    github.com/core-tools/hsu-core v1.0.0
    google.golang.org/grpc v1.59.0
)
```

**Import Usage:**
```go
// File: cmd/srv/main.go
package main

import (
    "github.com/org/hsu-example2/pkg/domain"    // Resolves to ./pkg/domain
    "github.com/org/hsu-example2/pkg/control"   // Resolves to ./pkg/control
)
```

### Approach 2: Multi-Language Repository

**File Structure:**
```
hsu-example2/
├── go/
│   ├── go.mod                 # Go module definition
│   ├── pkg/domain/handler.go  # Source code (note: /go/ prefix)
│   └── cmd/srv/main.go        # Application code
└── python/
    └── lib/domain/handler.py  # Python equivalent
```

**Build Configuration (`go/go.mod`):**
```go
module github.com/org/hsu-example2/go

go 1.21

// Key magic: Map logical import to parent directory
replace github.com/org/hsu-example2 => ..

require (
    github.com/core-tools/hsu-core v1.0.0
    google.golang.org/grpc v1.59.0  
)
```

**Import Usage (IDENTICAL to Approach 1):**
```go
// File: go/cmd/srv/main.go
package main

import (
    "github.com/org/hsu-example2/pkg/domain"    // Resolves to ../pkg/domain
    "github.com/org/hsu-example2/pkg/control"   // Resolves to ../pkg/control
)
```

### Approach 3: Multi-Repository Architecture

**File Structure:**
```
hsu-example3-srv-go/
├── go.mod                     # Module definition
├── cmd/srv/main.go            # Application code
└── cmd/srv/domain/handler.go  # Local implementation

hsu-example3-common/
├── go.mod                     # Common module
└── go/pkg/domain/contract.go  # Shared interfaces
```

**Build Configuration (`hsu-example3-srv-go/go.mod`):**
```go
module github.com/org/hsu-example2-srv-go

go 1.21

require (
    github.com/org/hsu-example2-common v1.0.0   // External dependency
    github.com/core-tools/hsu-core v1.0.0
)
```

**Import Usage:**
```go
// File: cmd/srv/main.go
package main

import (
    "github.com/org/hsu-example2-common/go/pkg/domain"   // External import
    "github.com/org/hsu-example2-srv-go/cmd/srv/domain"  // Local import
)
```

## Portability Rules

### Rule 1: Language Folder Handling

**Moving TO Multi-Language Repository (ADD language folder):**
```bash
# Source: Single-language repo
/pkg/domain/handler.go

# Target: Multi-language repo  
/go/pkg/domain/handler.go    # ADD /go/ prefix

# go.mod change:
# Before: replace github.com/org/hsu-example2 => .
# After:  replace github.com/org/hsu-example2 => .. (in /go/go.mod)
```

**Moving FROM Multi-Language Repository (STRIP language folder):**
```bash
# Source: Multi-language repo
/go/pkg/domain/handler.go

# Target: Single-language repo
/pkg/domain/handler.go       # STRIP /go/ prefix

# go.mod change:  
# Before: replace github.com/org/hsu-example2 => .. (in /go/go.mod)
# After:  replace github.com/org/hsu-example2 => . (in root go.mod)
```

**CRITICAL**: Imports remain IDENTICAL in both cases!

### Rule 2: Purpose Preservation

Logical units maintain their purpose across all architectures:

```bash
# Portable units (Go conventions)
/pkg/        → Shared libraries and business logic
/cmd/srv/    → Server executable implementations  
/cmd/cli/    → Client executable implementations
/api/proto/  → Protocol buffer definitions

# Portable units (Python conventions)  
/lib/        → Shared libraries and business logic
/srv/        → Server executable implementations
/cli/        → Client executable implementations
```

### Rule 3: Import Path Consistency

**Core Principle**: The **logical import path** stays the same, only the **resolution mechanism** changes.

```go
// Logical import (NEVER changes)
import "github.com/org/hsu-example2/pkg/domain"

// Resolution (changes per approach via build config)
// Approach 1: ./pkg/domain           (via replace . )
// Approach 2: ../pkg/domain          (via replace .. in /go/)
// Approach 3: external dependency    (via require statement)
```

## Python Portability Mechanics

### Package Configuration Changes

**Approach 1: Single-Language Python**
```toml
# pyproject.toml
[project]
name = "hsu-example1-py"
packages = ["lib", "srv", "cli"]

[project.scripts]
echo-server = "srv.run_server:main"
```

**Approach 2: Multi-Language Repository**  
```toml
# python/pyproject.toml
[project]
name = "hsu-example2"  
packages = ["python.lib", "python.srv", "python.cli"]

[project.scripts]
echo-server = "python.srv.run_server:main"
```

**Approach 3: Multi-Repository**
```toml
# pyproject.toml
[project]
name = "hsu-example3-srv-py"
dependencies = ["hsu-example3-common[python]>=1.0.0"]

[project.scripts] 
echo-server = "srv.run_server:main"
```

### Import Resolution

**Python imports adjust based on package structure:**

```python
# Approach 1: Direct imports
from lib.domain import Contract
from lib.control import Handler

# Approach 2: Namespaced imports  
from python.lib.domain import Contract
from python.lib.control import Handler

# Approach 3: External + local imports
from hsu_echo_common.python.lib.domain import Contract  # External
from srv.domain import LocalHandler                     # Local
```

## Advanced Portability Patterns

### Development vs Production Imports

**Development Mode (local replace directives):**
```go
// go.mod - development
replace github.com/org/hsu-example2-common => ../hsu-example3-common

// Enable local development with unreleased changes
go mod edit -replace github.com/org/hsu-example2-common=../hsu-example3-common
```

**Production Mode (versioned dependencies):**
```go
// go.mod - production
require github.com/org/hsu-example2-common v1.2.3

// Use tagged releases
go get github.com/org/hsu-example2-common@v1.2.3
```

### Cross-Repository Development

**Synchronized Development Workflow:**
```bash
# Working on common + implementation simultaneously
cd hsu-example3-common
git checkout feature/new-api

cd ../hsu-example3-srv-go  
go mod edit -replace github.com/org/hsu-example2-common=../hsu-example3-common
go build ./...  # Test against development version

# When ready, tag and release
cd ../hsu-example3-common
git tag v1.3.0
git push origin v1.3.0

cd ../hsu-example3-srv-go
go get github.com/org/hsu-example2-common@v1.3.0  # Switch to released version
```

### Multi-Language Coordination

**Shared API Evolution:**
```bash
# Update protocol buffers in common repo
cd hsu-example3-common
vim api/proto/echo.proto

# Regenerate all language bindings
make proto-gen

# Test both languages
cd go && go build ./...
cd ../python && pip install -e . && python -m pytest

# Coordinate release across languages
git tag v1.4.0
```

## Makefile Integration

### Build Configuration Management

**Approach 1: Simple Configuration**
```makefile
# Makefile.config
PROJECT_NAME = hsu-example1-go
PROJECT_TYPE = single-language-go
HSU_CORE_VERSION = v1.0.0

# Language detection is automatic
LANGUAGE_TYPE = go
```

**Approach 2: Multi-Language Configuration**
```makefile
# Makefile.config  
PROJECT_NAME = hsu-example2
PROJECT_TYPE = multi-language
HSU_CORE_VERSION = v1.0.0

# Both languages detected automatically
LANGUAGE_TYPE = go,python
GO_MODULE_PATH = go
PYTHON_PACKAGE_PATH = python
```

**Approach 3: Dependency Configuration**
```makefile
# Makefile.config (implementation repo)
PROJECT_NAME = hsu-example3-srv-go  
PROJECT_TYPE = implementation-go
HSU_CORE_VERSION = v1.0.0
COMMON_DEPENDENCY = github.com/core-tools/hsu-example3-common

# Dependency management integrated
LANGUAGE_TYPE = go
```

### Automatic Build Adaptation

The HSU Make System automatically adapts based on detected repository structure:

```makefile
# Single-language: Direct commands
make build → go build ./cmd/...

# Multi-language: Language-prefixed commands  
make go-build → cd go && go build ./cmd/...
make py-build → cd python && pip install -e .

# Multi-repo: Dependency-aware commands
make build → go get -u github.com/org/common && go build ./cmd/...
```

## Troubleshooting Portability

### Common Issues

**Issue 1: Import Path Mismatch**
```bash
# Error: package not found
go build: cannot find package "github.com/org/hsu-example2/pkg/domain"

# Solution: Check replace directive
grep "replace.*hsu-example2" go.mod
# Should show: replace github.com/org/hsu-example2 => .
```

**Issue 2: Language Folder Confusion**  
```bash
# Error: Moving code between approaches breaks builds
# Problem: Forgot to add/strip language folder

# Solution: Follow Rule 1 exactly
# To multi-language: ADD language folder (/go/, /python/)
# From multi-language: STRIP language folder
```

**Issue 3: Python Package Structure**
```bash
# Error: Module not found after approach change
# Problem: pyproject.toml packages configuration out of sync

# Solution: Update packages list to match folder structure
# Approach 1: packages = ["lib", "srv"]  
# Approach 2: packages = ["python.lib", "python.srv"]
```

### Validation Tools

**Import Validation:**
```bash
# Verify all imports resolve correctly
go mod tidy && go build ./...

# Check for missing dependencies
go mod graph | grep hsu-example2
```

**Cross-Architecture Testing:**
```bash
# Test same code in different approaches
hsu-validate-portable ./pkg/ ./cmd/srv/ ./cmd/cli/

# Verify imports work across approaches
hsu-test-imports --approach=1,2,3
```

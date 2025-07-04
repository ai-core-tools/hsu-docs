# Repository Migration Patterns

This document provides practical guidance for migrating between the three HSU repository approaches, with real examples and step-by-step instructions.

## Migration Overview

The HSU framework supports **seamless migration** between repository approaches as your team and domain evolve:

```
Approach 1 ←→ Approach 2 ←→ Approach 3
   ↑                            ↓
   └────── Direct Migration ─────┘
```

**Key Insight:** All migrations preserve **identical import statements** - only folder structure and build configuration change.

## Migration Strategies

### Progressive Evolution (Recommended)
Start simple and scale gradually:
```
Start:  Approach 1 (hsu-example1-go)
  ↓     Add Python support  
Grow:   Approach 2 (multi-language hsu-example2)
  ↓     Extract shared components
Scale:  Approach 3 (hsu-example3-common + implementations)
```

### Language-First Consolidation
Merge separate language implementations:
```
Start:  Multiple Approach 1 (hsu-example1-go + hsu-example1-py)
  ↓     Consolidate for coordination
Unify:  Approach 2 (single hsu-example2 repo)
  ↓     Scale teams independently  
Scale:  Approach 3 (separate repositories)
```

### Direct Scaling
Jump directly from simple to complex:
```
Start:  Approach 1 (hsu-example1-go)
  ↓     Team growth requires independence
Scale:  Approach 3 (hsu-example3-common + hsu-example3-srv-go)
```

## Migration 1→2: Adding Multi-Language Support

### Scenario: Go → Multi-Language

**Starting Point (Approach 1):**
```
hsu-example1-go/
├── Makefile
├── go.mod
├── api/proto/
├── pkg/domain/
├── cmd/srv/
└── cmd/cli/
```

**Migration Steps:**

**1. Create Language Structure:**
```bash
# Create language folders
mkdir go python

# Move existing Go code
mv pkg cmd go/
mv go.mod go.sum go/

# Move shared API  
# api/ stays at root for multi-language access
```

**2. Update Go Module Configuration:**
```go
// Before: go.mod at root
module github.com/org/hsu-example1-go
replace github.com/org/hsu-example2 => .

// After: go/go.mod 
module github.com/org/hsu-example2/go
replace github.com/org/hsu-example2 => ..
```

**3. Add Python Implementation:**
```bash
cd python
# Create Python structure
mkdir lib srv cli
mkdir lib/domain lib/control lib/generated

# Create pyproject.toml
cat > pyproject.toml << EOF
[project]
name = "hsu-example2"
packages = ["python.lib", "python.srv", "python.cli"]
EOF
```

**4. Update Build Configuration:**
```makefile
# Before: Makefile.config  
PROJECT_TYPE = single-language-go
HSU_APPROACH = 1

# After: Makefile.config
PROJECT_TYPE = multi-language
HSU_APPROACH = 2
GO_MODULE_PATH = go
PYTHON_PACKAGE_PATH = python
```

**Final Result (Approach 2):**
```
hsu-example2/
├── Makefile
├── api/proto/              # Shared APIs
├── go/                     # Go language boundary
│   ├── go.mod              # Updated replace directive
│   ├── pkg/domain/         # MOVED from root
│   ├── cmd/srv/            # MOVED from root
│   └── cmd/cli/            # MOVED from root
└── python/                 # New Python implementation
    ├── pyproject.toml
    ├── lib/domain/         # Python equivalent
    ├── srv/                # Python server
    └── cli/                # Python client
```

**Critical Verification:**
```go
// Import statements remain IDENTICAL!
// Before (Approach 1): cmd/srv/main.go
import "github.com/org/hsu-example2/pkg/domain"

// After (Approach 2): go/cmd/srv/main.go  
import "github.com/org/hsu-example2/pkg/domain"  // SAME!
```

### Testing Migration

```bash
# Verify Go code still works
cd go
go mod tidy
go build ./cmd/srv/

# Add Python implementation
cd ../python
pip install -e .
python -m srv.run_server

# Test cross-language coordination
make proto-gen              # Generate for both languages
make go-run-srv &            # Start Go server
make py-run-cli              # Test with Python client
```

## Migration 2→3: Extracting Shared Components

### Scenario: Multi-Language → Multi-Repository

**Starting Point (Approach 2):**
```
hsu-example2/
├── api/proto/
├── go/pkg/domain/
├── go/cmd/srv/
├── python/lib/domain/
└── python/srv/
```

**Migration Steps:**

**1. Create Common Repository:**
```bash
# Create shared components repository
mkdir ../hsu-example3-common
cd ../hsu-example3-common

# Extract shared APIs
mv ../hsu-example2/api/ .

# Extract shared Go libraries
mkdir go
mv ../hsu-example2/go/pkg/ go/
mv ../hsu-example2/go/go.mod go/

# Extract shared Python libraries  
mkdir python
mv ../hsu-example2/python/lib/ python/
cp ../hsu-example2/python/pyproject.toml python/

# Set up common repository build
cp ../hsu-example2/make/ .
```

**2. Create Implementation Repositories:**
```bash
# Create Go server implementation
mkdir ../hsu-example3-srv-go
cd ../hsu-example3-srv-go
mv ../hsu-example2/go/cmd/ .
mkdir cmd/srv/domain        # Local implementation folder

# Create Python server implementation
mkdir ../hsu-example3-srv-py
cd ../hsu-example3-srv-py  
mv ../hsu-example2/python/srv/ .
mkdir srv/domain           # Local implementation folder
```

**3. Update Dependencies:**

**Go Implementation:**
```go
// hsu-example3-srv-go/go.mod
module github.com/org/hsu-example3-srv-go

require (
    github.com/org/hsu-example3-common v1.0.0    // External dependency
    github.com/core-tools/hsu-core v1.0.0
)
```

**Python Implementation:**
```toml
# hsu-example3-srv-py/pyproject.toml
[project]
name = "hsu-example3-srv-py"
dependencies = [
    "hsu-example3-common[python]>=1.0.0"        // External dependency
]
```

**4. Update Import Patterns:**

**Before (Approach 2):**
```go
// Internal imports within multi-language repo
import "github.com/org/hsu-example2/pkg/domain"
```

**After (Approach 3):**
```go  
// External dependency on common repo
import "github.com/org/hsu-example3-common/go/pkg/domain"
```

**Final Result (Approach 3):**
```
hsu-example3-common/               # Shared components
├── api/proto/
├── go/pkg/domain/
└── python/lib/domain/

hsu-example3-srv-go/               # Go implementation  
├── go.mod                     # Depends on common
├── cmd/srv/
└── cmd/srv/domain/            # Local implementation

hsu-example3-srv-py/               # Python implementation
├── pyproject.toml             # Depends on common
├── srv/
└── srv/domain/                # Local implementation
```

## Migration 1→3: Direct Scaling

### Scenario: Single-Language → Multi-Repository

**Starting Point (Approach 1):**
```
hsu-example1-go/
├── pkg/domain/contract.go
├── pkg/control/handler.go
├── cmd/srv/domain/simple_handler.go
└── cmd/srv/main.go
```

**Migration Steps:**

**1. Separate Shared vs Implementation Code:**
```bash
# Identify what should be shared
shared_components=(
    "api/"
    "pkg/domain/"           # Interfaces
    "pkg/control/"          # gRPC adapters
    "pkg/generated/"        # Generated code
)

implementation_components=(
    "cmd/srv/domain/"       # Business logic
    "cmd/srv/main.go"       # Entry point
)
```

**2. Create Common Repository:**
```bash
mkdir ../hsu-example3-common
cd ../hsu-example3-common

# Extract shared components
mv ../hsu-example1-go/api/ .
mkdir go
mv ../hsu-example1-go/pkg/ go/

# Create go.mod for common
cat > go/go.mod << EOF
module github.com/org/hsu-example3-common/go
go 1.21
EOF
```

**3. Create Implementation Repository:**
```bash
mkdir ../hsu-example3-srv-go
cd ../hsu-example3-srv-go

# Move implementation code
mv ../hsu-example1-go/cmd/ .

# Create new go.mod with dependency
cat > go.mod << EOF
module github.com/org/hsu-example3-srv-go
go 1.21

require github.com/org/hsu-example3-common v1.0.0
EOF
```

**4. Update Imports:**
```go
// Before (Approach 1)
import "github.com/org/hsu-example1-go/pkg/domain"

// After (Approach 3)  
import "github.com/org/hsu-example3-common/go/pkg/domain"
```

## Migration 3→2: Consolidating Repositories

### Scenario: Multi-Repository → Multi-Language

Sometimes teams want to consolidate for better coordination:

**Starting Point (Approach 3):**
```
hsu-example3-common/go/pkg/domain/
hsu-example3-srv-go/cmd/srv/
hsu-example3-srv-py/srv/
```

**Migration Steps:**

**1. Create Unified Repository:**
```bash
mkdir hsu-example2-unified
cd hsu-example2-unified

# Merge common components
mv ../hsu-example3-common/api/ .
mkdir go python
mv ../hsu-example3-common/go/ .

# Merge implementations
mv ../hsu-example3-srv-go/cmd/ go/
mv ../hsu-example3-srv-py/srv/ python/
```

**2. Update Build Configuration:**
```go
// go/go.mod
module github.com/org/hsu-example2/go
replace github.com/org/hsu-example2 => ..
```

**3. Update Imports:**
```go
// Before (external dependency)
import "github.com/org/hsu-example3-common/go/pkg/domain"

// After (internal import)  
import "github.com/org/hsu-example2/pkg/domain"
```

## Migration Tools and Automation

### Automated Migration Scripts

**Go Import Rewriting:**
```bash
#!/bin/bash
# migrate-imports.sh

OLD_IMPORT="github.com/org/hsu-example1-go"
NEW_IMPORT="github.com/org/hsu-example2"

find . -name "*.go" -exec sed -i "s|$OLD_IMPORT|$NEW_IMPORT|g" {} \;
go mod edit -replace $NEW_IMPORT=.
go mod tidy
```

**Folder Structure Migration:**
```bash
#!/bin/bash  
# migrate-to-approach2.sh

# Create language boundaries
mkdir go python

# Move Go code
mv pkg cmd go/
mv go.mod go.sum go/

# Update go.mod
cd go
go mod edit -replace github.com/org/hsu-example2=..
```

### Validation Tools

**Cross-Approach Testing:**
```bash
# Test imports work in all approaches
validate-portability() {
    local folder=$1
    
    # Test Approach 1 (current)
    go build ./...
    
    # Test Approach 2 (simulated)  
    mkdir -p test-go
    cp -r * test-go/
    cd test-go
    go mod edit -replace github.com/org/hsu-example2=..
    go build ./...
    cd ..
    rm -rf test-go
}
```

## Common Migration Challenges

### Challenge 1: Import Path Updates

**Problem:** Forgetting to update all import references.

**Solution:**
```bash
# Systematic import updates
grep -r "old-import-path" .
sed -i 's|old-import-path|new-import-path|g' **/*.go

# Verify all imports resolve
go mod tidy
go build ./...
```

### Challenge 2: Circular Dependencies

**Problem:** Approach 3 common repo depends on implementation.

**Solution:**
```bash
# ✅ Correct: Common defines interfaces, implementations depend on common
hsu-example3-common/go/pkg/domain/contract.go     # Interface
hsu-example3-srv-go depends on hsu-example3-common    # Implementation uses interface

# ❌ Wrong: Common depends on implementation  
hsu-example3-common depends on hsu-example3-srv-go    # Creates circular dependency
```

### Challenge 3: Version Synchronization

**Problem:** Approach 3 version mismatches between common and implementations.

**Solution:**
```bash
# Use semantic versioning
cd hsu-example3-common
git tag v1.2.0

cd ../hsu-example3-srv-go
go get github.com/org/hsu-example3-common@v1.2.0

# Or use replace directives for development
go mod edit -replace github.com/org/hsu-example3-common=../hsu-example3-common
```

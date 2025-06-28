# HSU Repository Portability Framework

**Date**: December 28, 2024  
**Status**: Framework Definition  
**Context**: Evolved architecture framework based on successful hsu-example1-go implementation

## Executive Summary

This document presents the **HSU Repository Portability Framework** - a mature, practical approach to organizing domain-centric code that achieves true "repo-portability" while working with existing language tooling. This framework emerged from successful implementation and analysis of the unified repository concept.

## Key Innovation: Universal Repo-Portability

**Core Insight**: Repo-portability is achieved through **logical purpose separation** and **portable import schemes**, not specific folder structures. This enables seamless migration between repository architectures without code changes.

## The Three-Approach Framework

### Approach 1: Single-Repository + Single-Language
*"Focused Domain Implementation"*

#### Structure
```
hsu-{domain}-{lang}/
├── Makefile                 # Build automation
├── go.mod                   # Language-specific config  
├── api/                     # Mandatory - API definitions
│   └── proto/
├── pkg/                     # Mandatory - Common/shared code (Go convention)
│   ├── domain/
│   ├── control/
│   └── generated/
├── cmd/                     # Mandatory - Executable commands (Go convention)
│   ├── srv/                 # Server implementations
│   └── cli/                 # Client implementations (optional)
└── README.md
```

#### Characteristics
- ✅ **Single language focus** - leverages language-specific tooling fully
- ✅ **Simple structure** - familiar to language communities  
- ✅ **Full repo-portability** - `/pkg`, `/cmd/srv`, `/cmd/cli` folders are portable units
- ✅ **Proven approach** - validated by hsu-example1-go success

#### Examples

**Single-Language (Approach 1)**: `hsu-example1-go`
```
hsu-example1-go/
├── Makefile
├── go.mod                   # replace github.com/org/hsu-echo => .
├── api/proto/               # API definitions
├── pkg/                     # Portable shared code (Go convention)
└── cmd/                     # Portable executable code (Go convention)
    ├── srv/
    └── cli/
└── README.md
```

**Multi-Language (Approach 2)**: `hsu-example4`  
```
hsu-example4/
├── Makefile
├── api/proto/               # API definitions
├── go/
│   ├── go.mod               # replace github.com/org/hsu-echo => .
│   ├── pkg/                 # Portable shared code (Go convention)
│   └── cmd/                 # Portable executable code (Go convention)
│       ├── srv/
│       └── cli/
├── python/
│   ├── pyproject.toml
│   └── lib/ srv/ cli/       # Python structure
└── README.md
```

### Approach 2: Single-Repository + Multi-Language  
*"Unified Domain Implementation"*

#### Structure
```
hsu-{domain}/
├── Makefile                 # Cross-language build automation
├── api/                     # Mandatory - Language-independent APIs
│   └── proto/
├── go/                      # Mandatory - Go language boundary
│   ├── go.mod
│   ├── pkg/                 # Repo-portable Go shared code
│   └── cmd/                 # Repo-portable Go executables
│       ├── srv/
│       └── cli/
├── python/                  # Mandatory - Python language boundary  
│   ├── pyproject.toml
│   ├── lib/                 # Repo-portable Python shared code
│   ├── srv/                 # Repo-portable Python servers
│   └── cli/                 # Repo-portable Python clients
└── README.md
```

#### Characteristics
- ✅ **Multi-language coordination** - shared APIs, synchronized releases
- ✅ **Language tool compatibility** - each `/lang/` follows conventions
- ✅ **Full repo-portability** - `/go/pkg`, `/python/srv` etc. are portable
- ✅ **Clear boundaries** - language isolation prevents conflicts

### Approach 3: Multi-Repository Architecture
*"Scalable Domain Ecosystem"*

#### Repository Types

**Common Repository** - Shared domain assets:
```
hsu-{domain}-common/
├── Makefile
├── api/                     # Shared API definitions
├── go/
│   ├── go.mod
│   └── pkg/                 # Repo-portable shared Go code
├── python/
│   ├── pyproject.toml  
│   └── lib/                 # Repo-portable shared Python code
└── README.md
```

**Implementation Repositories** - Specific implementations:
```
hsu-{domain}-srv-{lang}/
├── Makefile
├── {lang}.mod               # go.mod, pyproject.toml, etc.
├── srv/                     # Repo-portable server code
└── README.md
```

#### Characteristics
- ✅ **Maximum flexibility** - independent scaling, deployment, teams
- ✅ **Shared consistency** - common APIs and libraries
- ✅ **Full repo-portability** - any folder can move between repos
- ✅ **Multiple common repos possible** - domain clustering flexibility

## Repo-Portability Mechanics

### Core Requirements

1. **Domain Cohesion**: All repositories in the set relate to the same domain
2. **Portable Import Schemes**: 
   - **Relative paths**: `./lib/domain` (direct portability)
   - **Common prefixes**: `github.com/org/hsu-{domain}` (with replace directives)
3. **Purpose Separation**: Logical splits (`pkg`, `cmd/cli`, `cmd/srv`) create portable units
4. **Standard Interfaces**: Consistent contracts enable substitution

### Portability Mapping Rules

#### **Rule 1: Language Folder Handling**
```bash
# Target: Multi-language repo
Source: /pkg/domain/handler.go  
Target: /go/pkg/domain/handler.go    # ADD language folder

# Target: Single-language repo  
Source: /go/pkg/domain/handler.go
Target: /pkg/domain/handler.go       # STRIP language folder

# CRITICAL: Imports remain identical in both cases!
# import "github.com/org/hsu-domain/pkg/domain"
```

#### **Rule 2: Import Path Consistency** 
```go
// CRITICAL: Imports must be IDENTICAL for true portability
// Both single-language and multi-language repos use:
import "github.com/org/hsu-domain/pkg/domain"

// The magic happens in go.mod replace directives:
// Multi-language: replace github.com/org/hsu-domain => . (in /go/go.mod)
// Single-language: replace github.com/org/hsu-domain => . (in root go.mod)
```

#### **Rule 3: Build Configuration**
```bash
# Multi-language: Build configs per language
/go/go.mod, /python/pyproject.toml

# Single-language: Build config at root
/go.mod, /pyproject.toml
```

## Comparative Analysis

| Aspect | Approach 1 | Approach 2 | Approach 3 |
|--------|------------|------------|------------|
| **Tooling Compatibility** | ✅ Excellent | ✅ Excellent | ✅ Excellent |
| **Repo-Portability** | ✅ Full | ✅ Full | ✅ Full |
| **Multi-Language Coordination** | ⚠️ Manual | ✅ Built-in | ✅ Flexible |
| **Team Scaling** | ⚠️ Limited | ⚠️ Moderate | ✅ Excellent |
| **Deployment Flexibility** | ⚠️ Monolithic | ⚠️ Coupled | ✅ Independent |
| **Complexity** | ✅ Simple | ⚠️ Moderate | ❌ Complex |
| **Getting Started** | ✅ Easy | ⚠️ Moderate | ❌ Hard |

## Implementation Patterns

### Pattern 1: Progressive Evolution
```
Start: Approach 1 (hsu-echo-go)
Grow:  Approach 2 (add /python/, keep /go/)  
Scale: Approach 3 (extract to multiple repos)
```

### Pattern 2: Language-First
```
Start: Multiple Approach 1 repos (hsu-echo-go, hsu-echo-py)
Unify: Approach 2 (merge to single multi-language repo)
Scale: Approach 3 (extract shared /api/ and /*/pkglib/ or /*/lib/)
```

### Pattern 3: Domain-First  
```
Start: Approach 2 (unified from beginning)
Split: Approach 3 (extract as domain grows)
```

## Technical Implementation

### Go-Specific Patterns

#### **Single-Language (Approach 1)**
```go
module github.com/org/hsu-echo-go

replace github.com/org/hsu-echo => .

// Imports - identical to multi-language case
import "github.com/org/hsu-echo/pkg/domain"
```

#### **Multi-Language (Approach 2)**  
```go
module github.com/org/hsu-echo/go

replace github.com/org/hsu-echo => .

// SAME imports as single-language - this is the key!
import "github.com/core-tools/hsu-echo/pkg/control"
import "github.com/core-tools/hsu-echo/pkg/domain" 
```

#### **Multi-Repo (Approach 3)**
```go
module github.com/org/hsu-echo-srv-go

require github.com/org/hsu-echo-common v1.0.0

import "github.com/org/hsu-echo-common/pkg/domain"
```

### Python-Specific Patterns

#### **Single-Language (Approach 1)**
```python
# pyproject.toml
[project]
name = "hsu-echo-py"
packages = ["lib", "srv", "cli"]

# Imports
from lib.domain import Handler
from srv.echo import EchoServer
```

#### **Multi-Language (Approach 2)**
```python
# pyproject.toml at root
[project]
name = "hsu-echo"
packages = ["python.lib", "python.srv", "python.cli"]

# Imports  
from python.lib.domain import Handler
from python.srv.echo import EchoServer
```

#### **Multi-Repo (Approach 3)**
```python
# pyproject.toml
[project]
name = "hsu-echo-srv-py"
dependencies = ["hsu-echo-common[python]"]

# Imports
from hsu_echo_common.python.lib.domain import Handler
```

## Migration Scenarios

### Scenario A: Scale Single-Language Repo
```bash
# Extract server component from hsu-echo-go
Source: hsu-echo-go/srv/echoserver/
Target: hsu-echo-srv-go/srv/echoserver/
```

### Scenario B: Add Language to Domain
```bash
# Add Python to existing Go repo
hsu-echo-go/ → hsu-echo/
├── go/                    # Move existing Go code
│   ├── go.mod            # Relocate
│   ├── pkg/ ← cmd/srv/ ← cmd/cli/ # Move folders  
└── python/               # Add new language
    ├── pyproject.toml
    └── lib/ srv/ cli/    # New implementations
```

### Scenario C: Consolidate Multi-Language Repos
```bash
# Merge separate language repos
hsu-echo-go/ + hsu-echo-py/ → hsu-echo/
├── go/pkg/ cmd/srv/ cmd/cli/ # From hsu-echo-go
└── python/lib/ srv/ cli/ # From hsu-echo-py
```

## Tooling and Automation

### Makefile Patterns
```makefile
# Approach 1: Single-language
build: build-srv build-cli
run-srv: build-srv && ./srv/echoserver/echoserver

# Approach 2: Multi-language  
build: build-go build-python
build-go: cd go && make build
build-python: cd python && make build

# Approach 3: Multi-repo
build: update-deps build-local
update-deps: git submodule update --remote
```

### Migration Tools
```bash
# Port folder between repos
hsu-port ./srv/ ../hsu-echo-srv-go/ --strip-lang-folder

# Update imports automatically  
hsu-rewrite-imports --from="./lib" --to="github.com/org/common"

# Validate portability
hsu-validate-portable ./lib/ ./srv/ ./cli/
```

## Success Metrics

### Development Experience
- ✅ **Build time**: Standard language tools work normally
- ✅ **IDE support**: Full language server functionality  
- ✅ **Learning curve**: Familiar patterns within language boundaries
- ✅ **Migration ease**: Automated tooling for repo restructuring

### Business Impact  
- ✅ **Team scaling**: Independent repository ownership
- ✅ **Deployment flexibility**: Mix and match implementations
- ✅ **Technology evolution**: Add languages without disruption
- ✅ **Dependency management**: Clear separation of concerns

## Correction to Previous Assessment

### Previous Error Acknowledged
The original `REPO_ARCHITECTURE_ASSESSMENT.md` incorrectly stated that "Option B: Monorepo with Language Boundaries" doesn't achieve repo-portability. **This was wrong**.

### Corrected Understanding  
**Repo-portability is achieved through logical purpose separation, not folder structure.** Both these approaches achieve full repo-portability:

```bash
# Original proposal: Purpose-first
/gosrv/ /gocli/ /golib/         # Portable units

# Option B: Language-first  
/go/srv/ /go/cli/ /go/lib/      # Equally portable units
```

The key insight: **portability comes from having clean boundaries and consistent import schemes**, not from the specific folder hierarchy.

### Breakthrough: Import Consistency Solution

The **hsu-example4** implementation proved that true repo-portability requires **identical imports** across all repository architectures. The solution uses clever go.mod replace directives:

```go
// Single-language repo: /pkg/domain/handler.go
module github.com/org/hsu-echo-go
replace github.com/org/hsu-echo => .

// Multi-language repo: /go/pkg/domain/handler.go  
module github.com/org/hsu-echo/go
replace github.com/org/hsu-echo => .

// IDENTICAL imports in both cases:
import "github.com/org/hsu-echo/pkg/domain"
```

This makes code truly portable - no import changes needed when moving between repository architectures.

## Recommendations

### For New Domains
**Start with Approach 1** (Single-repo + Single-language):
- Fastest to implement
- Best tool compatibility  
- Easiest to understand
- Clear migration path forward

### For Growing Domains
**Evolve to Approach 2** (Multi-language):
- Add language coordination
- Maintain tool compatibility
- Enable cross-language development

### For Mature Domains  
**Scale to Approach 3** (Multi-repo):
- Independent team ownership
- Flexible deployment options
- Maximum organizational scaling

### Universal Principles
1. **Always include `/api/` folder** - API-first design
2. **Maintain purpose separation** - `/pkg/`, `/cmd/srv/`, `/cmd/cli/` boundaries (Go conventions)
3. **Use consistent naming** - `hsu-{domain}-{type}-{lang}` pattern  
4. **Identical imports across architectures** - Critical for true repo-portability
5. **Automate migrations** - Tooling for repo restructuring
6. **Document patterns** - Clear examples for each approach

## Conclusion

The HSU Repository Portability Framework provides a mature, practical solution for domain-centric code organization. By recognizing that **repo-portability is independent of specific folder structures**, we achieve:

✅ **Full compatibility** with existing language tooling  
✅ **True portability** between repository architectures  
✅ **Flexible scaling** from simple to complex organizations  
✅ **Clear migration paths** between approaches  

This framework has been **validated in practice** with the successful hsu-example1-go implementation, proving that innovative repository organization can work within existing ecosystem constraints.

The key breakthrough: **You don't need to break language conventions to achieve repo-portability - you just need consistent logical boundaries and portable import schemes.** 
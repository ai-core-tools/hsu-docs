# Three Repository Approaches Comparison

This document provides a comprehensive comparison of the three HSU repository approaches, helping you choose the right architecture for your domain and team.

## Approach Overview

The HSU framework provides **three distinct approaches** that can be mixed, matched, and evolved progressively:

| Approach | Name | Complexity | Team Size | Best For |
|----------|------|------------|-----------|----------|
| **1** | Single-Repository + Single-Language | ✅ Simple | 1-3 developers | New domains, focused teams |
| **2** | Single-Repository + Multi-Language | ⚠️ Moderate | 3-8 developers | Coordinated development |
| **3** | Multi-Repository Architecture | ❌ Complex | 8+ developers | Independent scaling |

## Approach 1: Single-Repository + Single-Language

*"Focused Domain Implementation"*

### Structure

```
hsu-{domain}-{lang}/
├── Makefile                    # HSU Universal Makefile integration
├── Makefile.config             # Project-specific configuration
├── go.mod                      # Language-specific config (Go example)
├── api/                        # 🔵 Mandatory - API definitions
│   └── proto/
│       ├── {domain}service.proto
│       ├── generate-go.sh
│       └── generate-go.bat
├── pkg/                        # 🔵 Mandatory - Shared code (Go convention)
│   ├── domain/
│   │   └── contract.go
│   ├── control/
│   │   ├── handler.go
│   │   └── gateway.go
│   ├── generated/
│   │   └── api/proto/
│   └── logging/
│       └── logging.go
├── cmd/                        # 🔵 Mandatory - Executables (Go convention)
│   ├── srv/                    # Server implementations
│   │   └── {domain}grpcsrv/
│   │       └── main.go
│   └── cli/                    # Client implementations (optional)
│       └── {domain}grpccli/
│           └── main.go
├── make/ (git submodule)       # HSU makefile system from https://github.com/Core-Tools/make
└── README.md
```

**Python Equivalent:**
```
hsu-{domain}-py/
├── Makefile                    # HSU Universal Makefile integration
├── Makefile.config             # Project-specific configuration
├── pyproject.toml              # Python package configuration
├── api/                        # 🔵 Mandatory - API definitions
│   └── proto/
├── lib/                        # 🔵 Mandatory - Shared code (Python convention)
│   ├── domain/
│   ├── control/
│   └── generated/
├── srv/                        # 🔵 Mandatory - Server implementations
│   └── run_server.py
├── cli/                        # Client implementations (optional)
│   └── run_client.py
├── make/ (git submodule)       # HSU makefile system from https://github.com/Core-Tools/make
└── README.md
```

### Real Examples
- **hsu-example1-go**: Go implementation with proven build system
- **hsu-example1-py**: Python with modern packaging and Nuitka compilation

### Characteristics
- ✅ **Single language focus** - leverages language-specific tooling fully
- ✅ **Simple structure** - familiar to language communities
- ✅ **Full repo-portability** - `/pkg`, `/cmd/srv`, `/cmd/cli` folders are portable units
- ✅ **Proven approach** - validated by successful implementations
- ✅ **Fast development** - minimal coordination overhead

### When to Choose
- **New domains** starting development
- **Single-language teams** with deep expertise  
- **Rapid prototyping** requirements
- **Simple deployment** scenarios

## Approach 2: Single-Repository + Multi-Language

*"Unified Domain Implementation"*

### Structure

```
hsu-{domain}/
├── Makefile                    # Cross-language build automation
├── Makefile.config             # Multi-language configuration
├── api/                        # 🔵 Mandatory - Language-independent APIs
│   └── proto/
│       ├── {domain}service.proto
│       ├── generate-go.sh
│       ├── generate-go.bat
│       ├── generate-py.sh
│       └── generate-py.bat
├── go/                         # 🔵 Mandatory - Go language boundary
│   ├── go.mod
│   ├── pkg/                    # Repo-portable Go shared code
│   │   ├── domain/
│   │   ├── control/
│   │   ├── generated/api/proto/
│   │   └── logging/
│   └── cmd/                    # Repo-portable Go executables
│       ├── srv/{domain}grpcsrv/
│       └── cli/{domain}grpccli/
├── python/                     # 🔵 Mandatory - Python language boundary
│   ├── pyproject.toml
│   ├── lib/                    # Repo-portable Python shared code
│   │   ├── domain/
│   │   ├── control/
│   │   └── generated/api/proto/
│   ├── srv/                    # Repo-portable Python servers
│   │   └── run_server.py
│   └── cli/                    # Repo-portable Python clients
│       └── run_client.py
├── make/ (git submodule)       # HSU makefile system from https://github.com/Core-Tools/make
└── README.md
```

### Real Examples  
- **hsu-example2**: Coordinated Go/Python development with shared APIs

### Characteristics
- ✅ **Multi-language coordination** - shared APIs, synchronized releases
- ✅ **Language tool compatibility** - each `/lang/` follows conventions  
- ✅ **Full repo-portability** - `/go/pkg`, `/python/srv` etc. are portable
- ✅ **Clear boundaries** - language isolation prevents conflicts
- ⚠️ **Moderate complexity** - requires cross-language coordination

### When to Choose
- **Established domains** needing multiple languages
- **Coordinated teams** working on shared functionality
- **Synchronized releases** requirements
- **Shared API evolution** needs

## Approach 3: Multi-Repository Architecture

*"Scalable Domain Ecosystem"*

### Repository Types

#### Common Repository
*Shared domain assets*

```
hsu-{domain}-common/
├── Makefile                    # Cross-language shared components
├── Makefile.config             # Common configuration
├── api/                        # 🔵 Mandatory - Shared API definitions
│   └── proto/
│       ├── {domain}service.proto
│       ├── generate-go.sh
│       ├── generate-go.bat
│       ├── generate-py.sh
│       └── generate-py.bat
├── go/                         # Go shared components
│   ├── go.mod
│   ├── pkg/                    # Repo-portable shared Go code
│   │   ├── domain/
│   │   │   └── contract.go
│   │   ├── control/
│   │   │   ├── handler.go
│   │   │   └── main_{domain}.go
│   │   ├── generated/api/proto/
│   │   └── logging/
│   └── cmd/                    # Shared Go executables
│       └── cli/{domain}grpccli/ # Test clients
├── python/                     # Python shared components
│   ├── pyproject.toml
│   ├── lib/                    # Repo-portable shared Python code
│   │   ├── domain/
│   │   │   └── contract.py
│   │   ├── control/
│   │   │   ├── handler.py
│   │   │   └── serve_{domain}.py
│   │   └── generated/api/proto/
│   └── cli/                    # Shared Python executables
│       └── run_client.py       # Test clients
├── make/ (git submodule)       # HSU makefile system from https://github.com/Core-Tools/make
└── README.md
```

#### Implementation Repositories
*Specific server implementations*

**Go Server Implementation:**
```
hsu-{domain}-{variant}-srv-go/
├── Makefile                    # Build automation
├── Makefile.config             # Server-specific configuration
├── go.mod                      # Dependencies on common repo
├── cmd/                        # 🔵 Mandatory - Server executables
│   └── srv/
│       ├── domain/
│       │   └── {variant}_handler.go  # Business logic
│       └── {domain}grpcsrv/
│           └── main.go              # Entry point
├── make/ (git submodule)       # HSU makefile system from https://github.com/Core-Tools/make
└── README.md
```

**Python Server Implementation:**
```
hsu-{domain}-{variant}-srv-py/
├── Makefile                    # Build automation
├── Makefile.config             # Server-specific configuration
├── pyproject.toml              # Dependencies on common repo
├── srv/                        # 🔵 Mandatory - Server implementation
│   ├── domain/
│   │   └── {variant}_handler.py     # Business logic
│   └── run_server.py                # Entry point
├── make/ (git submodule)       # HSU makefile system from https://github.com/Core-Tools/make
└── README.md
```

### Real Examples
- **hsu-example3-common**: Shared components and APIs
- **hsu-example3-srv-go**: Independent Go server implementation
- **hsu-example3-srv-py**: Independent Python server implementation

### Characteristics
- ✅ **Maximum flexibility** - independent scaling, deployment, teams
- ✅ **Shared consistency** - common APIs and libraries
- ✅ **Full repo-portability** - any folder can move between repos
- ✅ **Multiple common repos possible** - domain clustering flexibility
- ❌ **High complexity** - requires sophisticated coordination

### When to Choose
- **Large teams** with independent responsibilities
- **Independent deployment** requirements
- **Different release cycles** for components
- **Heavy dependencies** need isolation

## Detailed Comparison Matrix

### Technical Capabilities

| Aspect | Approach 1 | Approach 2 | Approach 3 |
|--------|------------|------------|------------|
| **Language Tool Compatibility** | ✅ Excellent | ✅ Excellent | ✅ Excellent |
| **Repo-Portability** | ✅ Full | ✅ Full | ✅ Full |
| **Multi-Language Coordination** | ⚠️ Manual | ✅ Built-in | ✅ Flexible |
| **API Versioning** | ⚠️ Manual | ⚠️ Coordinated | ✅ Independent |
| **Dependency Isolation** | ❌ None | ⚠️ Language-level | ✅ Repository-level |
| **Build Simplicity** | ✅ Simple | ⚠️ Moderate | ❌ Complex |

### Team & Process

| Aspect | Approach 1 | Approach 2 | Approach 3 |
|--------|------------|------------|------------|
| **Team Scaling** | ⚠️ Limited (1-3) | ⚠️ Moderate (3-8) | ✅ Excellent (8+) |
| **Deployment Flexibility** | ⚠️ Monolithic | ⚠️ Coupled | ✅ Independent |
| **Release Coordination** | ✅ Simple | ⚠️ Coordinated | ❌ Complex |
| **Getting Started** | ✅ Easy | ⚠️ Moderate | ❌ Hard |
| **Code Sharing** | ❌ Manual | ✅ Built-in | ✅ Versioned |

### Operational

| Aspect | Approach 1 | Approach 2 | Approach 3 |
|--------|------------|------------|------------|
| **Repository Count** | 1 per language | 1 per domain | 3+ per domain |
| **Build Configuration** | 1 file | 1 file | Multiple files |
| **Dependency Updates** | Direct | Coordinated | Independent |
| **Testing Complexity** | ✅ Simple | ⚠️ Moderate | ❌ Complex |
| **Documentation Maintenance** | ✅ Simple | ⚠️ Moderate | ❌ Complex |

## Decision Framework

### Choose Approach 1 When:
- ✅ **New domain** with undefined requirements
- ✅ **Single language** expertise in team
- ✅ **Rapid development** is priority
- ✅ **Simple deployment** scenarios
- ✅ **Small team** (1-3 developers)
- ✅ **Learning HSU** framework

**Examples**: Research projects, prototypes, single-service applications

### Choose Approach 2 When:
- ✅ **Established domain** with clear requirements
- ✅ **Multi-language requirements** with coordination needs
- ✅ **Shared API evolution** is important
- ✅ **Medium team** (3-8 developers)
- ✅ **Synchronized releases** are beneficial
- ✅ **Cross-language consistency** is crucial

**Examples**: Platform APIs, shared services, coordinated client/server development

### Choose Approach 3 When:
- ✅ **Mature domain** with multiple variants needed
- ✅ **Large teams** requiring independence
- ✅ **Independent deployment** is essential
- ✅ **Different release cycles** for components
- ✅ **Heavy dependencies** need isolation
- ✅ **Multiple organizations** collaborating

**Examples**: ML platforms, microservice ecosystems, enterprise systems

## Migration Pathways

### Progressive Evolution
```
Start:  Approach 1 (hsu-example1-go)
  ↓     Add Python support
Grow:   Approach 2 (merge to hsu-example2 with /go/ and /python/)
  ↓     Extract shared components
Scale:  Approach 3 (hsu-example3-common + hsu-example3-srv-go + hsu-example3-srv-py)
```

### Language-First Evolution
```
Start:  Multiple Approach 1 repos (hsu-example1-go, hsu-example1-py)
  ↓     Coordinate development
Unify:  Approach 2 (merge to single hsu-example2 repo)
  ↓     Extract shared APIs
Scale:  Approach 3 (separate implementation repositories)
```

### Domain-First Evolution
```
Start:  Approach 2 (unified from beginning)
  ↓     Team growth requires independence
Split:  Approach 3 (extract shared components to common repo)
```

## Makefile System Integration

### Approach 1: Single-Language Commands
```makefile
# Consistent across Go and Python single-language repos
make build              # Build all components
make run-srv           # Run server
make run-cli           # Run client
make test              # Run tests
make clean             # Clean build artifacts

# Language-specific optimizations
make go-build          # Go-specific build (Go repos)
make py-build          # Python build with Nuitka (Python repos)
```

### Approach 2: Language-Prefixed Commands
```makefile
# Cross-language coordination
make build             # Build all languages
make go-build          # Build Go components only
make py-build          # Build Python components only
make go-run-srv        # Run Go server
make py-run-srv        # Run Python server
make proto-gen         # Generate code for all languages
```

### Approach 3: Repository-Specific Commands
```makefile
# Common repository
make build             # Build shared components
make proto-gen         # Generate language bindings
make test-common       # Test shared functionality

# Implementation repositories  
make build             # Build this implementation
make run-srv           # Run this server
make update-deps       # Update common dependencies
make test              # Test this implementation
```

## Example Transformations

### From Approach 1 to Approach 2
```bash
# Original: hsu-example1-go/
├── pkg/domain/handler.go
└── cmd/srv/main.go

# Transform to: hsu-example2/
├── go/
│   ├── pkg/domain/handler.go    # MOVED: Add go/ prefix
│   └── cmd/srv/main.go          # MOVED: Add go/ prefix  
└── python/
    ├── lib/domain/handler.py    # ADDED: New Python implementation
    └── srv/run_server.py        # ADDED: New Python server

# CRITICAL: Imports remain IDENTICAL!
# import "github.com/org/hsu-example2/pkg/domain"
```

### From Approach 2 to Approach 3
```bash
# Original: hsu-example2/go/pkg/domain/
# Transform to: 
# - hsu-example3-common/go/pkg/domain/     # EXTRACT: Shared components
# - hsu-example3-srv-go/cmd/srv/           # KEEP: Implementation only

# Dependencies change:
# Before: Internal imports
# After:  External dependency on hsu-example3-common
```

## Success Patterns

### Validated Implementations
All three approaches have been **successfully implemented** and tested:

- **Approach 1 Examples**: hsu-example1-go, hsu-example1-py
  - ✅ Full language tool compatibility
  - ✅ HSU Universal Makefile integration
  - ✅ Modern Python packaging with Nuitka

- **Approach 2 Example**: hsu-example2  
  - ✅ Coordinated Go/Python development
  - ✅ Shared API evolution
  - ✅ Cross-language build automation

- **Approach 3 Examples**: hsu-example3-*
  - ✅ Independent repository scaling
  - ✅ Shared component versioning
  - ✅ Flexible implementation patterns

### Framework Maturity
- **Complete Documentation**: All approaches fully documented
- **Working Examples**: Every claim validated with real code
- **Migration Tooling**: Automated transitions between approaches
- **Production Ready**: Proven through extensive development and testing

## Next Steps

1. **Review Specific Approach**: See detailed guides for [Approach 1](single-repo-single-lang.md), [Approach 2](single-repo-multi-lang.md), or [Approach 3](multi-repo-architecture.md)
2. **Understand Technical Details**: Review [portability mechanics](portability-mechanics.md)
3. **Plan Migration**: See [migration patterns](migration-patterns.md)
4. **Implementation Best Practices**: Check [development best practices](best-practices.md)

---

**The right approach depends on your current team size, domain maturity, and scaling requirements. All approaches support seamless evolution as your needs change.** 

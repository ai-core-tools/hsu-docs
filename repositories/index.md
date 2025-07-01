# HSU Repository Architecture Guide

Welcome to the HSU Repository Architecture documentation. This guide explains how to organize and structure your code repositories for maximum portability, scalability, and maintainability using the HSU framework.

## Quick Navigation

### 🏗️ **Framework & Concepts**
- **[Framework Overview](framework-overview.md)** - Core concepts, repo-portability definition, and key innovations
- **[Three Approaches Comparison](three-approaches.md)** - Detailed comparison with decision matrix and when to use each

### 📁 **Repository Approaches**
- **[Approach 1: Single-Repo + Single-Language](single-repo-single-lang.md)** - Focused domain implementation (examples: hsu-example1-go, hsu-example1-py)
- **[Approach 2: Single-Repo + Multi-Language](single-repo-multi-lang.md)** - Unified domain implementation (example: hsu-example2)
- **[Approach 3: Multi-Repository Architecture](multi-repo-architecture.md)** - Scalable domain ecosystem (examples: hsu-example3-*)

### ⚙️ **Technical Implementation**
- **[Portability Mechanics](portability-mechanics.md)** - Import consistency, go.mod tricks, and technical details
- **[Migration Patterns](migration-patterns.md)** - How to migrate between approaches with real examples
- **[Makefile Integration](makefile-integration.md)** - Repository approaches with HSU Universal Makefile System

### 📋 **Best Practices**
- **[Development Best Practices](best-practices.md)** - Workflow, naming conventions, tooling, and recommendations

## Overview

The HSU Repository Architecture Framework provides **three distinct approaches** for organizing domain-centric code that achieves true "repo-portability" - the ability to move code between different repository structures without modification.

### The Three Approaches

| Approach | Description | Complexity | Best For |
|----------|-------------|------------|----------|
| **Approach 1** | Single-Repository + Single-Language | ✅ Simple | New domains, single-language teams |
| **Approach 2** | Single-Repository + Multi-Language | ⚠️ Moderate | Coordinated multi-language development |
| **Approach 3** | Multi-Repository Architecture | ❌ Complex | Large teams, independent scaling |

### Key Innovation: Universal Repo-Portability

**Core Insight**: Repo-portability is achieved through **logical purpose separation** and **portable import schemes**, not specific folder structures. This enables seamless migration between repository architectures without code changes.

## Quick Start Examples

### Example Repository Structures

**Approach 1 - Single Language:**
```
hsu-example1-go/          # Single-repo, Go-focused
├── Makefile              # HSU Universal Makefile integration
├── go.mod
├── api/proto/            # API definitions
├── pkg/                  # Shared Go code (portable)
└── cmd/                  # Executable Go code (portable)
    ├── srv/              # Server implementations
    └── cli/              # Client implementations
```

**Approach 2 - Multi Language:**
```
hsu-example2/             # Single-repo, multi-language
├── Makefile              # Cross-language build automation
├── api/proto/            # Shared API definitions
├── go/                   # Language boundary
│   ├── go.mod
│   ├── pkg/              # Portable Go shared code
│   └── cmd/              # Portable Go executables
└── python/               # Language boundary
    ├── pyproject.toml
    ├── lib/              # Portable Python shared code
    ├── srv/              # Portable Python servers
    └── cli/              # Portable Python clients
```

**Approach 3 - Multi Repository:**
```
hsu-example3-common/      # Shared domain components
├── api/proto/            # Shared API definitions
├── go/pkg/               # Shared Go libraries
└── python/lib/           # Shared Python libraries

hsu-example3-srv-go/      # Go server implementation
├── Makefile
├── go.mod                # Depends on hsu-example3-common
└── cmd/srv/              # Server implementation only

hsu-example3-srv-py/      # Python server implementation  
├── Makefile
├── pyproject.toml        # Depends on hsu-example3-common
└── srv/                  # Server implementation only
```

## Integration with HSU Ecosystem

### Universal Makefile System
All repository approaches integrate seamlessly with the **[HSU Universal Makefile System](../makefile_guide/index.md)**:

- **Language Detection**: Automatic Go/Python project detection
- **Cross-Platform Support**: Windows, macOS, Linux compatibility  
- **Standardized Commands**: Consistent `make build`, `make run-srv`, `make test` across all approaches
- **Template System**: Automatic code generation and wrapper creation

### Framework Components
- **[HSU Core](../HSU_MASTER_GUIDE.md)**: Process management and gRPC infrastructure
- **[Protocol Buffers](../HSU_PROTOCOL_BUFFERS.md)**: API-first design with code generation
- **[Testing & Deployment](../HSU_TESTING_DEPLOYMENT.md)**: Comprehensive testing strategies

## Real-World Examples

The documentation includes **validated examples** from working repositories:

- **hsu-example1-go**: Proven single-language Go implementation
- **hsu-example1-py**: Python equivalent with Nuitka binary compilation
- **hsu-example2**: Multi-language coordination in single repository
- **hsu-example3-common**: Shared components for multi-repo architecture
- **hsu-example3-srv-go/py**: Independent server implementations

## Migration Support

The framework supports **progressive evolution**:
1. **Start Simple**: Begin with Approach 1 (single-language)
2. **Add Languages**: Evolve to Approach 2 (multi-language)
3. **Scale Teams**: Graduate to Approach 3 (multi-repository)

**Migration is seamless** - the same code works across all approaches due to consistent import schemes and portable folder structures.

## Next Steps

1. **New to HSU?** Start with [Framework Overview](framework-overview.md)
2. **Choosing an approach?** See [Three Approaches Comparison](three-approaches.md)  
3. **Ready to implement?** Pick your approach guide above
4. **Need to migrate?** Check [Migration Patterns](migration-patterns.md)

## Documentation Status

✅ **Complete**: All approaches validated with working examples  
✅ **Tested**: Integration with HSU Universal Makefile System  
✅ **Current**: Reflects latest framework capabilities and lessons learned

---

**Questions or Issues?** See [Best Practices](best-practices.md) for troubleshooting and recommendations. 
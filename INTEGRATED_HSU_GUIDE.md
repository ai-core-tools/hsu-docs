# Creating an Integrated HSU

This guide walks you through creating an Integrated HSU process that implements both core HSU functionality and custom business logic through gRPC APIs. Choose your learning path based on your needs and experience level.

## Overview

An Integrated HSU is a process that:
- **Implements Core HSU Interface**: Provides health checks, logging, and lifecycle management
- **Exposes Business APIs**: Custom gRPC services for domain-specific functionality  
- **Self-Manages**: Handles graceful startup and shutdown
- **Integrates Deeply**: Communicates with master processes through type-safe gRPC APIs

## 🎯 Learning Path Navigator

Choose your implementation approach based on your needs:

### 🚀 Single-Repository Implementation (Recommended for Getting Started)

**Best for:**
- Learning the HSU platform
- Single-language projects
- Rapid prototyping
- Small teams or individual development

**Characteristics:**
- Self-contained in one repository
- All code visible and editable
- No complex dependencies
- Perfect for understanding HSU patterns

### 🏢 Multi-Repository Implementation (Multi-Repository Structure)

**Best for:**
- Production systems
- Multiple language implementations (Go + Python)
- Team collaboration
- Complex domains with multiple server variants

**Characteristics:**
- Shared common domain repositories
- Independent server implementation repositories
- Sophisticated dependency management
- Enables multiple implementations per domain

---

## 🚀 Single-Repository Implementation Path

### Prerequisites
- Choose your language: Go 1.22+ or Python 3.8+
- Protocol Buffers compiler (`protoc`)
- Basic understanding of gRPC

### Quick Start Options

#### Option A: Single-Repository Go Implementation
**Perfect for Go developers or teams**

**📋 Follow this guide:** [Single-Repository HSU Go Implementation](INTEGRATED_HSU_SINGLE_REPO_GO_GUIDE.md)

**What you'll build:**
- Single-repository Go server
- Built-in gRPC service definitions
- Complete test client
- Simple business logic implementation

**Time to complete:** ~30-45 minutes

#### Option B: Single-Repository Python Implementation  
**Perfect for Python developers or teams**

**📋 Follow this guide:** [Single-Repository HSU Python Implementation](INTEGRATED_HSU_SINGLE_REPO_PYTHON_GUIDE.md)

**What you'll build:**
- Single-repository Python server
- Git submodules for dependencies
- Python client and server examples
- Single-repository business logic implementation

**Time to complete:** ~30-45 minutes

---

## 🏢 Multi-Repository Implementation Path

### Prerequisites
- Go 1.22+ and/or Python 3.8+
- Git (for repository management)
- Understanding of multi-repository development
- Basic understanding of gRPC and HSU platform concepts

### Implementation Steps

#### Step 1: Understand the Architecture
**📋 Essential reading:** [HSU Repository Structure](HSU_REPOSITORY_STRUCTURE.md)

Learn about:
- Common domain repositories vs server implementation repositories
- Multi-repository development patterns
- Dependency management across languages
- Version control strategies

**Time to complete:** ~15 minutes

#### Step 2: Setup Protocol Buffers
**📋 Complete setup:** [Protocol Buffer Definition Guide](HSU_PROTOCOL_BUFFERS.md)

Setup includes:
- gRPC service definitions
- Code generation for Go and Python
- API contract management
- Cross-language compatibility

**Time to complete:** ~20 minutes

#### Step 3: Choose Your Implementation Language(s)

##### Option A: Go Implementation
**📋 Follow this guide:** [HSU Go Implementation Guide](INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md)

Create:
- Common domain repository with Go support
- gRPC handlers and domain contracts
- Helper functions for server setup
- Individual server implementations

**Time to complete:** ~60-90 minutes

##### Option B: Python Implementation
**📋 Follow this guide:** [HSU Python Implementation Guide](INTEGRATED_HSU_MULTI_REPO_PYTHON_GUIDE.md)

Create:
- Python support in common domain repository
- Git submodule management
- Python gRPC handlers and domain contracts
- Python server implementations

**Time to complete:** ~60-90 minutes

##### Option C: Both Go and Python
Follow both implementation guides to create servers in both languages sharing the same domain contract.

**Time to complete:** ~2-3 hours

#### Step 4: Testing and Deployment
**📋 Best practices:** [Testing and Deployment Guide](HSU_TESTING_DEPLOYMENT.md)

Covers:
- Cross-language testing strategies
- Integration testing
- Deployment patterns
- Monitoring and observability

**Time to complete:** ~30 minutes

#### Step 5: Follow Best Practices
**📋 Platform conventions:** [HSU Best Practices](HSU_BEST_PRACTICES.md)

Learn:
- Error handling patterns
- Logging and monitoring
- Configuration management
- Troubleshooting guides

**Time to complete:** ~20 minutes

---

## 📚 Reference Implementation

The **`hsu-echo`** domain serves as the complete reference implementation:

### Single-Repository Implementations
- **[`hsu-echo-simple-go/`](../hsu-echo-simple-go/)** - Self-contained Go server
- **[`hsu-echo-simple-py/`](../hsu-echo-simple-py/)** - Self-contained Python server

### Multi-Repository Implementation Structure
- **[`hsu-echo/`](../hsu-echo/)** - Common domain repository
- **[`hsu-echo-super-srv-go/`](../hsu-echo-super-srv-go/)** - Go server implementation
- **[`hsu-echo-super-srv-py/`](../hsu-echo-super-srv-py/)** - Python server implementation

## 🔄 Migration Path

You can start with single-repository and evolve:

1. **Start Single-Repository**: Begin with a single-repository implementation to learn the patterns
2. **Extract Common**: When you need multiple implementations, extract shared components
3. **Scale Architecture**: Move to multi-repository structure for production systems

The HSU platform supports this evolution without breaking existing functionality.

## 📖 Additional Resources

Once you've created your HSU implementation, explore these topics:

- **[Working with gRPC Services](GRPC_SERVICES.md)** - Advanced gRPC patterns
- **[Multi-Language Support](MULTI_LANGUAGE.md)** - Language-specific considerations  
- **[Process Management](PROCESS_MANAGEMENT.md)** - Managing HSU processes
- **[Creating HSU Masters](HSU_MASTER_GUIDE.md)** - Building master processes

## 🆘 Getting Help

- **Single-Repository Implementation Issues**: Check the troubleshooting sections in the single-repository implementation guides
- **Multi-Repository Implementation Issues**: Review the [Best Practices troubleshooting](HSU_BEST_PRACTICES.md#troubleshooting)
- **Architecture Questions**: Study the reference implementation in `hsu-echo/`
- **Platform Concepts**: Consult the [Developer Guide](DEVELOPER_GUIDE.md)

## 🎯 Recommended Learning Sequence

### For Beginners
1. Choose **Single-Repository Implementation** (Go or Python)
2. Complete the implementation following the guide
3. Experiment with the business logic
4. Study the reference implementation patterns

### For Production Development
1. Read **[Repository Structure](HSU_REPOSITORY_STRUCTURE.md)** first
2. Setup **[Protocol Buffers](HSU_PROTOCOL_BUFFERS.md)**
3. Implement your chosen language(s)
4. Follow **[Testing and Deployment](HSU_TESTING_DEPLOYMENT.md)**
5. Apply **[Best Practices](HSU_BEST_PRACTICES.md)**

---

**Ready to start?** Pick your path above and begin building your first HSU server! 🚀 
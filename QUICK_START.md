# HSU Platform - 5-Minute Quick Start Guide

Get up and running with the HSU Platform in just 5 minutes! This guide will help you understand the core concepts and start your first HSU project.

## 🎯 What is HSU?

HSU (Host System Unit) is a platform for building **portable microservices** that work seamlessly across different repository structures, programming languages, and deployment environments.

**Key Benefits:**
- ✅ **Repository Portability** - Same code works in single-repo, multi-repo, or hybrid setups
- ✅ **Universal Build System** - Consistent `make` commands across all projects  
- ✅ **Multi-Language Support** - Go and Python with identical import patterns
- ✅ **Production Ready** - Full gRPC stack with deployment automation

## 🏗️ Step 1: Choose Your Repository Approach (2 minutes)

HSU supports three proven approaches. **Pick the one that matches your team structure:**

### Option A: Single-Repository + Single-Language
**Best for:** Small teams, getting started, language-specific projects
```bash
# Example: hsu-example1-go/ or hsu-example1-py/
└── your-project/
    ├── api/proto/          # Protocol definitions
    ├── cmd/               # Application entry points  
    ├── pkg/               # Business logic
    └── Makefile           # Universal build commands
```

### Option B: Single-Repository + Multi-Language  
**Best for:** Full-stack teams, unified deployments, shared protocols
```bash
# Example: hsu-example2/
└── your-project/
    ├── api/proto/         # Shared protocols
    ├── go/                # Go services
    ├── python/            # Python services  
    └── Makefile           # Universal build commands
```

### Option C: Multi-Repository Architecture
**Best for:** Large teams, microservice independence, separate deployment cycles
```bash
# Example: hsu-example3-*
your-project-common/       # Shared protocols & clients
your-project-srv-go/       # Go microservice
your-project-srv-py/       # Python microservice  
```

**👉 Decision unclear?** See the [detailed comparison with decision matrix](repositories/three-approaches.md).

## 🚀 Step 2: Set Up Your Project (2 minutes)

### Copy From Working Examples
The fastest way to start is copying a working example:

```bash
# For Approach A (Single-Language)
cp -r hsu-example1-go/ my-project/
# or
cp -r hsu-example1-py/ my-project/

# For Approach B (Multi-Language)  
cp -r hsu-example2/ my-project/

# For Approach C (Multi-Repository)
cp -r hsu-example3-common/ my-project-common/
cp -r hsu-example3-srv-go/ my-project-srv-go/
```

### Update Project Configuration
Edit `Makefile.config` to match your project:
```makefile
# Project identification
PROJECT_NAME = my-project
MODULE_NAME = github.com/myorg/my-project

# Language support
ENABLE_GO = 1
ENABLE_PYTHON = 1
```

## ⚡ Step 3: Universal Build Commands (1 minute)

All HSU projects use the same build commands regardless of approach:

```bash
# 🔧 Development Commands
make setup              # Install dependencies
make generate           # Generate code from protocols  
make build              # Build all components
make test               # Run all tests
make run-server         # Start development server
make run-client         # Test with example client

# 📦 Distribution Commands  
make package            # Create distribution packages
make package-binary     # Create optimized binaries
make docker             # Build Docker images

# 🧹 Maintenance Commands
make clean              # Clean build artifacts
make help               # Show all available commands
```

**🎉 That's it!** Your HSU project is ready for development.

## 🎓 Next Steps

Now that you're up and running, explore these guides based on your needs:

### For Developers
- [**Developer Guide**](guides/DEVELOPER_GUIDE.md) - Core development practices
- [**Testing & Debugging**](guides/TESTING_DEBUGGING.md) - Quality assurance
- [**Multi-Language Development**](guides/MULTI_LANGUAGE.md) - Go + Python best practices

### For DevOps/Operations  
- [**Configuration Management**](deployment/CONFIGURATION.md) - Environment setup
- [**Makefile System Deep Dive**](makefile_guide/index.md) - Advanced build automation
- [**Python Package Deployment**](deployment/PYTHON_PACKAGE_DEPLOYMENT_GUIDE.md) - PyPI publishing

### For Architects
- [**Repository Framework Deep Dive**](repositories/index.md) - Architectural decisions  
- [**Migration Patterns**](repositories/migration-patterns.md) - Evolving between approaches
- [**Best Practices**](repositories/best-practices.md) - Team workflows

### For Implementation
- [**Step-by-Step Tutorials**](tutorials/) - Detailed implementation guides
- [**Examples Collection**](reference/EXAMPLES.md) - Code patterns and snippets  
- [**API Reference**](reference/API_REFERENCE.md) - Complete technical documentation

## 🆘 Need Help?

**Common Issues:**
- Build errors → [Makefile Troubleshooting](makefile_guide/troubleshooting.md)
- Protocol issues → [Protocol Buffers Guide](guides/HSU_PROTOCOL_BUFFERS.md)  
- Architecture questions → [Repository Framework FAQ](repositories/framework-overview.md)

**Full Documentation:** [Main Documentation Hub](README.md)

---

**🚀 Ready to build something amazing with HSU!** 

*Questions? Check the [comprehensive documentation](README.md) or explore the working examples in the repository.* 
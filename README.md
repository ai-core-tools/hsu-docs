# HSU (Host System Unit) Platform Documentation

Welcome to the comprehensive documentation for the HSU Platform - a cutting-edge framework for building portable, scalable microservices with seamless multi-language support and universal build systems.

## 🚀 Quick Start

**New to HSU?** Start here:
- [**5-Minute Quick Start Guide**](QUICK_START.md) - Get up and running fast
- [**Repository Architecture Overview**](repositories/index.md) - Choose your approach
- [**Makefile System Quick Start**](makefile_guide/quick-start.md) - Universal build commands

## 📚 Documentation Sections

### 🏗️ Core Framework Documentation

#### Architecture & Product Vision
- [**Product Overview & Architecture**](architecture/index.md) - Product concept, value proposition, and system design

#### Repository Architecture
Choose the approach that fits your team structure:
- [**Repository Framework Overview**](repositories/index.md) - Start here for repository decisions
- [**Three Repository Approaches**](repositories/three-approaches.md) - Detailed comparison with decision matrix
- [**Portability Mechanics**](repositories/portability-mechanics.md) - Technical implementation details
- [**Migration Patterns**](repositories/migration-patterns.md) - Moving between approaches
- [**Makefile Integration**](repositories/makefile-integration.md) - Build system integration
- [**Best Practices**](repositories/best-practices.md) - Development workflows and guidelines

#### Universal Makefile System
Standardized build commands across all projects:
- [**Makefile System Overview**](makefile_guide/index.md) - Complete navigation hub
- [**Quick Start**](makefile_guide/quick-start.md) - Essential commands and setup
- [**Master Rollout Architecture**](makefile_guide/master-rollout.md) - Enterprise deployment
- [**Configuration Reference**](makefile_guide/configuration.md) - All configuration options
- [**Command Reference**](makefile_guide/commands.md) - Complete command catalog
- [**Examples & Patterns**](makefile_guide/examples.md) - Real-world usage
- [**Best Practices**](makefile_guide/best-practices.md) - Guidelines and recommendations
- [**Advanced Topics**](makefile_guide/advanced.md) - Migration, extensibility, troubleshooting

### 🎓 Step-by-Step Tutorials

Hands-on guides for implementing HSU with working examples:
- [**HSU Implementation Guide**](tutorials/INTEGRATED_HSU_GUIDE.md) -  - Complete implementation guide for integrated HSU
- [**Tutorial Index**](tutorials/index.md) - Navigation hub for all specific implementation tutorials

### 📖 Developer Guides

Essential guides for development teams:
- [**Developer Guide**](guides/DEVELOPER_GUIDE.md) - Core development practices
- [**Development Setup**](guides/DEVELOPMENT_SETUP.md) - Environment configuration
- [**HSU Master Guide**](guides/HSU_MASTER_GUIDE.md) - Comprehensive platform overview
- [**Best Practices**](guides/HSU_BEST_PRACTICES.md) - Development standards
- [**Protocol Buffers Guide**](guides/HSU_PROTOCOL_BUFFERS.md) - gRPC and protobuf implementation
- [**Multi-Language Development**](guides/MULTI_LANGUAGE.md) - Cross-language best practices
- [**Process Management**](guides/PROCESS_MANAGEMENT.md) - Service lifecycle management
- [**Testing & Debugging**](guides/TESTING_DEBUGGING.md) - Quality assurance practices
- [**Testing & Deployment**](guides/HSU_TESTING_DEPLOYMENT.md) - CI/CD integration

### 🚀 Deployment & Operations

Production deployment and operational guides:
- [**Configuration Management**](deployment/CONFIGURATION.md) - Environment configuration
- [**Python Package Deployment**](deployment/PYTHON_PACKAGE_DEPLOYMENT_GUIDE.md) - PyPI publishing

### 📋 Reference Documentation

Technical specifications and API documentation:
- [**API Reference**](reference/API_REFERENCE.md) - Complete API documentation
- [**gRPC Services**](reference/GRPC_SERVICES.md) - Service definitions and protocols
- [**Examples Collection**](reference/EXAMPLES.md) - Code examples and snippets
- [**Repository Portability Framework**](reference/HSU_REPO_PORTABILITY_FRAMEWORK.md) - Technical specification

## 🏢 Repository Examples

See HSU in action with our working examples:

### Approach 1: Single-Repository + Single-Language
- **`hsu-example1-go/`** - Pure Go implementation with full gRPC stack
- **`hsu-example1-py/`** - Pure Python implementation with gRPC services

### Approach 2: Single-Repository + Multi-Language  
- **`hsu-example2/`** - Go and Python services in one repository with shared protocols

### Approach 3: Multi-Repository Architecture
- **`hsu-example3-common/`** - Shared protocols and client libraries
- **`hsu-example3-srv-go/`** - Go microservice implementation  
- **`hsu-example3-srv-py/`** - Python microservice implementation

## 🤝 Contributing

For contribution guidelines and development setup, see:
- [**Development Setup**](guides/DEVELOPMENT_SETUP.md)
- [**Developer Guide**](guides/DEVELOPER_GUIDE.md)
- [**Best Practices**](guides/HSU_BEST_PRACTICES.md)

## 📄 License

See [LICENSE](LICENSE) for details.

---

*For questions or support, please refer to the relevant documentation sections above or contact the development team.*

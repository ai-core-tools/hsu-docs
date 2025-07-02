# HSU Microservice Framework

The **Host System Unit (HSU)** framework provides a clean, pluggable framework for composing larger applications from independent, language-agnostic microservices running locally or distributed across the network. This framework enables lightweight orchestration and management of distributed services in resource-constrained environments such as edge computing or embedding systems.

Unlike Kubernetes, which separates orchestration into dedicated services (API server, etcd, controllers), the HSU framework allows to integrate orchestration directly into the services typically selecting one of them as a master process. This eliminates the overhead of maintaining separate orchestration infrastructure while combining service discovery, lifecycle management, and business logic dispatch in a single, efficient process.

# HSU Platform: Kubernetes for Native Applications

## Problem

**Kubernetes** revolutionized container orchestration but while enabling horizontal scaling of orchestration components it creates significant resource overhead and imposes strict packaging requirements that limit deployment flexibility in resource-constrained environments such as:

- **Edge computing environments** with limited resources and intermittent connectivity
- **On-premises deployments** requiring native process control and legacy system integration
- **Desktop applications** needing cross-platform modular architectures without container overhead
- **Embedded systems** where containers are impractical or impossible
- **Development environments** requiring lightweight orchestration of diverse tooling

Other orchestration systems such as **Nomad**, **systemd**, **Docker Compose** and some others provide more lightweight services orchestration but still require additional dependencies and resources, such as RAM and CPU for orchestration service itself or containers runtime on Windows and MacOS

## Solution

The HSU framework provides Kubernetes-grade service orchestration capabilities that are **built-in right into one of the service processes** in the system (so-called master process), offering the following functionality with near to zero hardware resources overhead:

- **Native Process Control** in Windows, Linux and macOS without containers runtime overhead
- **Automated deployment and scaling** including installation, update, on-demand wakeup and on-idle shutdown
- **Service discovery and configuration management** for native processes and network services
- **Health monitoring** including memory and CPU usage tracking using OS-native APIs

The main difference between *external* orchestration systems (e.g. Kubernetes, Nomad, Docker Compose) and HSU is represented on this diagram:

![HSU vs Kubernetes, Nomad and Docker Compose](../img/hsu-vs-k8s.drawio.svg)

Since orchestration is built directly into the system processes, HSU provides not just a set of orchestration libraries but rather a complete development framework with an ability to define and implement service business APIs:
- **client libraries** - that allow to orchestrate and communicate with other services, currently for **Go-lang** only, but with **Rust** in backlog
- **server libraries** - allowing to implement base control or service specific APIs in **Go**, **Python**, with upcoming **Rust** and **C++** support
- **API protocol defintion** - for those services who want to implement their own business API (currently gRPC with plans to support HTTP)
- **build system assistents** - allowing to compile server code into binaries, including Python code-to-binary compilation with help of **Nuitka**
- **code examples** - comprehensive documentation and examples
- **code repository layout guides** - consistent repository layouts and conventions, making it straightforward to generate client/server libraries across languages while maintaining a cohesive system architecture

## Architecture

The **Host System Unit (HSU)** architecture divides all services into two primary roles:
- **HSU (Host System Units)** – Standalone processes or services that implement specific functionality within the microservice system
- **Master Processes** – Long-running resident processes responsible for HSU discovery, orchestration, and lifecycle management

The architecture provides a continuum of integration making it highly adaptable to real-world hybrid systems with help of three categories of HSUs:
- **Unmanaged Units** for passive observation
- **Managed Units** for full process lifecycle control
- **Integrated Units** for deep API-level integration and orchestration

### HSU Categories

The architecture supports three distinct categories of units, each offering different levels of integration and control:

#### 1. Unmanaged Units
Unmanaged units are processes whose lifecycle is **not controlled** by the master processes. However, the master process can still perform basic management operations such as:
- **Discovery**: Locate processes by name or identifier
- **Monitoring**: Retrieve memory usage, CPU consumption, and health status
- **Basic Control**: Terminate processes when necessary

These capabilities leverage standard OS-level APIs, and HSU libraries provide cross-platform abstractions for common operations.

**Examples**:
- Database servers (PostgreSQL, MySQL)
- System services (SSH daemon, Docker daemon)
- Third-party applications already deployed in the environment

#### 2. Managed Units
Managed units are processes whose **complete lifecycle** is controlled by the master processes. The master process has full authority over:
- **Process Control**: Start, stop, and restart operations
- **Environment Management**: Working directory, environment variables
- **I/O Handling**: stdout/stderr redirection and processing
- **Configuration**: Command-line parameters and runtime arguments
- **Limits**: CPU, RAM constrains

**Examples**:
- Custom application workers spawned on-demand
- Batch processing jobs with defined lifecycles
- Monitoring agents controlled by a central orchestrator

#### 3. Integrated Units
Integrated units represent the highest level of integration, combining full lifecycle management with **deep programmatic integration** through gRPC APIs. These units implement:
- **Core gRPC Interface**: Standard functionality (health checks, graceful shutdown, logging)
- **Business-Specific APIs**: Custom gRPC services for domain-specific operations
- **Multi-Language Support**: Can be implemented in any language supporting gRPC (Go, Python, Rust, Java, etc.)

The master process communicates with integrated units through generated gRPC client stubs, enabling type-safe, versioned API interactions.

**Examples**:
- ML inference servers with model management APIs
- Data processing pipelines with job control interfaces
- Storage adapters implementing standardized CRUD operations

### Design Philosophy

The HSU architecture doesn't prescribe specific microservice design patterns or domain boundaries. Instead, it provides a **lightweight orchestration layer** that combines Kubernetes-like process management with business API clients in a single, low-footprint master process.

This design enables microservices architectures in resource-constrained environments:

- **Dynamic Resource Management**: Spin HSUs up and down based on demand to optimize CPU/RAM usage
- **Third-Party Integration**: Attach to and control existing processes or services without modification
- **Language Agnostic Development**: Implement integrated HSUs in the most suitable language for each use case
- **Edge Computing Ready**: Minimal overhead suitable for embedded systems and edge deployments

## 📚 Documentation Sections

### 🎓 Step-by-Step Tutorials

Hands-on guides for implementing HSU with working examples:
- [**HSU Implementation Guide**](tutorials/INTEGRATED_HSU_GUIDE.md) -  - Complete implementation guide for integrated HSU
- [**Tutorial Index**](tutorials/index.md) - Navigation hub for all specific implementation tutorials

### 🎯 Architecture Deep Dive
Learn more on HSU concept, value proposition, and system design
- [**Architecture Deep Dive**](architecture/index.md) - Detailed architecture description

### 🏗️ Core Framework Documentation

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
- [**Configuration Management**](deployment/configuration.md) - Environment configuration
- [**Python Package Deployment**](deployment/python_package_deployment_guide.md) - Python package deployment and publishing

### 📋 Reference Documentation

Technical specifications and API documentation:
- [**API Reference**](reference/api_reference.md) - Complete API documentation
- [**gRPC Services**](reference/grpc_services.md) - Service definitions and protocols
- [**Examples Collection**](reference/examples.md) - Code examples and snippets
- [**Repository Portability Framework**](reference/repo_portability_framework.md) - Technical specification

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

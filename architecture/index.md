# HSU Microservice Framework

The **Host System Unit (HSU)** framework provides a clean, pluggable framework for composing larger applications from independent, language-agnostic microservices running locally or distributed across the network. This framework enables lightweight orchestration and management of distributed services in resource-constrained environments such as edge computing or embedding systems.

Unlike Kubernetes, which separates orchestration into dedicated services (API server, etcd, controllers), the HSU framework allows to integrate orchestration directly into the services typically selecting one of them as a master process. This eliminates the overhead of maintaining separate orchestration infrastructure while combining service discovery, lifecycle management, and business logic dispatch in a single, efficient process.

## Architecture Diagram

![HSU Architecture](../img/hsu-architecture.drawio.svg)

---

## Distributed Architecture (Planned)

> **Note**: The following describes the planned distributed architecture. Current implementation focuses on single-node orchestration with multi-node capabilities planned for future releases.

### Multi-Node Coordination
- **Master Node Election**: Consensus-based leader election for high availability
- **Node Discovery**: Automatic discovery and registration of HSU nodes across network segments
- **Tunnel-Based Networking**: Secure, encrypted communication channels between distributed nodes
- **Configuration Synchronization**: Distributed configuration management across the cluster

### Service Mesh Integration
- **Native Service Discovery**: gRPC-based service registry with health checking
- **Load Balancing**: Intelligent request routing between HSU instances
- **Circuit Breakers**: Automatic failure detection and traffic isolation
- **Observability**: Distributed tracing and metrics collection across HSU network

### Deployment Model
- **Declarative Configuration**: YAML-based HSU deployment specifications
- **Rolling Deployments**: Zero-downtime updates with configurable rollback policies
- **Resource Management**: Cross-node resource allocation and constraint enforcement
- **Secrets Distribution**: Encrypted secrets management across distributed nodes

---

## Core Concepts

| Concept                  | Description                                                                       |
| ------------------------ | --------------------------------------------------------------------------------- |
| **Unmanaged HSU process** | External processes that exist independently of the master process. The master can discover, monitor, and perform basic control operations (start/stop/kill) but does not manage their complete lifecycle. Examples include system services, databases, or pre-existing applications. |
| **Managed HSU process**          | Processes whose complete lifecycle is controlled by the master process. The master manages startup, shutdown, environment variables, working directories, and I/O redirection. These processes are typically custom applications designed to work within the HSU ecosystem. |
| **Integrated HSU process**       | Fully managed processes that implement standardized gRPC interfaces for deep integration with the master process. They support advanced features like health checks, graceful shutdown, structured logging, and custom business logic APIs. These represent the highest level of HSU integration. |
| **HSU Master process**   | Central orchestration service responsible for HSU discovery, lifecycle management, health monitoring, log aggregation, and API gateway functionality. Acts as the single point of control for all HSUs in the system. |
| **Interface A / B ...**    | Domain-specific gRPC service interfaces that extend the core HSU functionality. Examples include LLM management APIs, data processing interfaces, storage adapters, or custom business logic services. |
| **gRPC Interface Stack** | Collection of generated client stubs and protobuf definitions that enable type-safe communication between the master process and integrated HSUs. Supports multiple programming languages and versioned API contracts. |


### Typical Use Cases

The HSU architecture excels in scenarios requiring lightweight microservice orchestration with varying levels of process control. Here are common implementation patterns organized by HSU category:

#### Unmanaged HSU Use Cases
These scenarios involve integrating with existing systems while maintaining minimal interference:

- **Database Integration** – Monitor PostgreSQL/MySQL servers, track connections and performance metrics, implement connection pooling
- **System Service Management** – Integrate with SSH daemons, Docker containers, message queues (Redis, RabbitMQ) for discovery and health monitoring
- **Third-Party API Gateways** – Monitor external services, track response times, implement circuit breaker patterns
- **Legacy System Integration** – Connect with existing applications without modification, providing modern APIs over legacy interfaces

#### Managed HSU Use Cases
Perfect for custom applications requiring full lifecycle control:

- **Batch Processing Workers** – Spawn data processing jobs on-demand, manage job queues, handle failure recovery
- **Microservice Components** – Deploy and manage custom REST APIs, background services, and scheduled tasks
- **Development Tooling** – Control development servers, testing frameworks, and build processes
- **Resource-Intensive Tasks** – Manage GPU-intensive workloads, temporary compute jobs, and seasonal processing spikes

#### Integrated HSU Use Cases
Advanced scenarios leveraging deep gRPC integration for complex business logic:

- **LLM Management Platform** – Control model servers (Ollama, vLLM), manage inference requests, handle model loading/unloading, implement request routing and load balancing
- **Machine Learning Pipeline** – Orchestrate training jobs, manage experiment tracking, control data preprocessing, handle model deployment and A/B testing
- **RAG (Retrieval-Augmented Generation) System** – Manage document ingestion, vector database operations, query processing, and response generation
- **Media Processing** – Control video transcoding workers, manage encoding queues, handle thumbnail generation, implement streaming protocols
- **Real-Time Analytics** – Process streaming data from Kafka/Kinesis, manage stateful processors, handle windowing operations, implement alerting systems
- **Storage Orchestration** – Manage object store operations (S3, MinIO), implement caching strategies, handle data replication and backup
- **Notification Systems** – Control multi-channel dispatchers (email, SMS, push notifications), manage templates and personalization, handle delivery tracking

#### Hybrid Deployments
Complex systems often combine multiple HSU types:

- **Edge AI Platform** – Integrated HSUs for ML inference + Managed HSUs for data collection + Unmanaged HSUs for existing sensor networks
- **Content Management System** – Integrated HSUs for media processing + Managed HSUs for background jobs + Unmanaged HSUs for database and cache layers
- **IoT Data Pipeline** – Integrated HSUs for stream processing + Managed HSUs for device simulators + Unmanaged HSUs for time-series databases


## Comparison: HSU vs Kubernetes vs Lightweight Alternatives

| Feature / Capability           | **HSU Architecture**                | **Kubernetes**                           | **Nomad**                           | **systemd**                         |
|-------------------------------|--------------------------------------|------------------------------------------|-------------------------------------|-------------------------------------|
| **Primary Abstraction**       | Host System Unit (HSU)               | Pod (Container Group)                    | Job / Task                          | Unit (Service, Timer, Socket)       |
| **Lifecycle Control**         | OS-level & gRPC                      | Container runtime (CRI)                  | OS & container runtime              | OS-level                            |
| **Orchestration Type**        | 🚧 Local + planned multi-node        | ✅ Cluster-wide, declarative             | ✅ Cluster-wide, imperative + config| ❌ Local only                       |
| **Service Discovery**         | 🚧 Planned via gRPC registry         | ✅ DNS + Labels/Selectors                | ✅ Consul integration               | ❌ Manual configuration             |
| **Auto-scaling**              | 🚧 Planned horizontal scaling        | ✅ HPA/VPA/Cluster autoscaling          | ✅ Job autoscaling                  | ❌ Not supported                   |
| **Configuration Management**  | 🚧 Environment-based config          | ✅ ConfigMaps/Secrets                   | ✅ Templates + Variables            | ⚠️ Environment files               |
| **Secrets Management**        | 🚧 Encrypted config files planned    | ✅ Encrypted etcd storage               | ✅ Vault integration                | ❌ Plain text files                |
| **Multi-node Deployment**     | 🚧 Tunnel-based networking planned   | ✅ Core feature                          | ✅ Core feature                     | ❌ Single node only                |
| **Health Management**         | ⚠️ Basic process monitoring          | ✅ Probes + Self-healing                | ✅ Health checks                    | ⚠️ Basic restart policies          |
| **Rolling Updates**           | ❌ Not implemented                   | ✅ Core feature                          | ✅ Update strategies                | ❌ Manual process                  |
| **Load Balancing**            | ❌ Not implemented                   | ✅ Services + Ingress                    | ✅ Via service discovery            | ❌ External required               |
| **Custom App-Level APIs**     | ✅ Built-in via gRPC                 | ⚠️ Possible via Operator/CRD              | ⚠️ Manual integration needed        | ❌ Not supported                    |
| **Process Management**        | ✅ Native, fine-grained control      | ⚠️ Container-focused, VM via operators   | ✅ Mixed (exec + container)         | ✅ Full native control              |
| **Language Agnostic**         | ✅ Full (gRPC, CLI, etc.)            | ✅ via container boundary                 | ✅                                  | ✅                                  |
| **Cross-Platform Support**    | ✅ Native (Linux, Windows, macOS)    | ✅ Linux + Windows nodes                 | ✅ (Linux/Windows/macOS via plugin) | ⚠️ Linux primary, some BSD support  |
| **Resource Constraints**      | ✅ OS primitives (ulimit, cgroups)   | ✅ Full quota support (cgroups, etc.)     | ✅ via config                       | ⚠️ Manual (`ulimit`, slices)        |
| **Workers Scheduling**        | ✅ Built-in into the master process  | ✅ Core feature                           | ✅ Core feature                     | ❌ No scheduler                     |
| **On-Demand Worker Start**    | ✅ Direct via API or OS process spawn  | ⚠️ Indirect (e.g., scale-to-zero via KEDA) | ✅ via job dispatching               | ⚠️ Indirect via timer/trigger units |
| **System Overhead**           | 🟢 Minimal (single binary master)      | 🔴 High (API server, etcd, controllers)   | 🟡 Moderate (single binary, plugins) | 🟢 Very low (native init daemon)   |
| **Ideal For**                 | Edge, ML, embedded, hybrid systems   | Cloud-native microservices, CI/CD        | General workload orchestration      | Local servers, daemons, dev setups |
| **Complexity / Footprint**    | 🟢 Low                               | 🔴 High                                   | 🟡 Medium                           | 🟢 Very Low                         |

**Legend:**
- ✅ Fully implemented and production-ready
- 🚧 Planned/In development
- ⚠️ Partial implementation or workarounds available
- ❌ Not supported


## Features & Roadmap

### Base HSUs orchestration
- [🚧] Go-lang client for all types of HSUs - Managed, Unamanaged and Integrated units control interfaces
- [🚧] gRPC integration framework - Core API definitions and client/server helpers
- [🚧] Process lifecycle control - Start, stop, monitor native processes, on-demand wakeup, on-idle shutdown
- [🚧] Basic health monitoring - Process status and hardware resource usage tracking for CPU and RAM
- [🚧] Go-lang HSU server stubs support
- [🚧] Python HSU server stubs support
- [🚧] Rust HSU server stubs support
- [🚧] Binary compiler for Python HSUs with help of Nuitka integration support
- [🚧] Code examples and tools - Comprehensive README.md and HSU interfaces examples
- [🚧] HSUs logs collection - HSU's execution status, stdoud and stderr collection by the master process
- [🚧] Local gRPC based HSUs discovery with automatic health checking
- [🚧] URL/port based HSUs discovery
- [🚧] Configuration management - Centralized config distribution and secrets management
- [🚧] New HSUs Scaffolding - Automatic generation of client/server stubs for new gRPC interface
- [🚧] Inbound REST API routing - Standalone API routing HSU with on-call auth and wake-up hooks to master process
- [🚧] Standalone HSU master process - Dedicated master process with HSUs control-only functionality

### Runtime units management:
- [🚧] On-demand HSU installation - Unit download & signature checking
- [🚧] On-demand HSU upgrade - Units upgrade with smart upgrade schedule

### Distributed system orchestration
- [🚧] Authentication support - External IdP and API tokens support
- [🚧] Multi-node coordination - Distributed master processes with leader election
- [🚧] Network mesh - Inter-node communication and load balancing
- [🚧] Centralized HSU units config update - Mass-management and update of the configurations in runtime
- [🚧] Peer-to-peer HSUs binary cache - Optimization for mass HSUs update within a network
- [🚧] HSU crash reports collection - Crash reports upload
- [🚧] System information report collection - Collection of system information for centralized management

### Advanced system orchestration
- [🚧] Auto-scaling - Horizontal scaling based on resource utilization and custom metrics
- [🚧] Advanced orchestration - Rolling deployments, canary releases, A/B testing
- [🚧] Observability platform - Distributed tracing, metrics aggregation, log correlation
- [🚧] Edge-specific features - Offline operation, synchronization, bandwidth optimization
- [🚧] Enterprise features - RBAC, audit logging, compliance reporting

**Legend:**
- ✅ Fully implemented and production-ready
- 🚧 Planned/In development
- ⚠️ Partial implementation
- ❌ Not planned

---

## 📖 **Detailed Documentation Navigation**

### **Implementation Approaches**
- [**Repository Framework**](../repositories/index.md) - Choose your architectural approach
- [**Universal Makefile System**](../makefile_guide/index.md) - Unified build automation
- [**Step-by-Step Tutorials**](../tutorials/index.md) - Hands-on implementation guides

### **Technical Deep Dive**
- [**API Reference**](../reference/api_reference.md) - Complete technical documentation
- [**Protocol Specifications**](../reference/grpc_services.md) - gRPC service definitions
- [**Portability Mechanics**](../repositories/portability-mechanics.md) - How repo-portability works

## 🚀 **Quick Start Options**

### **For Developers**
1. **[Complete Implementation Guide](../tutorials/INTEGRATED_HSU_GUIDE.md)** - Step-by-step tutorials
2. **[Developer Guide](../guides/DEVELOPER_GUIDE.md)** - Development best practices

### **For DevOps Engineers**
1. **[Universal Makefile System](../makefile_guide/index.md)** - Build automation
2. **[Deployment Guides](../deployment/index.md)** - Production deployment
3. **[Configuration Management](../deployment/configuration.md)** - Environment setup

---

**Ready to transform your microservice architecture?** Explore the **[complete implementation tutorials](../tutorials/index.md)**. 
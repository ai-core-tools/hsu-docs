# HSU Microservice Architecture

## Overview

The **Host System Unit (HSU)** architecture provides a clean, pluggable framework for composing larger applications from independent, language-agnostic microservices. This architecture enables lightweight orchestration and management of distributed services in resource-constrained environments.

The core architectural principle divides all services into two primary roles:
- **HSU (Host System Units)** – Standalone processes or services that implement specific functionality within the system
- **Master Processes** – Long-running resident processes responsible for HSU discovery, orchestration, and lifecycle management

The HSU architecture and design principles provides a continuum of integration: from passive observation (Unmanaged Units), to full process lifecycle control (Managed Units), to deep API orchestration (Integrated Units) — making it highly adaptable to real-world hybrid systems, especially in the areas of:

- **Edge Computing and IoT**: Minimal overhead, native process management, offline-ready
- **On-Premises Deployments**: Easily integrates with legacy or system-level processes without requiring containerization
- **Desktop applications**: Native process management for desktop apps, enabling modular plugin architectures and background service coordination
- **AI/ML Workflows**: Enables tight integration with Python/Go-based ML services using gRPC while maintaining process isolation
- **Dev/Test Automation**: Lightweight orchestration of test runners, local servers, and CI agents across diverse platforms
- **Embedded Systems**: Optimized for constrained devices where container runtimes are impractical
- **Custom Platform Runtimes**: Scenarios requiring rich API interaction with runtime-managed services outside the container model


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

---

## Architecture Diagram

![HSU Architecture](./img/hsu-architecture.drawio.svg)

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
| **Orchestration Type**        | Local, embedded orchestration        | Cluster-wide, declarative                | Cluster-wide, imperative + config   | Local only                          |
| **Custom App-Level APIs**     | ✅ Built-in via gRPC                 | ⚠️ Possible via Operator/CRD              | ⚠️ Manual integration needed        | ❌ Not supported                    |
| **Process Management**        | ✅ Native, fine-grained control      | 🚫 Container-only                         | ✅ Mixed (exec + container)         | ✅ Full native control              |
| **Language Agnostic**         | ✅ Full (gRPC, CLI, etc.)            | ✅ via container boundary                 | ✅                                  | ✅                                  |
| **Cross-Platform Support**    | ✅ Native (Linux, Windows, macOS)    | ⚠️ Linux-only control plane, partial Win  | ✅ (Linux/Windows/macOS via plugin) | ⚠️ Linux primary, some BSD support  |
| **Resource Constraints**      | ✅ OS primitives (ulimit, cgroups)   | ✅ Full quota support (cgroups, etc.)     | ✅ via config                       | ⚠️ Manual (`ulimit`, slices)        |
| **Workers Scheduling**        | ✅ Built-in into the master process  | ✅ Core feature                           | ✅ Core feature                     | ❌ No scheduler                     |
| **On-Demand Worker Start**    | ✅ Direct via API or OS process spawn  | ⚠️ Indirect (e.g., scale-to-zero via KEDA) | ✅ via job dispatching               | ⚠️ Indirect via timer/trigger units |
| **System Overhead**           | 🟢 Minimal (single binary master)      | 🔴 High (API server, etcd, controllers)   | 🟡 Moderate (single binary, plugins) | 🟢 Very low (native init daemon)   |
| **Ideal For**                 | Edge, ML, embedded, hybrid systems   | Cloud-native microservices, CI/CD        | General workload orchestration      | Local servers, daemons, dev setups |
| **Complexity / Footprint**    | 🟢 Low                               | 🔴 High                                   | 🟡 Medium                           | 🟢 Very Low                         |


## Repository Layout (suggested)

```
.
├── cmd/                  # Main + sample HSUs
├── proto/                # gRPC contract files
│   ├── hsu_core.proto    # Core API (required)
│   ├── hsu_a.proto       # Feature A API (optional)
│   └── hsu_b.proto       # Feature B API (optional)
├── internal/             # Shared client/server helpers
└── docs/                 # Specs & diagrams
```

---

## Quick Start (demo)

```bash
# 1. Generate Go client stubs (example language)
make gen-go

# 2. Build example HSUs
make build‑example

# 3. Run the main process (will auto‑spawn HSUs on demand)
./bin/main
```

---

## Defining a New Interface for integrated HSUs

1. Drop a new proto in ``.
2. Run `make gen‑all` to regenerate stubs for every target language.
3. Implement an HSU that registers `hsu_xyz`.
4. Add the new client stub to the main process dependency list.

### 📄 Placeholder – gRPC Proto Definition

```proto
// proto/hsu_xyz.proto
syntax = "proto3";
package hsu.xyz;

// TODO: replace with real service definition
service XYZ {
    rpc DoSomething (XYZRequest) returns (XYZResponse);
}
```

---

## Implementing an integrated HSU

### Go Example (implements Core + A)

```go
// cmd/hsu_a_service1/main.go
// TODO: full implementation
func main() {
    // 1. Parse flags & config
    // 2. Register Core and Interface A servers
    // 3. Serve gRPC
}
```

### Python Example (implements Core + B)

```python
# cmd/hsu_b_service1/main.py
# TODO: full implementation
async def serve():
    # 1. Instantiate Core & B servicers
    # 2. Start aio gRPC server
```

### Rust Example (implements Core, A & B)

```rust
// cmd/hsu_abc_service/src/main.rs
// TODO: full implementation using tonic
#[tokio::main]
async fn main() -> Result<(), Box<dyn std::error::Error>> {
    // register services and serve
}
```

---

## Runtime Lifecycle

```mermaid
graph TD
    A[Main process] -- ping/start --> B[HSU process]
    B -- register --> A
    A -- RPC calls --> B
    A -- stop --> B
```

1. **Discovery** – main process checks if an HSU is running, or spawns it.
2. **Handshake** – HSU registers active interfaces via Core API.
3. **Workload** – main invokes RPCs.
4. **Shutdown** – idle HSUs are stopped to free resources.

---

## Extending the System

- **Add a language** – run that language’s gRPC code‑gen tool for all `.proto` files.
- **Swap an implementation** – stop current HSU binary, launch alternative.
- **Compose** – an HSU can expose *multiple* interfaces in one process to save IPC.

---

## Contributing

1. Fork → feature branch → PR.
2. Run `make lint test` before opening a pull request.
3. Describe which interfaces your code changes touch.

---

## License

Apache-2.0

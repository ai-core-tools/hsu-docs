# Creating an Integrated Unit

This comprehensive guide walks you through creating an Integrated Unit process. Choose your path based on your team structure and requirements.

## What is an Integrated Unit?

An Integrated Unit is a process that represents the **highest level of HSU integration**, combining full lifecycle management with deep programmatic integration through gRPC APIs:

- **Complete Lifecycle Management**: Full start, stop, restart, and monitoring control by the master process
- **Core HSU Interface**: Standardized gRPC services for health checks, logging, and graceful shutdown
- **Business API Integration**: Custom gRPC services for domain-specific functionality and business logic
- **Multi-Language Support**: Can be implemented in any language supporting gRPC (Go, Python, Rust, Java, etc.)

Integrated units are ideal for **custom microservices** that need sophisticated orchestration, API-level coordination, and seamless integration with other HSU components.

It is highly-recommended (though optional) that Integrated Unit code should be:
- **Repository Portable**: Work seamlessly across different repository structures
- **Integrated with HSU Make System**: Use standardized HSU make system to build

## Architecture Integration

```
┌─────────────────┐    gRPC APIs     ┌─────────────────┐
│   Master        │◄────────────────►│   Integrated    │
│   Process       │  • Core HSU API  │   Unit          │
│                 │  • Business API  │   (Deep gRPC)   │
│                 │  • Health Checks │                 │
│                 │  • Lifecycle     │                 │
└─────────────────┘                  └─────────────────┘
```

The master process communicates with integrated units through **generated gRPC client stubs**:
- **Core HSU API**: Health checks, graceful shutdown, logging configuration
- **Business API**: Custom domain-specific operations and data processing
- **Lifecycle Management**: Start, stop, restart with coordination through gRPC
- **Service Discovery**: Dynamic registration and discovery of business services

## Implementing Core HSU Interface

Every integrated unit must implement the standardized Core HSU Interface, which provides essential orchestration capabilities:

### Core HSU Service Definition

```protobuf
// Core HSU Interface - must be implemented by all integrated units
service CoreService {
    // Health and status
    rpc Ping(PingRequest) returns (PingResponse);
    rpc GetStatus(GetStatusRequest) returns (GetStatusResponse);
    
    // Lifecycle management
    rpc PrepareShutdown(PrepareShutdownRequest) returns (PrepareShutdownResponse);
    rpc Shutdown(ShutdownRequest) returns (ShutdownResponse);
    
    // Configuration and metrics
    rpc UpdateConfiguration(UpdateConfigurationRequest) returns (UpdateConfigurationResponse);
    rpc GetMetrics(GetMetricsRequest) returns (GetMetricsResponse);
}
```

For Integrated Unit, standard way of implementing the Core HSU Interface is by integrating with [hsu-core](https://github.com/Core-Tools/hsu-core) library. 

**Complete Reference:** [Core API Reference](../../core/reference.md)

## Exposing Business APIs

Beyond the Core HSU Interface, Integrated Unit exposes custom gRPC services for domain-specific functionality:

### Business API Design

```protobuf
// Example: Data Processing Service
service DataProcessingService {
    // Batch operations
    rpc ProcessBatch(ProcessBatchRequest) returns (ProcessBatchResponse);
    rpc GetProcessingStatus(GetProcessingStatusRequest) returns (GetProcessingStatusResponse);
    
    // Stream processing
    rpc ProcessStream(stream ProcessStreamRequest) returns (stream ProcessStreamResponse);
    
    // Configuration
    rpc UpdateProcessingConfig(UpdateProcessingConfigRequest) returns (UpdateProcessingConfigResponse);
}

message ProcessBatchRequest {
    repeated DataItem items = 1;
    ProcessingOptions options = 2;
    string batch_id = 3;
}

message ProcessBatchResponse {
    string batch_id = 1;
    ProcessingStatus status = 2;
    repeated ProcessedItem results = 3;
}
```

### Client Integration

The master process uses generated client stubs to interact with business APIs:

```go
// Master process using integrated unit business API
func (m *HSUMaster) ProcessDataBatch(items []DataItem) error {
    // Get client for data processing service
    client, err := m.getServiceClient("data-processor")
    if err != nil {
        return err
    }
    
    // Call business API
    response, err := client.ProcessBatch(context.Background(), &proto.ProcessBatchRequest{
        Items: items,
        Options: &proto.ProcessingOptions{
            Priority: proto.Priority_HIGH,
            Timeout: 300,
        },
        BatchId: generateBatchID(),
    })
    
    if err != nil {
        return err
    }
    
    m.logger.Infof("Batch processed: %s, status: %s", response.BatchId, response.Status)
    return nil
}
```

**Detailed Guide:** [Protocol Buffers Guide](../../../api/protocol-buffers.md)

## Repository Portable Code

The **Repository Portability** is a practical way to organizing domain-centric code with an ability to move it between different repository structures without modification. 

Traditional approaches of code organization force developers to choose between language-specific tooling OR innovative repository organization. The HSU framework **eliminates this trade-off** by recognizing that code portability comes from **clean logical boundaries and purpose separation** and **consistent and portable import schemes**. This enables seamless migration between repository architectures without code changes.

The HSU framework supports **three repository approaches** of organizing domain-centric code enabling "repo-portability" . **The choice will determine team scaling and deployment flexibility**.

| Repository Approach | Description | Complexity | Best For |
|---------------------|-------------|------------|----------|
| **Approach 1** | Single-Repository + Single-Language | ✅ Simple | New domains, single-language teams |
| **Approach 2** | Single-Repository + Multi-Language | ⚠️ Moderate | Coordinated multi-language development |
| **Approach 3** | Multi-Repository Architecture | ❌ Complex | Large teams, independent scaling |

**Approach 1 - Single Language:**. Best for: Small teams, getting started, language-specific projects
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

**Approach 2 - Multi Language:**. Best for: Full-stack teams, unified deployments, shared protocols
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

**Approach 3 - Multi Repository:**. Best for: Large teams, microservice independence, separate deployment cycles
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

**Detailed description:** [Repository Portability](../../../repositories/index.md)

## Integration with HSU Make System

The HSU Make System is distributed via git submodules from the [canonical repository](https://github.com/core-tools/make). This provides better version control, easier updates, and cleaner project structure.

It provides a number of standard commands to generate API stubs (generate gRPC code from .proto), build all components (binaries, packages), run tests. 

It supports the repository layouts of all repository portability approaches.

```makefile
# Approach 1: Single-language commands
make build          # Build all components
make run-srv        # Run server
make test          # Run tests

# Approach 2: Language-specific commands  
make go-build      # Build Go components
make py-build      # Build Python components  
make go-run-srv    # Run Go server
make py-run-srv    # Run Python server

# Approach 3: Repository-specific commands
make build         # Build current repo
make test-common   # Test shared components
make deploy-srv    # Deploy server implementation
```

**Complete reference:** [HSU Make System](../../make/index.md)

---

## Implementation Steps

### Step 1: Foundation Setup

#### 1.1 Choose Your Repository Approach
- **Single team, one language?** → Approach 1
- **Multi-language coordination?** → Approach 2  
- **Multiple teams, microservices?** → Approach 3

#### 1.2 Set Up Your Environment  
```bash
# Install required tools
go version          # Go 1.22+
python --version    # Python 3.8+ 
protoc --version    # Protocol Buffers compiler
make --version      # GNU Make or compatible
```

### Step 2: Copy Example and Customize

#### 2.1 Copy Working Example
```bash
# For Approach 1 (copy without make system, then add submodule)
cp -r hsu-example1-go/ my-project/
cd my-project/
rm -rf make/  # Remove make directory (will be added as submodule)
git init
git submodule add https://github.com/core-tools/make.git make

# For Approach 2 (copy without make system, then add submodule)
cp -r hsu-example2/ my-project/
cd my-project/
rm -rf make/  # Remove make directory (will be added as submodule)
git init
git submodule add https://github.com/core-tools/make.git make

# For Approach 3 (copy each repository without make system, then add submodules)
cp -r hsu-example3-common/ my-project-common/
cd my-project-common/
rm -rf make/  # Remove make directory (will be added as submodule)
git init
git submodule add https://github.com/core-tools/make.git make

cd ..
cp -r hsu-example3-srv-go/ my-project-srv-go/
cd my-project-srv-go/
rm -rf make/  # Remove make directory (will be added as submodule)
git init
git submodule add https://github.com/core-tools/make.git make
```

#### 2.2 Update Project Configuration
Edit `Makefile.config`:
```makefile
# Project identification
PROJECT_NAME = my-project
MODULE_NAME = github.com/myorg/my-project

# Language support  
ENABLE_GO = 1
ENABLE_PYTHON = 1

# gRPC configuration
PROTO_PATH = api/proto
```

#### 2.3 Test Build
```bash
make clean && make setup && make generate && make build
make test           # Verify everything works
make run-server     # Start your customized server
```

### Step 3: Customize Business Logic

#### 3.1 Define Your Service API
Edit `api/proto/yourservice.proto`:
```protobuf
syntax = "proto3";

package yourservice;
option go_package = "github.com/myorg/my-project/pkg/generated/api/proto";

service YourService {
    rpc YourMethod(YourRequest) returns (YourResponse);
}

message YourRequest {
    string input = 1;
}

message YourResponse {
    string output = 1;
}
```

#### 3.2 Regenerate API Stubs
```bash
make generate       # Updates all generated code
make build          # Verify compilation
```

#### 3.3 Implement Business Logic
- **Go:** Edit `pkg/domain/` and `pkg/control/`
- **Python:** Edit `lib/domain/` and `lib/control/`

### Step 4: Testing and Deployment

#### 4.1 Test Your Implementation
```bash
make test                    # Unit tests
make run-server             # Integration test
make run-client             # End-to-end test
```

#### 4.2 Create Production Build
```bash
make package-binary         # Optimized binaries
make docker                 # Container images
```

#### 4.3 Deploy Your Service

HSU framework currently does not support any type of deployment. 

---

## Examples and Tutorials

Examples and tutorials listed below cover all the three repository approaches standardized in HSU framework.

### Approach 1: Single-Repository + Single-Language

**Working Examples:**
- **[`hsu-example1-go/`](https://github.com/core-tools/hsu-example1-go/)** - Pure Go implementation with full gRPC stack
- **[`hsu-example1-py/`](https://github.com/core-tools/hsu-example1-py/)** - Pure Python implementation with gRPC services

**Tutorial:** [Single-Repository Go Implementation](single-repo-go.md) or [Single-Repository Python Implementation](single-repo-python.md)

### Approach 2: Single-Repository + Multi-Language  

**Working Example:**
- **[`hsu-example2/`](https://github.com/core-tools/hsu-example2/)** - Go and Python services in one repository with shared protocols

**Tutorial:** [Single-Repository Multi-Language Implementation](single-repo-multi-language.md)

### Approach 3: Multi-Repository Architecture

**Working Examples:**
- **[`hsu-example3-common/`](https://github.com/core-tools/hsu-example3-common/)** - Shared protocols and client libraries
- **[`hsu-example3-srv-go/`](https://github.com/core-tools/hsu-example3-srv-go/)** - Go microservice implementation  
- **[`hsu-example3-srv-py/`](https://github.com/core-tools/hsu-example3-srv-py/)** - Python microservice implementation

**Tutorial:** [Multi-Repository Go Implementation](multi-repo-go.md) or [Multi-Repository Python Implementation](multi-repo-python.md)

## Related Reading

- **[Master Process Guide](../../master/index.md)** - Implement master process to orchestrate your integrated units
- **[Unmanaged Units](../unmanaged/index.md)** - Integrate existing processes without modification
- **[Managed Units](../managed/index.md)** - Full lifecycle control of custom processes
- **[HSU Core Reference](../../core/reference.md)** - Available library functions and APIs
- **[HSU Make System](../../make/index.md)** - Integrate HSU Make System

---

*You are here: System > Units > **Integrated Units***

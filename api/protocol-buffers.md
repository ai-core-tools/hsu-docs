# Protocol Buffer Definition Guide

This guide covers setting up Protocol Buffer definitions for HSU services, including service definitions, message types, and code generation for both Go and Python using the HSU Universal Makefile System.

## Overview

Protocol Buffers (protobuf) define the gRPC API contract for your HSU service. This contract is shared between:
- Go implementations
- Python implementations  
- Client applications
- Other services that interact with your HSU

## Step 1: Define Your Service

### Create Protocol Buffer Definition

Create `api/proto/{service}service.proto`:

```proto
syntax = "proto3"

option go_package = "github.com/core-tools/hsu-example2/generated/api/proto";

package proto;

service EchoService {
  rpc Echo(EchoRequest) returns (EchoResponse) {}
}

message EchoRequest {
  string message = 1;
}

message EchoResponse {
  string message = 1;
}
```

### Key Components

- **Service Definition**: Defines the available RPC methods
- **Message Types**: Define request and response structures  
- **Go Package Option**: Specifies the generated Go package path
- **Package Name**: Used for Python imports

## Step 2: Code Generation with Universal Makefile

### Automatic Generation

The HSU Make System handles all code generation automatically:

```bash
# Generate protocol buffer stubs for all languages
make proto

# This automatically generates:
# - Go stubs in go/generated/api/proto/
# - Python stubs in python/generated/api/proto/
```

### Behind the Scenes

The Make System automatically:
1. **Detects available languages** (Go, Python)
2. **Runs appropriate protoc commands** with correct paths
3. **Handles cross-platform differences** (Windows, Linux, macOS)
4. **Applies fix-imports** for Python compatibility

### Manual Generation (Advanced)

If you need custom generation, you can still run protoc manually:

**For Go:**
```bash
cd api/proto
protoc --go_out=../../go/generated/api/proto --go_opt=paths=source_relative \
       --go-grpc_out=../../go/generated/api/proto --go-grpc_opt=paths=source_relative \
       echoservice.proto
```

**For Python:**
```bash
cd api/proto
python -m grpc_tools.protoc -I. --python_out=../../python/generated/api/proto \
    --grpc_python_out=../../python/generated/api/proto echoservice.proto
```

## Step 3: Working Example

### From hsu-example2 (Multi-Language Repository)

**Protocol Definition (`api/proto/echoservice.proto`):**
```proto
syntax = "proto3";

option go_package = "github.com/core-tools/hsu-example2/generated/api/proto";

package proto;

import "coreservice.proto";

service EchoService {
  rpc Echo(EchoRequest) returns (EchoResponse) {}
}

message EchoRequest {
  string message = 1;
}

message EchoResponse {
  string message = 1;
}
```

**Generate code:**
```bash
cd hsu-example2
make proto
```

**Generated files:**
```
hsu-example2/
├── go/generated/api/proto/
│   ├── echoservice.pb.go
│   ├── echoservice_grpc.pb.go
│   └── coreservice.pb.go
└── python/generated/api/proto/
    ├── echoservice_pb2.py
    ├── echoservice_pb2_grpc.py
    └── coreservice_pb2.py
```

### Using Generated Code

**Go Implementation:**
```go
package main

import (
    "github.com/core-tools/hsu-example2/go/generated/api/proto"
)

func (h *EchoHandler) Echo(ctx context.Context, req *proto.EchoRequest) (*proto.EchoResponse, error) {
    return &proto.EchoResponse{
        Message: "go-echo: " + req.Message,
    }, nil
}
```

**Python Implementation:**
```python
from generated.api.proto import echoservice_pb2

def Echo(self, request, context):
    return echoservice_pb2.EchoResponse(
        message=f"py-echo: {request.message}"
    )
```

## Best Practices

### Message Design

```proto
// Use clear, descriptive names
message ProcessDataRequest {
  string data_id = 1;
  repeated string items = 2;
  ProcessingOptions options = 3;
}

// Include version information for evolution
message ProcessingOptions {
  int32 version = 1;
  string algorithm = 2;
  map<string, string> parameters = 3;
}
```

### Service Design

```proto
service DataProcessorService {
  // Use verb-noun naming
  rpc ProcessData(ProcessDataRequest) returns (ProcessDataResponse) {}
  rpc GetStatus(StatusRequest) returns (StatusResponse) {}
  rpc ListResults(ListResultsRequest) returns (ListResultsResponse) {}
}
```

### Backward Compatibility

- **Add new fields** with new field numbers
- **Never remove** existing fields
- **Use optional fields** for new features
- **Consider versioning** for major changes

## Current Directory Structure

### Approach 1: Single-Language Repository
```
hsu-example1-go/
├── api/proto/
│   └── echoservice.proto
├── pkg/generated/api/proto/
│   ├── echoservice.pb.go
│   └── echoservice_grpc.pb.go
└── Makefile
```

### Approach 2: Multi-Language Repository  
```
hsu-example2/
├── api/proto/
│   └── echoservice.proto
├── go/generated/api/proto/
│   ├── echoservice.pb.go
│   └── echoservice_grpc.pb.go
├── python/generated/api/proto/
│   ├── echoservice_pb2.py
│   └── echoservice_pb2_grpc.py
└── Makefile
```

### Approach 3: Multi-Repository
```
hsu-example3-common/
├── api/proto/
│   └── echoservice.proto
├── go/generated/api/proto/
│   ├── echoservice.pb.go
│   └── echoservice_grpc.pb.go
├── python/generated/api/proto/
│   ├── echoservice_pb2.py
│   └── echoservice_pb2_grpc.py
└── Makefile
```

## Makefile Integration

### Available Commands

All HSU repositories support these protocol buffer commands with the HSU Make System:

```bash
# Generate all protocol buffer stubs
make proto

# Clean generated files
make proto-clean  

# In multi-language repositories:
make go-proto      # Generate Go stubs only
make py-proto      # Generate Python stubs only
```

### Makefile Configuration

The makefile automatically detects:
- **Available languages** in your repository
- **Protocol buffer files** in `api/proto/`  
- **Target directories** for generated code
- **Required protoc plugins** and dependencies

## Prerequisites

### Tool Installation

The HSU Make System handles most setup, but you may need:

**For Go:**
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

**For Python:**
```bash
pip install grpcio-tools
```

**Protocol Buffers Compiler:**
- **Linux**: `sudo apt install protobuf-compiler`
- **macOS**: `brew install protobuf`
- **Windows**: Download from [Protocol Buffers releases](https://github.com/protocolbuffers/protobuf/releases)

### Verification

Test your setup:
```bash
# In any hsu-example* directory
make setup      # Install dependencies
make proto      # Generate protocol buffers
make build      # Build with generated code
```

## Troubleshooting

### Common Issues

**`protoc: command not found`**
- Install Protocol Buffers compiler and ensure it's in PATH

**`protoc-gen-go: program not found`**  
- Run: `go install google.golang.org/protobuf/cmd/protoc-gen-go@latest`
- Ensure `$GOPATH/bin` is in PATH

**Python import errors**
- Run: `make proto` to regenerate with correct import fixes
- Check that generated files are in correct directory structure

**Go import path issues**
- Verify `go_package` option matches your module structure
- Use replace directives if needed for local development

### Debug Generation

Enable verbose protoc output:
```bash
# See what commands the makefile runs
make proto VERBOSE=1

# Manual verification
cd api/proto && protoc --version
```

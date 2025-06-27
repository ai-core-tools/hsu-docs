# HSU Protocol Buffer Definition Guide

This guide covers setting up Protocol Buffer definitions for HSU services, including service definitions, message types, and code generation for both Go and Python.

## Overview

Protocol Buffers (protobuf) define the gRPC API contract for your HSU service. This contract is shared between:
- Go implementations
- Python implementations  
- Client applications
- Other services that interact with your HSU

## Step 1: Define Your Service

### Create Protocol Buffer Definition

Create `api/proto/{domain}service.proto`:

```proto
syntax = "proto3";

option go_package = "github.com/core-tools/hsu-{domain}/api/proto";

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

## Step 2: Code Generation

### For Go

Create `api/proto/generate-go.sh`:

```bash
#!/bin/bash
protoc --go_out=../../go/api/proto --go_opt=paths=source_relative \
       --go-grpc_out=../../go/api/proto --go-grpc_opt=paths=source_relative \
       {domain}service.proto
```

Create `api/proto/generate-go.bat` (Windows):

```batch
@echo off
protoc --go_out=../../go/api/proto --go_opt=paths=source_relative ^
       --go-grpc_out=../../go/api/proto --go-grpc_opt=paths=source_relative ^
       {domain}service.proto
```

### For Python

Create `api/proto/generate-py.sh`:

```bash
#!/bin/bash
python -m grpc_tools.protoc -I. --python_out=../../py/api/proto \
    --grpc_python_out=../../py/api/proto {domain}service.proto
```

Create `api/proto/generate-py.bat` (Windows):

```batch
@echo off
python -m grpc_tools.protoc -I. --python_out=../../py/api/proto ^
    --grpc_python_out=../../py/api/proto {domain}service.proto
```

## Step 3: Generate Code

### Prerequisites

**For Go:**
```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

**For Python:**
```bash
pip install grpcio-tools
```

### Run Generation

```bash
cd api/proto

# For Go
chmod +x generate-go.sh
./generate-go.sh

# For Python  
chmod +x generate-py.sh
./generate-py.sh
```

## Step 4: Generated Files

### Go Generated Files

- `go/api/proto/{domain}service.pb.go` - Message types
- `go/api/proto/{domain}service_grpc.pb.go` - gRPC service definitions

### Python Generated Files

- `py/api/proto/{domain}service_pb2.py` - Message types
- `py/api/proto/{domain}service_pb2_grpc.py` - gRPC service definitions

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

## Directory Structure

```
your-hsu-domain/
├── api/
│   └── proto/
│       ├── {domain}service.proto
│       ├── generate-go.sh
│       ├── generate-go.bat  
│       ├── generate-py.sh
│       └── generate-py.bat
├── go/
│   └── api/
│       └── proto/
│           ├── {domain}service.pb.go
│           └── {domain}service_grpc.pb.go
└── py/
    └── api/
        └── proto/
            ├── {domain}service_pb2.py
            └── {domain}service_pb2_grpc.py
```

## Next Steps

- [Go Implementation Guide](HSU_GO_IMPLEMENTATION.md) - Implement Go servers
- [Python Implementation Guide](HSU_PYTHON_IMPLEMENTATION.md) - Implement Python servers
- [gRPC Services Documentation](GRPC_SERVICES.md) - Advanced gRPC patterns 
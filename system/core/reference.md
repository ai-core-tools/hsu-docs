# Core API Reference

This document provides a reference documentation for the core APIs, including both core services and implementation patterns.

## Table of Contents

- [Core APIs](#core-hsu-apis)
- [Core Libraries](#core-libraries)
- [Example Services](#example-services)
- [Client Libraries](#client-libraries)
- [Process Management](#process-management)
- [Error Handling](#error-handling)

## Core APIs

### CoreService (gRPC)

The core service that every unit must implement for health checking and basic lifecycle management.

**Proto Definition:**
```proto
service CoreService {
  rpc Ping(PingRequest) returns (PingResponse) {}
}

message PingRequest {}
message PingResponse {}
```

**Go Implementation:**
```go
type Contract interface {
    Ping(ctx context.Context) error
}
```

**Usage:**
- **Health Checks**: Master processes use Ping to verify unit availability
- **Service Discovery**: Confirms unit is ready to accept requests
- **Load Balancing**: Helps determine which HSUs are available for work

## Core Libraries

### Go Libraries (`hsu-core/go/`)

#### Control Package
- **Server Creation**: `NewServer(options ServerOptions, logger logging.Logger) (Server, error)`
- **Client Connection**: `NewConnection(options ConnectionOptions, logger logging.Logger) (Connection, error)`
- **Service Registration**: `RegisterGRPCServerHandler(server grpc.ServiceRegistrar, handler interface{}, logger logging.Logger)`

#### Process Package
- **Process Control**: `NewController(path string, args []string, retryPeriod time.Duration, logConfig ControllerLogConfig) (Controller, error)`
- **Features**: Automatic restart, output capture, cross-platform support

### Python Libraries (`hsu-core/py/`)

#### Control Package
- **Server**: `Server(port: int)` with `GRPC()` and `run()` methods
- **Handler Registration**: `register_grpc_default_server_handler(server: grpc.Server)`

## Current Implementation Status

✅ **Working Features**:
- Basic gRPC server/client infrastructure
- Process lifecycle management
- Health checking (Ping service)
- Cross-platform process control
- Go and Python support

🚧 **In Development**:
- Advanced configuration management
- Service discovery beyond basic health checks
- Load balancing algorithms

## Example Services

### EchoService

A simple service demonstrating basic unit patterns.

**Proto Definition:**
```proto
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

**Go Implementation:**
```go
type Handler interface {
    Echo(ctx context.Context, message string) (string, error)
}

func NewGRPCClientGateway(grpcClientConnection grpc.ClientConnInterface, logger logging.Logger) Handler
```

**Python Implementation:**
```python
class EchoServicer(echoservice_pb2_grpc.EchoServiceServicer):
    def Echo(self, request, context):
        return echoservice_pb2.EchoResponse(message=request.message)
```

## Client Libraries

### Go Client Pattern

```go
// 1. Create connection
connectionOptions := coreControl.ConnectionOptions{
    ServerPath: "/path/to/server",  // Optional: spawn server
    AttachPort: 50051,              // Optional: connect to existing
}
connection, err := coreControl.NewConnection(connectionOptions, logger)

// 2. Create client gateways
coreGateway := coreControl.NewGRPCClientGateway(connection.GRPC(), logger)
businessGateway := businessControl.NewGRPCClientGateway(connection.GRPC(), logger)

// 3. Health check with retry
retryOptions := coreDomain.RetryPingOptions{
    RetryAttempts: 10,
    RetryInterval: 1 * time.Second,
}
err = coreDomain.RetryPing(ctx, coreGateway, retryOptions, logger)

// 4. Use business logic
result, err := businessGateway.DoSomething(ctx, "input")
```

### Python Client Pattern

```python
import grpc
from hsu_core.py.api.proto import coreservice_pb2_grpc, coreservice_pb2
from business.api.proto import businessservice_pb2_grpc, businessservice_pb2

# 1. Create connection
with grpc.insecure_channel('localhost:50051') as channel:
    # 2. Create clients
    core_client = coreservice_pb2_grpc.CoreServiceStub(channel)
    business_client = businessservice_pb2_grpc.BusinessServiceStub(channel)
    
    # 3. Health check
    core_client.Ping(coreservice_pb2.PingRequest())
    
    # 4. Use business logic
    response = business_client.DoSomething(businessservice_pb2.Request(data="input"))
```

## Process Management

### Master Process Responsibilities

**Process Lifecycle:**
```go
type HSUWorker struct {
    ID         string
    Port       int
    Controller process.Controller
    Gateway    domain.Contract
    Status     string
}

// Start worker
func (m *HSUMaster) startWorker(workerID string) error {
    // 1. Find free port
    port, err := freeport.GetFreePort()
    
    // 2. Start process
    controller, err := process.NewController(executablePath, args, retryPeriod, logConfig)
    
    // 3. Create connection
    connection, err := control.NewConnection(connectionOptions, logger)
    
    // 4. Health check
    gateway := control.NewGRPCClientGateway(connection.GRPC(), logger)
    err = domain.RetryPing(ctx, gateway, retryOptions, logger)
    
    // 5. Register worker
    worker := HSUWorker{ID: workerID, Port: port, Controller: controller, Gateway: gateway}
    
    return nil
}
```

**Health Monitoring:**
```go
func (m *HSUMaster) healthCheckWorkers() {
    for _, worker := range m.workers {
        ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
        err := worker.Gateway.Ping(ctx)
        cancel()
        
        if err != nil {
            // Mark unhealthy, potentially restart
            worker.Status = "unhealthy"
        } else {
            worker.Status = "running"
        }
    }
}
```
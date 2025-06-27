# Working with gRPC Services

This guide covers best practices for defining, implementing, and using gRPC services in the HSU platform.

## Protocol Buffers Best Practices

### Service Definition Structure

```proto
syntax = "proto3";

option go_package = "github.com/yourorg/your-hsu/api/proto";
package proto;

// Service definition
service YourBusinessService {
  rpc ProcessData(ProcessDataRequest) returns (ProcessDataResponse) {}
  rpc GetStatus(GetStatusRequest) returns (GetStatusResponse) {}
}

message ProcessDataRequest {
  string data = 1;
  ProcessingOptions options = 2;
}

message ProcessDataResponse {
  string result = 1;
  bool success = 2;
  string error_message = 3;
}
```

### Naming Conventions

**Services:**
- Use `Service` suffix: `DataProcessorService`, `ModelManagerService`
- Use PascalCase: `MyBusinessService`

**Methods:**
- Use verb-noun pattern: `ProcessData`, `GetStatus`, `DeleteUser`
- Use PascalCase

**Messages:**
- Use `Request`/`Response` suffixes for RPC messages
- Use PascalCase for message names
- Use snake_case for field names

## Code Generation

### Go Code Generation

Create a generation script `generate.sh`:

```bash
#!/bin/bash
set -e

PROTO_DIR="api/proto"
OUT_DIR="api/proto"

# Generate Go code
protoc \
  --proto_path=${PROTO_DIR} \
  --go_out=${OUT_DIR} \
  --go_opt=paths=source_relative \
  --go-grpc_out=${OUT_DIR} \
  --go-grpc_opt=paths=source_relative \
  ${PROTO_DIR}/*.proto

echo "✓ Go code generated successfully"
```

### Python Code Generation

```bash
#!/bin/bash
set -e

PROTO_DIR="api/proto"
OUT_DIR="api/proto"

# Generate Python code
python -m grpc_tools.protoc \
  --proto_path=${PROTO_DIR} \
  --python_out=${OUT_DIR} \
  --grpc_python_out=${OUT_DIR} \
  ${PROTO_DIR}/*.proto

echo "✓ Python code generated successfully"
```

## Server Implementation

### Go Server Pattern

```go
package main

import (
    "context"
    "fmt"
    
    "github.com/yourorg/your-hsu/api/proto"
    coreControl "github.com/core-tools/hsu-core/go/control"
    coreDomain "github.com/core-tools/hsu-core/go/domain"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
)

type BusinessHandler struct {
    proto.UnimplementedYourBusinessServiceServer
    logger coreLogging.Logger
}

func NewBusinessHandler(logger coreLogging.Logger) *BusinessHandler {
    return &BusinessHandler{logger: logger}
}

func (h *BusinessHandler) ProcessData(ctx context.Context, req *proto.ProcessDataRequest) (*proto.ProcessDataResponse, error) {
    h.logger.Infof("Processing data: %s", req.Data)
    
    // Validate input
    if req.Data == "" {
        return &proto.ProcessDataResponse{
            Success: false,
            ErrorMessage: "data cannot be empty",
        }, nil
    }
    
    // Process data
    result := fmt.Sprintf("Processed: %s", req.Data)
    
    return &proto.ProcessDataResponse{
        Result:  result,
        Success: true,
    }, nil
}

// Main server setup
func main() {
    // Create server
    server, err := coreControl.NewServer(
        coreControl.ServerOptions{Port: 50051}, 
        logger,
    )
    if err != nil {
        log.Fatalf("Failed to create server: %v", err)
    }
    
    // Register core services (required)
    coreHandler := coreDomain.NewDefaultHandler(logger)
    coreControl.RegisterGRPCServerHandler(server.GRPC(), coreHandler, logger)
    
    // Register business services
    businessHandler := NewBusinessHandler(logger)
    proto.RegisterYourBusinessServiceServer(server.GRPC(), businessHandler)
    
    // Start server
    server.Run(func() {
        log.Println("Server shutting down...")
    })
}
```

## Client Implementation

### Go Client Pattern

```go
package main

import (
    "context"
    "log"
    "time"
    
    "github.com/yourorg/your-hsu/api/proto"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

func main() {
    // Connect to server
    conn, err := grpc.Dial(
        "localhost:50051", 
        grpc.WithTransportCredentials(insecure.NewCredentials()),
    )
    if err != nil {
        log.Fatalf("Failed to connect: %v", err)
    }
    defer conn.Close()
    
    // Create client
    client := proto.NewYourBusinessServiceClient(conn)
    
    // Make request with timeout
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    
    response, err := client.ProcessData(ctx, &proto.ProcessDataRequest{
        Data: "test data",
    })
    if err != nil {
        log.Fatalf("ProcessData failed: %v", err)
    }
    
    if response.Success {
        log.Printf("Result: %s", response.Result)
    } else {
        log.Printf("Error: %s", response.ErrorMessage)
    }
}
```

## Error Handling

Use proper gRPC status codes:

```go
import (
    "google.golang.org/grpc/codes"
    "google.golang.org/grpc/status"
)

func (h *BusinessHandler) ProcessData(ctx context.Context, req *proto.ProcessDataRequest) (*proto.ProcessDataResponse, error) {
    // Validate input
    if req.Data == "" {
        return nil, status.Error(codes.InvalidArgument, "data cannot be empty")
    }
    
    // Handle business logic errors
    result, err := h.processBusinessLogic(req.Data)
    if err != nil {
        h.logger.Errorf("Business logic failed: %v", err)
        return nil, status.Error(codes.Internal, "processing failed")
    }
    
    return &proto.ProcessDataResponse{
        Result:  result,
        Success: true,
    }, nil
}
```

## Testing

### Unit Testing

```go
func TestBusinessHandler_ProcessData(t *testing.T) {
    logger := &mockLogger{}
    handler := NewBusinessHandler(logger)
    
    tests := []struct {
        name    string
        request *proto.ProcessDataRequest
        want    *proto.ProcessDataResponse
        wantErr bool
    }{
        {
            name: "valid data",
            request: &proto.ProcessDataRequest{Data: "test"},
            want: &proto.ProcessDataResponse{
                Result: "Processed: test",
                Success: true,
            },
        },
        {
            name: "empty data",
            request: &proto.ProcessDataRequest{Data: ""},
            want: &proto.ProcessDataResponse{
                Success: false,
                ErrorMessage: "data cannot be empty",
            },
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            got, err := handler.ProcessData(context.Background(), tt.request)
            if (err != nil) != tt.wantErr {
                t.Errorf("ProcessData() error = %v, wantErr %v", err, tt.wantErr)
                return
            }
            if !reflect.DeepEqual(got, tt.want) {
                t.Errorf("ProcessData() = %v, want %v", got, tt.want)
            }
        })
    }
}
```

## Best Practices

1. **Design APIs First**: Define clear, versioned APIs before implementation
2. **Use Appropriate Timeouts**: Always set context timeouts
3. **Handle Errors Gracefully**: Use proper gRPC status codes
4. **Implement Health Checks**: Always provide health endpoints
5. **Log Appropriately**: Use structured logging with context
6. **Test Thoroughly**: Unit and integration tests for all services

## Next Steps

- [API Reference](API_REFERENCE.md) - Complete API documentation
- [Testing and Debugging](TESTING_DEBUGGING.md) - Advanced testing strategies
- [Multi-Language Support](MULTI_LANGUAGE.md) - Cross-language implementations 
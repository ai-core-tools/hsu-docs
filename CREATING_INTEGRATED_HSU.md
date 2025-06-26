# Creating an Integrated HSU

This guide walks you through creating an Integrated HSU process that implements both core HSU functionality and custom business logic through gRPC APIs.

## Overview

An Integrated HSU is a process that:
- **Implements Core HSU Interface**: Provides health checks, logging, and lifecycle management
- **Exposes Business APIs**: Custom gRPC services for domain-specific functionality
- **Self-Manages**: Handles graceful startup and shutdown
- **Integrates Deeply**: Communicates with master processes through type-safe gRPC APIs

## Prerequisites

- Go 1.22+ or Python 3.8+ installed
- Basic understanding of gRPC and Protocol Buffers
- Familiarity with the HSU platform concepts

## Architecture

```
┌─────────────────────────────────────────────────────────────┐
│                  Integrated HSU Process                     │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    ┌──────────────────────────────┐   │
│  │   Core gRPC     │    │   Business Logic gRPC        │   │
│  │   Services      │    │   Services                   │   │
│  │                 │    │                              │   │
│  │ • Ping/Health   │    │ • Domain APIs                │   │
│  │ • Lifecycle     │    │ • Custom Operations          │   │
│  │ • Logging       │    │ • Data Processing            │   │
│  └─────────────────┘    └──────────────────────────────┘   │
│           │                          │                     │
│           └──────────────────────────┼─────────────────────┤
│                                      │                     │
│  ┌─────────────────────────────────────────────────────────┤
│  │              gRPC Server                               │
│  │         (Single Port, Multiple Services)               │
│  └─────────────────────────────────────────────────────────┤
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Option 1: Go Implementation

### Step 1: Project Setup

```bash
mkdir my-integrated-hsu
cd my-integrated-hsu
go mod init github.com/yourorg/my-integrated-hsu
```

Add dependencies:

```bash
go get github.com/core-tools/hsu-core
go get github.com/jessevdk/go-flags
go get google.golang.org/grpc
go get google.golang.org/protobuf/cmd/protoc-gen-go
go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
```

### Step 2: Define Your Business gRPC Service

Create `api/proto/dataprocessor.proto`:

```proto
syntax = "proto3";

option go_package = "github.com/yourorg/my-integrated-hsu/api/proto";

package proto;

// Business logic service
service DataProcessorService {
  rpc ProcessBatch(ProcessBatchRequest) returns (ProcessBatchResponse) {}
  rpc GetMetrics(GetMetricsRequest) returns (GetMetricsResponse) {}
  rpc ConfigureProcessor(ConfigureRequest) returns (ConfigureResponse) {}
}

message ProcessBatchRequest {
  repeated DataItem items = 1;
  ProcessingOptions options = 2;
}

message DataItem {
  string id = 1;
  bytes data = 2;
  map<string, string> metadata = 3;
}

message ProcessingOptions {
  int32 batch_size = 1;
  bool async_mode = 2;
  string output_format = 3;
}

message ProcessBatchResponse {
  repeated ProcessedItem results = 1;
  ProcessingStats stats = 2;
}

message ProcessedItem {
  string id = 1;
  bytes processed_data = 2;
  bool success = 3;
  string error_message = 4;
}

message ProcessingStats {
  int32 total_processed = 1;
  int32 successful = 2;
  int32 failed = 3;
  float processing_time_seconds = 4;
}

message GetMetricsRequest {}

message GetMetricsResponse {
  int64 total_batches_processed = 1;
  int64 total_items_processed = 2;
  float average_processing_time = 3;
  string uptime = 4;
}

message ConfigureRequest {
  map<string, string> config = 1;
}

message ConfigureResponse {
  bool success = 1;
  string message = 2;
}
```

Generate Go code:

```bash
mkdir -p api/proto
cd api/proto
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       dataprocessor.proto
```

### Step 3: Implement Business Logic

Create `internal/domain/processor.go`:

```go
package domain

import (
    "context"
    "fmt"
    "sync"
    "sync/atomic"
    "time"

    "github.com/yourorg/my-integrated-hsu/api/proto"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
)

type DataProcessorHandler struct {
    proto.UnimplementedDataProcessorServiceServer
    logger            coreLogging.Logger
    config            map[string]string
    configMutex       sync.RWMutex
    
    // Metrics
    totalBatches      int64
    totalItems        int64
    totalProcessingTime float64
    startTime         time.Time
}

func NewDataProcessorHandler(logger coreLogging.Logger) *DataProcessorHandler {
    return &DataProcessorHandler{
        logger:    logger,
        config:    make(map[string]string),
        startTime: time.Now(),
    }
}

func (h *DataProcessorHandler) ProcessBatch(ctx context.Context, req *proto.ProcessBatchRequest) (*proto.ProcessBatchResponse, error) {
    startTime := time.Now()
    h.logger.Infof("Processing batch with %d items", len(req.Items))

    results := make([]*proto.ProcessedItem, 0, len(req.Items))
    successful := int32(0)
    failed := int32(0)

    for _, item := range req.Items {
        processedItem, err := h.processItem(item, req.Options)
        if err != nil {
            h.logger.Errorf("Failed to process item %s: %v", item.Id, err)
            processedItem = &proto.ProcessedItem{
                Id:           item.Id,
                Success:      false,
                ErrorMessage: err.Error(),
            }
            failed++
        } else {
            successful++
        }
        results = append(results, processedItem)
    }

    processingTime := time.Since(startTime)
    
    // Update metrics
    atomic.AddInt64(&h.totalBatches, 1)
    atomic.AddInt64(&h.totalItems, int64(len(req.Items)))
    
    stats := &proto.ProcessingStats{
        TotalProcessed:        int32(len(req.Items)),
        Successful:           successful,
        Failed:               failed,
        ProcessingTimeSeconds: float32(processingTime.Seconds()),
    }

    h.logger.Infof("Batch processed: %d successful, %d failed, %.2fs", 
        successful, failed, processingTime.Seconds())

    return &proto.ProcessBatchResponse{
        Results: results,
        Stats:   stats,
    }, nil
}

func (h *DataProcessorHandler) processItem(item *proto.DataItem, options *proto.ProcessingOptions) (*proto.ProcessedItem, error) {
    // Simulate processing based on options
    if options.AsyncMode {
        // Simulate async processing
        time.Sleep(10 * time.Millisecond)
    } else {
        // Simulate sync processing
        time.Sleep(50 * time.Millisecond)
    }

    // Simple processing: reverse the data
    processedData := make([]byte, len(item.Data))
    for i, b := range item.Data {
        processedData[len(item.Data)-1-i] = b
    }

    return &proto.ProcessedItem{
        Id:            item.Id,
        ProcessedData: processedData,
        Success:       true,
    }, nil
}

func (h *DataProcessorHandler) GetMetrics(ctx context.Context, req *proto.GetMetricsRequest) (*proto.GetMetricsResponse, error) {
    totalBatches := atomic.LoadInt64(&h.totalBatches)
    totalItems := atomic.LoadInt64(&h.totalItems)
    uptime := time.Since(h.startTime)

    var avgProcessingTime float32
    if totalBatches > 0 {
        avgProcessingTime = float32(h.totalProcessingTime / float64(totalBatches))
    }

    return &proto.GetMetricsResponse{
        TotalBatchesProcessed: totalBatches,
        TotalItemsProcessed:   totalItems,
        AverageProcessingTime: avgProcessingTime,
        Uptime:               uptime.String(),
    }, nil
}

func (h *DataProcessorHandler) ConfigureProcessor(ctx context.Context, req *proto.ConfigureRequest) (*proto.ConfigureResponse, error) {
    h.configMutex.Lock()
    defer h.configMutex.Unlock()

    h.logger.Infof("Updating configuration with %d settings", len(req.Config))
    
    for key, value := range req.Config {
        h.config[key] = value
        h.logger.Debugf("Config: %s = %s", key, value)
    }

    return &proto.ConfigureResponse{
        Success: true,
        Message: fmt.Sprintf("Updated %d configuration settings", len(req.Config)),
    }, nil
}
```

### Step 4: Create the Main HSU Process

Create `cmd/dataprocessor/main.go`:

```go
package main

import (
    "fmt"
    "os"

    coreControl "github.com/core-tools/hsu-core/go/control"
    coreDomain "github.com/core-tools/hsu-core/go/domain"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
    
    "github.com/yourorg/my-integrated-hsu/api/proto"
    "github.com/yourorg/my-integrated-hsu/internal/domain"
    "github.com/yourorg/my-integrated-hsu/internal/logging"

    flags "github.com/jessevdk/go-flags"
)

type flagOptions struct {
    Port int `long:"port" description:"port to listen on" default:"50052"`
}

func main() {
    var opts flagOptions
    var parser = flags.NewParser(&opts, flags.HelpFlag)
    
    _, err := parser.ParseArgs(os.Args[1:])
    if err != nil {
        fmt.Printf("Command line flags parsing failed: %v\n", err)
        os.Exit(1)
    }

    logger := logging.NewSprintfLogger()
    logger.Infof("Starting Data Processor HSU on port %d", opts.Port)

    // Create core logger
    coreLogger := coreLogging.NewLogger(
        "dataprocessor.core", coreLogging.LogFuncs{
            Debugf: logger.Debugf,
            Infof:  logger.Infof,
            Warnf:  logger.Warnf,
            Errorf: logger.Errorf,
        })

    // Create business logger
    businessLogger := coreLogging.NewLogger(
        "dataprocessor.business", coreLogging.LogFuncs{
            Debugf: logger.Debugf,
            Infof:  logger.Infof,
            Warnf:  logger.Warnf,
            Errorf: logger.Errorf,
        })

    // Create gRPC server
    serverOptions := coreControl.ServerOptions{
        Port: opts.Port,
    }
    
    server, err := coreControl.NewServer(serverOptions, coreLogger)
    if err != nil {
        logger.Errorf("Failed to create server: %v", err)
        os.Exit(1)
    }

    // Register core HSU services
    coreHandler := coreDomain.NewDefaultHandler(coreLogger)
    coreControl.RegisterGRPCServerHandler(server.GRPC(), coreHandler, coreLogger)

    // Register business logic services
    businessHandler := domain.NewDataProcessorHandler(businessLogger)
    proto.RegisterDataProcessorServiceServer(server.GRPC(), businessHandler)

    logger.Infof("Data Processor HSU started successfully")
    
    // Start server (blocks until shutdown)
    server.Run(func() {
        logger.Infof("Data Processor HSU shutting down...")
    })
}
```

### Step 5: Add Logging Support

Create `internal/logging/logger.go`:

```go
package logging

import (
    "log"
)

type SprintfLogger struct{}

func NewSprintfLogger() *SprintfLogger {
    return &SprintfLogger{}
}

func (l *SprintfLogger) Debugf(format string, args ...interface{}) {
    log.Printf("[DEBUG] "+format, args...)
}

func (l *SprintfLogger) Infof(format string, args ...interface{}) {
    log.Printf("[INFO] "+format, args...)
}

func (l *SprintfLogger) Warnf(format string, args ...interface{}) {
    log.Printf("[WARN] "+format, args...)
}

func (l *SprintfLogger) Errorf(format string, args ...interface{}) {
    log.Printf("[ERROR] "+format, args...)
}
```

### Step 6: Build and Test

Create `Makefile`:

```makefile
.PHONY: build run test clean proto

proto:
	cd api/proto && protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative \
		dataprocessor.proto

build: proto
	go build -o bin/dataprocessor cmd/dataprocessor/*.go

run: build
	./bin/dataprocessor --port 50052

test: build
	go run examples/client/main.go

clean:
	rm -rf bin/
```

Create a test client in `examples/client/main.go`:

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "github.com/yourorg/my-integrated-hsu/api/proto"
    coreProto "github.com/core-tools/hsu-core/go/api/proto"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
)

func main() {
    // Connect to HSU
    conn, err := grpc.Dial("localhost:50052", grpc.WithTransportCredentials(insecure.NewCredentials()))
    if err != nil {
        log.Fatalf("Failed to connect: %v", err)
    }
    defer conn.Close()

    // Test core service (health check)
    coreClient := coreProto.NewCoreServiceClient(conn)
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()

    _, err = coreClient.Ping(ctx, &coreProto.PingRequest{})
    if err != nil {
        log.Fatalf("Core ping failed: %v", err)
    }
    fmt.Println("✓ Core service health check passed")

    // Test business service
    businessClient := proto.NewDataProcessorServiceClient(conn)
    
    // Test metrics
    metrics, err := businessClient.GetMetrics(ctx, &proto.GetMetricsRequest{})
    if err != nil {
        log.Fatalf("GetMetrics failed: %v", err)
    }
    fmt.Printf("✓ Initial metrics: batches=%d, items=%d\n", 
        metrics.TotalBatchesProcessed, metrics.TotalItemsProcessed)

    // Test configuration
    _, err = businessClient.ConfigureProcessor(ctx, &proto.ConfigureRequest{
        Config: map[string]string{
            "batch_size": "100",
            "timeout":    "30s",
        },
    })
    if err != nil {
        log.Fatalf("ConfigureProcessor failed: %v", err)
    }
    fmt.Println("✓ Configuration updated")

    // Test data processing
    batchReq := &proto.ProcessBatchRequest{
        Items: []*proto.DataItem{
            {Id: "item1", Data: []byte("hello world"), Metadata: map[string]string{"type": "text"}},
            {Id: "item2", Data: []byte("test data"), Metadata: map[string]string{"type": "test"}},
        },
        Options: &proto.ProcessingOptions{
            BatchSize:    2,
            AsyncMode:    false,
            OutputFormat: "json",
        },
    }

    batchResp, err := businessClient.ProcessBatch(ctx, batchReq)
    if err != nil {
        log.Fatalf("ProcessBatch failed: %v", err)
    }

    fmt.Printf("✓ Batch processed: %d successful, %d failed\n", 
        batchResp.Stats.Successful, batchResp.Stats.Failed)

    for _, result := range batchResp.Results {
        if result.Success {
            fmt.Printf("  Item %s: %s\n", result.Id, string(result.ProcessedData))
        } else {
            fmt.Printf("  Item %s: ERROR - %s\n", result.Id, result.ErrorMessage)
        }
    }

    fmt.Println("✓ All tests passed!")
}
```

## Best Practices

1. **Implement Both Core and Business APIs**: Always provide core HSU functionality alongside your business logic
2. **Handle Graceful Shutdown**: Respond properly to shutdown signals from master processes
3. **Provide Health Checks**: Implement meaningful health checks that reflect your service's actual state
4. **Use Structured Logging**: Log important events and errors for debugging and monitoring
5. **Handle Configuration**: Support runtime configuration updates where appropriate
6. **Metrics and Monitoring**: Expose useful metrics about your service's performance

## Next Steps

- [Working with gRPC Services](GRPC_SERVICES.md) - Advanced gRPC patterns and best practices
- [Multi-Language Support](MULTI_LANGUAGE.md) - Implementing HSUs in different languages
- [Testing and Debugging](TESTING_DEBUGGING.md) - Testing strategies and debugging techniques

## Troubleshooting

### Common Issues

1. **gRPC service registration conflicts**: Ensure unique service names
2. **Port binding failures**: Check if ports are already in use
3. **Proto compilation errors**: Verify proto syntax and import paths
4. **Import path issues**: Check Go module paths and Python sys.path

### Debugging

Enable gRPC debug logging:

**Go:**
```bash
GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info ./bin/dataprocessor
``` 
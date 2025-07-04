# Creating a Master Process

This guide walks you through creating an Master Process that can orchestrate and manage other HSUs in your system.

## Overview

A Master Process is responsible for:
- **Service Discovery**: Finding and connecting to HSU services
- **Process Lifecycle Management**: Starting, stopping, and monitoring HSU processes
- **Health Monitoring**: Checking service health and handling failures
- **Load Balancing**: Distributing work across multiple HSU instances
- **API Gateway**: Routing requests to appropriate HSU services

HSU Core library is called to support all these features. See [Core Reference](../core/reference.md) to details on the status of each specific feature. The guide below reflects the current state: some features not yet implemented in the library, need to be implemented in the master process itself. 

## Step 1: Project Setup

Create a new directory for your master process:

```bash
mkdir my-hsu-master
cd my-hsu-master
go mod init github.com/yourorg/my-hsu-master
```

Add the required dependencies:

```bash
go get github.com/core-tools/hsu-core
go get github.com/jessevdk/go-flags
go get github.com/phayes/freeport
go get google.golang.org/grpc
go get google.golang.org/protobuf/cmd/protoc-gen-go
go get google.golang.org/grpc/cmd/protoc-gen-go-grpc
```

## Step 2: Define Your gRPC Services

Create your service proto definition in `api/proto/myservice.proto`:

```proto
syntax = "proto3";

option go_package = "github.com/yourorg/my-hsu-master/api/proto";

package proto;

// Your custom business service
service MyBusinessService {
  rpc ProcessData(ProcessRequest) returns (ProcessResponse) {}
  rpc GetStatus(StatusRequest) returns (StatusResponse) {}
}

message ProcessRequest {
  string data = 1;
  int32 priority = 2;
}

message ProcessResponse {
  string result = 1;
  bool success = 2;
}

message StatusRequest {}

message StatusResponse {
  string status = 1;
  int64 processed_count = 2;
}
```

Generate Go code from the proto:

```bash
# Create generate script
mkdir -p api/proto
cd api/proto

# Generate Go stubs
protoc --go_out=. --go_opt=paths=source_relative \
       --go-grpc_out=. --go-grpc_opt=paths=source_relative \
       myservice.proto
```

## Step 3: Implement the Master Process Core

Create `cmd/master/main.go`:

```go
package main

import (
    "fmt"
    "os"

    coreControl "github.com/core-tools/hsu-core/go/control"
    coreDomain "github.com/core-tools/hsu-core/go/domain"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
    "github.com/yourorg/my-hsu-master/internal/domain"
    "github.com/yourorg/my-hsu-master/internal/logging"

    flags "github.com/jessevdk/go-flags"
)

type flagOptions struct {
    Port          int    `long:"port" description:"port to listen on" default:"50051"`
    WorkerPath    string `long:"worker-path" description:"path to worker executable"`
    WorkerCount   int    `long:"worker-count" description:"number of workers to manage" default:"2"`
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
    logger.Infof("Starting Master with options: %+v", opts)

    // Create core logger
    coreLogger := coreLogging.NewLogger(
        "hsu-master.core", coreLogging.LogFuncs{
            Debugf: logger.Debugf,
            Infof:  logger.Infof,
            Warnf:  logger.Warnf,
            Errorf: logger.Errorf,
        })

    // Create and start the master server
    master, err := NewHSUMaster(opts, coreLogger)
    if err != nil {
        logger.Errorf("Failed to create Master: %v", err)
        os.Exit(1)
    }

    master.Run()
}
```

## Step 4: Implement the Master Logic

Create `cmd/master/master.go`:

```go
package main

import (
    "context"
    "fmt"
    "sync"
    "time"

    "github.com/phayes/freeport"
    coreControl "github.com/core-tools/hsu-core/go/control"
    coreDomain "github.com/core-tools/hsu-core/go/domain"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
    coreProcess "github.com/core-tools/hsu-core/go/process"
    "github.com/yourorg/my-hsu-master/internal/domain"
)

type HSUMaster struct {
    options      flagOptions
    server       coreControl.Server
    logger       coreLogging.Logger
    workers      []HSUWorker
    workersMutex sync.RWMutex
}

type HSUWorker struct {
    ID         string
    Port       int
    Controller coreProcess.Controller
    Gateway    coreDomain.Contract
    Status     string
}

func NewHSUMaster(options flagOptions, logger coreLogging.Logger) (*HSUMaster, error) {
    // Create gRPC server
    serverOptions := coreControl.ServerOptions{
        Port: options.Port,
    }
    
    server, err := coreControl.NewServer(serverOptions, logger)
    if err != nil {
        return nil, fmt.Errorf("failed to create server: %v", err)
    }

    // Register core services
    coreHandler := coreDomain.NewDefaultHandler(logger)
    coreControl.RegisterGRPCServerHandler(server.GRPC(), coreHandler, logger)

    // Register business logic services
    businessHandler := domain.NewBusinessHandler(logger)
    domain.RegisterBusinessService(server.GRPC(), businessHandler)

    master := &HSUMaster{
        options: options,
        server:  server,
        logger:  logger,
        workers: make([]HSUWorker, 0),
    }

    return master, nil
}

func (m *HSUMaster) Run() {
    m.logger.Infof("Starting Master...")

    // Start worker management in background
    go m.manageWorkers()

    // Start the server (blocks until shutdown)
    m.server.Run(func() {
        m.logger.Infof("Shutting down workers...")
        m.shutdownWorkers()
    })
}

func (m *HSUMaster) manageWorkers() {
    if m.options.WorkerPath == "" {
        m.logger.Infof("No worker path specified, running in standalone mode")
        return
    }

    m.logger.Infof("Starting %d workers from %s", m.options.WorkerCount, m.options.WorkerPath)

    // Start initial workers
    for i := 0; i < m.options.WorkerCount; i++ {
        err := m.startWorker(fmt.Sprintf("worker-%d", i))
        if err != nil {
            m.logger.Errorf("Failed to start worker %d: %v", i, err)
        }
    }

    // Monitor workers
    ticker := time.NewTicker(30 * time.Second)
    defer ticker.Stop()

    for {
        select {
        case <-ticker.C:
            m.healthCheckWorkers()
        }
    }
}

func (m *HSUMaster) startWorker(workerID string) error {
    // Find free port
    port, err := freeport.GetFreePort()
    if err != nil {
        return fmt.Errorf("failed to get free port: %v", err)
    }

    // Start worker process
    args := []string{"--port", fmt.Sprintf("%d", port)}
    
    logConfig := coreProcess.ControllerLogConfig{
        Module: fmt.Sprintf("worker.%s", workerID),
        Funcs: coreLogging.LogFuncs{
            Debugf: m.logger.Debugf,
            Infof:  m.logger.Infof,
            Warnf:  m.logger.Warnf,
            Errorf: m.logger.Errorf,
        },
    }

    controller, err := coreProcess.NewController(
        m.options.WorkerPath, 
        args, 
        10*time.Second, // retry period
        logConfig,
    )
    if err != nil {
        return fmt.Errorf("failed to create process controller: %v", err)
    }

    // Create connection to worker
    connectionOptions := coreControl.ConnectionOptions{
        AttachPort: port,
    }
    
    connection, err := coreControl.NewConnection(connectionOptions, m.logger)
    if err != nil {
        controller.Stop()
        return fmt.Errorf("failed to create connection: %v", err)
    }

    gateway := coreControl.NewGRPCClientGateway(connection.GRPC(), m.logger)

    // Wait for worker to be ready
    ctx, cancel := context.WithTimeout(context.Background(), 30*time.Second)
    defer cancel()

    retryOptions := coreDomain.RetryPingOptions{
        RetryAttempts: 30,
        RetryInterval: 1 * time.Second,
    }

    err = coreDomain.RetryPing(ctx, gateway, retryOptions, m.logger)
    if err != nil {
        controller.Stop()
        return fmt.Errorf("worker failed health check: %v", err)
    }

    // Add to workers list
    worker := HSUWorker{
        ID:         workerID,
        Port:       port,
        Controller: controller,
        Gateway:    gateway,
        Status:     "running",
    }

    m.workersMutex.Lock()
    m.workers = append(m.workers, worker)
    m.workersMutex.Unlock()

    m.logger.Infof("Worker %s started successfully on port %d", workerID, port)
    return nil
}

func (m *HSUMaster) healthCheckWorkers() {
    m.workersMutex.RLock()
    workers := make([]HSUWorker, len(m.workers))
    copy(workers, m.workers)
    m.workersMutex.RUnlock()

    for i, worker := range workers {
        ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
        err := worker.Gateway.Ping(ctx)
        cancel()

        if err != nil {
            m.logger.Warnf("Worker %s health check failed: %v", worker.ID, err)
            // Update status
            m.workersMutex.Lock()
            if i < len(m.workers) {
                m.workers[i].Status = "unhealthy"
            }
            m.workersMutex.Unlock()
        } else {
            m.workersMutex.Lock()
            if i < len(m.workers) {
                m.workers[i].Status = "running"
            }
            m.workersMutex.Unlock()
        }
    }
}

func (m *HSUMaster) shutdownWorkers() {
    m.workersMutex.Lock()
    defer m.workersMutex.Unlock()

    for _, worker := range m.workers {
        m.logger.Infof("Stopping worker %s", worker.ID)
        worker.Controller.Stop()
    }
    
    m.workers = nil
}
```

## Step 5: Add Business Logic Services

Create your business logic handlers in `internal/domain/handlers.go`:

```go
package domain

import (
    "context"
    "fmt"
    "sync/atomic"

    "github.com/yourorg/my-hsu-master/api/proto"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
    "google.golang.org/grpc"
)

type BusinessHandler struct {
    proto.UnimplementedMyBusinessServiceServer
    logger        coreLogging.Logger
    processedCount int64
}

func NewBusinessHandler(logger coreLogging.Logger) *BusinessHandler {
    return &BusinessHandler{
        logger: logger,
    }
}

func (h *BusinessHandler) ProcessData(ctx context.Context, req *proto.ProcessRequest) (*proto.ProcessResponse, error) {
    h.logger.Infof("Processing data: %s (priority: %d)", req.Data, req.Priority)
    
    // Your business logic here
    result := fmt.Sprintf("Processed: %s", req.Data)
    
    // Update counter
    atomic.AddInt64(&h.processedCount, 1)
    
    return &proto.ProcessResponse{
        Result:  result,
        Success: true,
    }, nil
}

func (h *BusinessHandler) GetStatus(ctx context.Context, req *proto.StatusRequest) (*proto.StatusResponse, error) {
    count := atomic.LoadInt64(&h.processedCount)
    
    return &proto.StatusResponse{
        Status:         "running",
        ProcessedCount: count,
    }, nil
}

// RegisterBusinessService registers the business service with the gRPC server
func RegisterBusinessService(server grpc.ServiceRegistrar, handler *BusinessHandler) {
    proto.RegisterMyBusinessServiceServer(server, handler)
}
```

## Step 6: Add Logging Support

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

## Step 7: Build and Test

Create a `Makefile`:

```makefile
.PHONY: build run clean proto

proto:
	cd api/proto && protoc --go_out=. --go_opt=paths=source_relative \
		--go-grpc_out=. --go-grpc_opt=paths=source_relative \
		myservice.proto

build: proto
	go build -o bin/master cmd/master/*.go

run: build
	./bin/master --port 50051 --worker-count 2

clean:
	rm -rf bin/
```

Build and run your master:

```bash
make build
make run
```

## Step 8: Advanced Features

### Service Discovery

Add service discovery capabilities:

```go
type ServiceRegistry struct {
    services map[string][]ServiceInfo
    mutex    sync.RWMutex
}

type ServiceInfo struct {
    Address string
    Port    int
    Health  string
}

func NewServiceRegistry() *ServiceRegistry {
    return &ServiceRegistry{
        services: make(map[string][]ServiceInfo),
    }
}

func (r *ServiceRegistry) RegisterService(name, address string, port int) {
    r.mutex.Lock()
    defer r.mutex.Unlock()
    
    if r.services[name] == nil {
        r.services[name] = make([]ServiceInfo, 0)
    }
    
    r.services[name] = append(r.services[name], ServiceInfo{
        Address: address,
        Port:    port,
        Health:  "healthy",
    })
}

func (r *ServiceRegistry) GetServices(name string) []ServiceInfo {
    r.mutex.RLock()
    defer r.mutex.RUnlock()
    
    services := r.services[name]
    healthy := make([]ServiceInfo, 0)
    
    for _, service := range services {
        if service.Health == "healthy" {
            healthy = append(healthy, service)
        }
    }
    
    return healthy
}
```

### Load Balancing

Add simple round-robin load balancing:

```go
type LoadBalancer struct {
    services []ServiceInfo
    current  int64
    mutex    sync.RWMutex
}

func NewLoadBalancer() *LoadBalancer {
    return &LoadBalancer{
        services: make([]ServiceInfo, 0),
    }
}

func (lb *LoadBalancer) UpdateServices(services []ServiceInfo) {
    lb.mutex.Lock()
    defer lb.mutex.Unlock()
    lb.services = services
}

func (lb *LoadBalancer) GetNext() ServiceInfo {
    lb.mutex.RLock()
    defer lb.mutex.RUnlock()
    
    if len(lb.services) == 0 {
        return ServiceInfo{}
    }
    
    next := atomic.AddInt64(&lb.current, 1) % int64(len(lb.services))
    return lb.services[next]
}
```

## Next Steps

- **[Unmanaged Units](../units/unmanaged/index.md)** - Integrate existing processes
- **[Managed Units](../units/managed/index.md)** - Control application lifecycle
- **[Integrated Units](../units/integrated/index.md)** - Deep gRPC integration

---

*You are here: System > **Master Process***


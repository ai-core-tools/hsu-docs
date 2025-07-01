# Single-Repository HSU Go Implementation Guide

This guide walks you through creating a single-repository, self-contained Go-based HSU server in a single repository. This approach is perfect for getting started quickly or when you only need one server implementation.

## Overview

A single-repository HSU Go implementation includes everything in one repository:
- Protocol Buffer definitions
- Generated gRPC code
- Domain contracts and business logic
- Server setup and entry point
- Client for testing

This is ideal for:
- Learning the HSU platform
- Single-implementation services
- Rapid prototyping
- When multi-repository complexity isn't needed

## Prerequisites

- Go 1.22+
- Protocol Buffers compiler (`protoc`)
- Basic understanding of gRPC

## Step 1: Create Project Structure

```bash
mkdir hsu-echo-simple-go
cd hsu-echo-simple-go
git init
go mod init github.com/your-org/hsu-echo-simple-go
```

Create the directory structure:

```
hsu-echo-simple-go/
├── api/
│   └── proto/
│       ├── echoservice.proto
│       ├── generate-go.sh
│       └── generate-go.bat
├── cmd/
│   ├── echogrpcsrv/
│   │   └── main.go           # Server entry point
│   └── echogrpccli/
│       └── main.go           # Client for testing
├── internal/
│   ├── api/
│   │   └── proto/            # Generated gRPC code
│   ├── control/
│   │   ├── handler.go        # gRPC ↔ domain adapter
│   │   ├── gateway.go        # Client gateway
│   │   └── main_echo.go      # Server setup helper
│   ├── domain/
│   │   ├── contract.go       # Domain interface
│   │   └── simple_handler.go # Business logic
│   └── logging/
│       ├── logging.go        # Logging interface
│       ├── sprintf_logger.go # Logger implementation
│       └── std_sprintf_logger.go
├── go.mod
├── go.sum
└── README.md
```

## Step 2: Define Protocol Buffer Service

Create `api/proto/echoservice.proto`:

```proto
syntax = "proto3";

option go_package = "github.com/your-org/hsu-echo-simple-go/internal/api/proto";

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

## Step 3: Generate Go Code

Create `api/proto/generate-go.sh`:

```bash
#!/bin/bash
protoc --go_out=../../internal/api/proto --go_opt=paths=source_relative \
       --go-grpc_out=../../internal/api/proto --go-grpc_opt=paths=source_relative \
       echoservice.proto
```

Create `api/proto/generate-go.bat` (Windows):

```batch
@echo off
protoc --go_out=../../internal/api/proto --go_opt=paths=source_relative ^
       --go-grpc_out=../../internal/api/proto --go-grpc_opt=paths=source_relative ^
       echoservice.proto
```

Run the generator:

```bash
cd api/proto
chmod +x generate-go.sh
./generate-go.sh
```

## Step 4: Define Domain Contract

Create `internal/domain/contract.go`:

```go
package domain

import (
    "context"
)

type Contract interface {
    Echo(ctx context.Context, message string) (string, error)
}
```

## Step 5: Implement Business Logic

Create `internal/domain/simple_handler.go`:

```go
package domain

import (
    "context"

    "github.com/your-org/hsu-echo-simple-go/internal/logging"
)

func NewSimpleHandler(logger logging.Logger) Contract {
    return &simpleHandler{
        logger: logger,
    }
}

type simpleHandler struct {
    logger logging.Logger
}

func (h *simpleHandler) Echo(ctx context.Context, message string) (string, error) {
    h.logger.Infof("Processing echo request: %s", message)
    response := "go-simple-echo: " + message
    h.logger.Debugf("Echo response: %s", response)
    return response, nil
}
```

## Step 6: Create gRPC Handler

Create `internal/control/handler.go`:

```go
package control

import (
    "context"

    "github.com/your-org/hsu-echo-simple-go/internal/api/proto"
    "github.com/your-org/hsu-echo-simple-go/internal/domain"
    "github.com/your-org/hsu-echo-simple-go/internal/logging"

    "google.golang.org/grpc"
)

func RegisterGRPCServerHandler(grpcServerRegistrar grpc.ServiceRegistrar, handler domain.Contract, logger logging.Logger) {
    proto.RegisterEchoServiceServer(grpcServerRegistrar, &grpcServerHandler{
        handler: handler,
        logger:  logger,
    })
}

type grpcServerHandler struct {
    proto.UnimplementedEchoServiceServer
    handler domain.Contract
    logger  logging.Logger
}

func (h *grpcServerHandler) Echo(ctx context.Context, echoRequest *proto.EchoRequest) (*proto.EchoResponse, error) {
    response, err := h.handler.Echo(ctx, echoRequest.Message)
    if err != nil {
        h.logger.Errorf("Echo server handler: %v", err)
        return nil, err
    }
    h.logger.Debugf("Echo server handler done")
    return &proto.EchoResponse{Message: response}, nil
}
```

## Step 7: Create Server Setup Helper

Create `internal/control/main_echo.go`:

```go
package control

import (
    "fmt"
    "os"

    coreControl "github.com/core-tools/hsu-core/go/control"
    coreDomain "github.com/core-tools/hsu-core/go/domain"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
    echoDomain "github.com/your-org/hsu-echo-simple-go/internal/domain"
    echoLogging "github.com/your-org/hsu-echo-simple-go/internal/logging"

    "github.com/your-org/hsu-echo-simple-go/internal/logging"

    flags "github.com/jessevdk/go-flags"
)

type flagOptions struct {
    Port int `long:"port" description:"port to listen on"`
}

func logPrefix(module string) string {
    return fmt.Sprintf("module: %s-server , ", module)
}

func MainEcho(echoServerHandlerFactoryFunc func(echoLogger echoLogging.Logger) echoDomain.Contract) {
    var opts flagOptions
    var argv []string = os.Args[1:]
    var parser = flags.NewParser(&opts, flags.HelpFlag)
    var err error
    _, err = parser.ParseArgs(argv)
    if err != nil {
        fmt.Printf("Command line flags parsing failed: %v", err)
        os.Exit(1)
    }

    logger := logging.NewSprintfLogger()

    logger.Infof("opts: %+v", opts)

    if opts.Port == 0 {
        fmt.Println("Port is required")
        os.Exit(1)
    }

    logger.Infof("Starting...")

    coreLogger := coreLogging.NewLogger(
        logPrefix("hsu-core"), coreLogging.LogFuncs{
            Debugf: logger.Debugf,
            Infof:  logger.Infof,
            Warnf:  logger.Warnf,
            Errorf: logger.Errorf,
        })
    echoLogger := echoLogging.NewLogger(
        logPrefix("hsu-echo"), echoLogging.LogFuncs{
            Debugf: logger.Debugf,
            Infof:  logger.Infof,
            Warnf:  logger.Warnf,
            Errorf: logger.Errorf,
        })

    coreServerOptions := coreControl.ServerOptions{
        Port: opts.Port,
    }
    coreServer, err := coreControl.NewServer(coreServerOptions, coreLogger)
    if err != nil {
        logger.Errorf("Failed to create core server: %v", err)
        return
    }

    coreServerHandler := coreDomain.NewDefaultHandler(coreLogger)
    echoServerHandler := echoServerHandlerFactoryFunc(echoLogger)

    coreControl.RegisterGRPCServerHandler(coreServer.GRPC(), coreServerHandler, coreLogger)
    RegisterGRPCServerHandler(coreServer.GRPC(), echoServerHandler, echoLogger)

    coreServer.Run(nil)
}
```

## Step 8: Create Server Entry Point

Create `cmd/echogrpcsrv/main.go`:

```go
package main

import (
    "github.com/your-org/hsu-echo-simple-go/internal/control"
    "github.com/your-org/hsu-echo-simple-go/internal/domain"
)

func main() {
    control.MainEcho(domain.NewSimpleHandler)
}
```

## Step 9: Create Test Client

Create `cmd/echogrpccli/main.go`:

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "github.com/your-org/hsu-echo-simple-go/internal/api/proto"
    coreProto "github.com/core-tools/hsu-core/go/api/proto"
    "google.golang.org/grpc"
    "google.golang.org/grpc/credentials/insecure"
    flags "github.com/jessevdk/go-flags"
)

type flagOptions struct {
    Address string `long:"address" description:"server address" default:"localhost:50055"`
}

func main() {
    var opts flagOptions
    _, err := flags.Parse(&opts)
    if err != nil {
        log.Fatalf("Failed to parse flags: %v", err)
    }

    // Connect to HSU server
    conn, err := grpc.Dial(opts.Address, grpc.WithTransportCredentials(insecure.NewCredentials()))
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

    // Test echo service
    echoClient := proto.NewEchoServiceClient(conn)
    
    echoResp, err := echoClient.Echo(ctx, &proto.EchoRequest{
        Message: "Hello World!",
    })
    if err != nil {
        log.Fatalf("Echo failed: %v", err)
    }

    fmt.Printf("✓ Echo response: %s\n", echoResp.Message)
    fmt.Println("✓ All tests passed!")
}
```

## Step 10: Setup Dependencies

Update `go.mod`:

```go
module github.com/your-org/hsu-echo-simple-go

go 1.22

require (
    github.com/core-tools/hsu-core v0.0.0
    github.com/jessevdk/go-flags v1.5.0
    google.golang.org/grpc v1.64.0
    google.golang.org/protobuf v1.34.1
)
```

Install dependencies:

```bash
go mod tidy
```

## Step 11: Build and Run

### Build the Server

```bash
go build -o bin/echogrpcsrv cmd/echogrpcsrv/*.go
```

### Build the Client

```bash
go build -o bin/echogrpccli cmd/echogrpccli/*.go
```

### Run the Server

```bash
./bin/echogrpcsrv --port 50055
```

### Test with Client

```bash
./bin/echogrpccli --address localhost:50055
```

Expected output:
```
✓ Core service health check passed
✓ Echo response: go-simple-echo: Hello World!
✓ All tests passed!
```

## Key Advantages

### Single-Repository Structure
- Everything in one repository
- No git submodules or complex dependencies
- Easy to understand and modify

### Self-Contained
- All code is visible and editable
- Direct control over all components
- Single-repository build and deployment

### Perfect for Learning
- Clear separation of concerns
- Easy to trace code flow
- All patterns visible in one place

## When to Use Single-Repository vs Multi-Repository Structure

### Use Single-Repository Structure When:
- Learning the HSU platform
- Building a single server implementation
- Rapid prototyping
- Small teams or individual development
- Don't need multiple language implementations

### Consider Multi-Repository Structure When:
- Need multiple server implementations (Go + Python)
- Want to share common components across teams
- Building production systems with multiple variants
- Need independent versioning of implementations

## Next Steps

- Study the [Protocol Buffer Definition Guide](../guides/HSU_PROTOCOL_BUFFERS.md) to understand gRPC contracts
- Explore the [Multi-Repository Implementation Guides](INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md) when you need multi-repository structure
- Check [Best Practices](../guides/HSU_BEST_PRACTICES.md) for production deployment 
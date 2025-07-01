# HSU Go Implementation Guide

This guide walks you through creating Go-based HSU servers using the established patterns from the `hsu-example3-common` reference implementation.

## Overview

Creating a Go-based HSU server involves:
1. Setting up a common domain repository with Go support
2. Defining gRPC services and generating Go code
3. Implementing domain contracts and gRPC adapters
4. Creating helper functions for server setup
5. Building individual server implementations

## Step 1: Create Common Domain Repository

### Project Setup

```bash
mkdir hsu-example3-common
cd hsu-example3-common
git init
go mod init github.com/core-tools/hsu-example3-common
```

### Directory Structure

```
hsu-example3-common/
├── api/proto/
│   ├── api/proto/
│   ├── control/
│   ├── domain/
│   └── logging/
├── cmd/echogrpccli/
├── internal/logging/
├── go.mod
└── README.md
```

### Protocol Buffer Setup

Before implementing the Go server, you need to define your gRPC service contract using Protocol Buffers. This includes:

- Creating `.proto` service definitions
- Setting up code generation scripts
- Generating Go gRPC code

**📋 Complete Setup Guide:** [Protocol Buffer Definition Guide](../guides/HSU_PROTOCOL_BUFFERS.md)

The Protocol Buffer guide covers:
- Service and message definitions
- Code generation for both Go and Python
- Best practices for gRPC API design
- Directory structure and file organization

Once you've completed the Protocol Buffer setup, continue with the Go implementation below.

## Step 2: Define Domain Contract

Create `go/domain/contract.go`:

```go
package domain

import (
    "context"
)

type Contract interface {
    Echo(ctx context.Context, message string) (string, error)
}
```

## Step 3: Create gRPC Adapter

Create `go/control/handler.go`:

```go
package control

import (
    "context"

    "github.com/core-tools/hsu-example3-common/go/api/proto"
    "github.com/core-tools/hsu-example3-common/go/domain"
    "github.com/core-tools/hsu-example3-common/go/logging"

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

## Step 4: Create Helper Function

Create `go/control/main_echo.go`:

```go
package control

import (
    "fmt"
    "os"

    coreControl "github.com/core-tools/hsu-core/go/control"
    coreDomain "github.com/core-tools/hsu-core/go/domain"
    coreLogging "github.com/core-tools/hsu-core/go/logging"
    echoDomain "github.com/core-tools/hsu-example3-common/go/domain"
    echoLogging "github.com/core-tools/hsu-example3-common/go/logging"
    "github.com/core-tools/hsu-example3-common/internal/logging"

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
        logPrefix("hsu-example3-common"), echoLogging.LogFuncs{
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

## Step 5: Create Server Implementation

### Create New Repository

```bash
mkdir hsu-example3-srv-go
cd hsu-example3-srv-go
git init
go mod init github.com/core-tools/hsu-example3-srv-go
```

### Directory Structure

```
hsu-example3-srv-go/
├── cmd/
│   └── echogrpcsrv/
│       └── main.go
├── internal/
│   └── domain/
│       └── super_handler.go
├── go.mod
├── go.sum
└── README.md
```

### Implement Business Logic

Create `internal/domain/super_handler.go`:

```go
package domain

import (
    "context"

    "github.com/core-tools/hsu-example3-common/go/domain"
    "github.com/core-tools/hsu-example3-common/go/logging"
)

func NewSuperHandler(logger logging.Logger) domain.Contract {
    return &superHandler{
        logger: logger,
    }
}

type superHandler struct {
    logger logging.Logger
}

func (h *superHandler) Echo(ctx context.Context, message string) (string, error) {
    h.logger.Infof("Processing echo request: %s", message)
    response := "go-super-echo: " + message
    h.logger.Debugf("Echo response: %s", response)
    return response, nil
}
```

### Create Entry Point

Create `cmd/echogrpcsrv/main.go`:

```go
package main

import (
    "github.com/core-tools/hsu-example3-srv-go/internal/domain"
    echoControl "github.com/core-tools/hsu-example3-common/go/control"
)

func main() {
    echoControl.MainEcho(domain.NewSuperHandler)
}
```

### Update Dependencies

Update `go.mod`:

```go
module github.com/core-tools/hsu-example3-srv-go

go 1.22

require (
    github.com/core-tools/hsu-example3-common v0.0.0
)
```

## Step 6: Build and Test

### Build the Server

```bash
go mod tidy
go build -o bin/echogrpcsrv cmd/echogrpcsrv/*.go
```

### Run the Server

```bash
./bin/echogrpcsrv --port 50055
```

### Create Test Client

Create `cmd/echogrpccli/main.go` in the common domain repository:

```go
package main

import (
    "context"
    "fmt"
    "log"
    "time"

    "github.com/core-tools/hsu-example3-common/go/api/proto"
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

    // Connect to HSU
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

### Test the Implementation

```bash
# In the common domain repository
cd cmd/echogrpccli
go run main.go --address localhost:50055
```

Expected output:
```
✓ Core service health check passed
✓ Echo response: go-super-echo: Hello World!
✓ All tests passed!
```

## Key Patterns

### Factory Function Pattern
Server implementations provide a factory function that matches the expected signature:
```go
func NewSuperHandler(logger logging.Logger) domain.Contract
```

### Helper Function Usage
The common domain provides a helper that handles all server setup boilerplate:
```go
echoControl.MainEcho(domain.NewSuperHandler)
```

### gRPC Adapter Pattern
Convert between gRPC types and domain types in the control layer, keeping domain logic pure.

## Next Steps

- [Python Implementation Guide](INTEGRATED_HSU_MULTI_REPO_PYTHON_GUIDE.md) - Create Python servers
- [Testing and Deployment](../guides/HSU_TESTING_DEPLOYMENT.md) - Test and deploy your servers
- [Best Practices](../guides/HSU_BEST_PRACTICES.md) - Follow platform conventions 
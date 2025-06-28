# Development Setup

This guide helps you set up your development environment for working with the HSU platform.

## Prerequisites

### Go Development
- **Go 1.22+** - [Download from golang.org](https://golang.org/dl/)
- **Protocol Buffers Compiler** - For generating gRPC stubs

### Python Development (Optional)
- **Python 3.8+** - For Python HSU implementations
- **pip** - Python package manager

## Installation

### Install Protocol Buffers Compiler

**Linux (Ubuntu/Debian):**
```bash
sudo apt update
sudo apt install -y protobuf-compiler
```

**macOS:**
```bash
brew install protobuf
```

**Windows:**
Download from [Protocol Buffers releases](https://github.com/protocolbuffers/protobuf/releases) and add to PATH.

### Install Go gRPC Tools

```bash
go install google.golang.org/protobuf/cmd/protoc-gen-go@latest
go install google.golang.org/grpc/cmd/protoc-gen-go-grpc@latest
```

### Install Python gRPC Tools (if using Python)

```bash
pip install grpcio grpcio-tools
```

## Clone and Build HSU Platform

```bash
# Clone the repository
git clone https://github.com/core-tools/hsu-platform.git
cd hsu-platform

# Test Go modules
cd hsu-core
go mod tidy
go test ./...

# Build example servers
cd ../hsu-echo-super-srv-go
go build -o bin/server cmd/echogrpcsrv/main.go

# Build example client
cd ../hsu-echo-cli-go
go build -o bin/client cmd/echogrpccli/main.go
```

## Verify Installation

Run the echo example to verify everything works:

```bash
# Terminal 1: Start the server
cd hsu-echo-super-srv-go
./bin/server --port 50055

# Terminal 2: Run the client
cd hsu-echo-cli-go
./bin/client --port 50055
```

You should see successful echo responses.

## IDE Setup

### VS Code
Recommended extensions:
- **Go** (official Go extension)
- **Protocol Buffers** (for .proto files)
- **gRPC** (for gRPC development)

### GoLand/IntelliJ
- Enable Go plugin
- Install Protocol Buffers plugin

## Development Workflow

1. **Create new services**: Define `.proto` files
2. **Generate code**: Run `protoc` to generate Go/Python stubs
3. **Implement handlers**: Write business logic
4. **Test**: Run unit and integration tests
5. **Build**: Create executables

## Troubleshooting

### Common Issues

**`protoc: command not found`**
- Install Protocol Buffers compiler
- Ensure it's in your PATH

**`protoc-gen-go: program not found`**
- Run: `go install google.golang.org/protobuf/cmd/protoc-gen-go@latest`
- Ensure `$GOPATH/bin` is in your PATH

**Go module issues**
- Run: `go mod tidy` in each module directory
- Check Go version: `go version`

**Port binding failures**
- Check if ports are already in use: `netstat -tlnp | grep 50055`
- Use different ports or kill existing processes

## Next Steps

- [Creating an HSU Master Process](HSU_MASTER_GUIDE.md)
- [Creating an Integrated HSU](INTEGRATED_HSU_GUIDE.md)
- [Working with gRPC Services](GRPC_SERVICES.md) 
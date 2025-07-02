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
# Clone the core-tools repository containing all HSU examples
git clone https://github.com/your-org/core-tools.git
cd core-tools

# Test HSU core libraries
cd hsu-core/go
go mod tidy
go test ./...

# Build and test working examples
cd ../../hsu-example1-go
make setup && make build && make test

# Build Python example  
cd ../hsu-example1-py
make setup && make build && make test

# Test multi-language example
cd ../hsu-example2
make setup && make build && make test
```

## Verify Installation

Run the working examples to verify everything works:

### **Option 1: Test Approach 1 (Single-Language)**

```bash
# Terminal 1: Start Go server
cd hsu-example1-go
make setup && make build
make run-server

# Terminal 2: Test Go client
make run-client
```

**Expected output:**
```
✓ Core service health check passed
✓ Echo response: go-simple-echo: Hello World!
```

### **Option 2: Test Approach 2 (Multi-Language)**

```bash
# Terminal 1: Start Go server
cd hsu-example2
make setup && make build
make go-run-server

# Terminal 2: Start Python server
make py-run-server

# Terminal 3: Test both servers
make run-client
```

**Expected output:**
```
✓ Go server: go-echo: Hello World!
✓ Python server: py-echo: Hello World!
```

### **Option 3: Test Approach 3 (Multi-Repository)**

```bash
# Terminal 1: Start Go microservice
cd hsu-example3-srv-go
make setup && make build
make run-server

# Terminal 2: Test with shared client
cd ../hsu-example3-common/go
make setup && make build
make run-client
```

**Expected output:**
```
✓ Go microservice responding
✓ Shared client successfully connected
```

## IDE Setup

### VS Code
Recommended extensions:
- **Go** (official Go extension)
- **Protocol Buffers** (for .proto files)
- **gRPC** (for gRPC development)
- **Python** (for Python HSU implementations)

### GoLand/IntelliJ
- Enable Go plugin
- Install Protocol Buffers plugin
- Configure Python interpreter (if using Python)

## Development Workflow

### Using the Universal Makefile System

All HSU examples use the same commands regardless of approach:

```bash
# Core workflow (works in any hsu-example* directory)
make setup          # Install dependencies
make proto          # Generate gRPC code  
make build          # Build all components
make test           # Run tests
make run-server     # Start development server
make run-client     # Test with example client
```

### Language-Specific Development

```bash
# In multi-language repositories (hsu-example2)
make go-build       # Build Go components
make py-build       # Build Python components
make go-run-server  # Start Go server
make py-run-server  # Start Python server
```

### Protocol Buffer Development

1. **Edit `.proto` files** in `api/proto/`
2. **Regenerate code**: `make proto`
3. **Implement handlers**: Update business logic
4. **Test**: `make build && make test`

## Troubleshooting

### Common Issues

**`protoc: command not found`**
- Install Protocol Buffers compiler
- Ensure it's in your PATH

**`protoc-gen-go: program not found`**
- Run: `go install google.golang.org/protobuf/cmd/protoc-gen-go@latest`
- Ensure `$GOPATH/bin` is in your PATH

**`make: command not found`**
- **Windows**: Install [Make for Windows](http://gnuwin32.sourceforge.net/packages/make.htm)
- **macOS**: Install via Xcode Command Line Tools or Homebrew
- **Linux**: Install via package manager (`sudo apt install make`)

**Go module issues**
- Run: `make setup` (handles go mod tidy automatically)
- Check Go version: `go version`

**Python package issues**
- Run: `make setup` (handles pip install automatically)
- Check Python version: `python --version`

**Port binding failures**
- Check if ports are already in use: `netstat -tlnp | grep 50055`
- Use different ports in configuration or kill existing processes

**Build failures**
- Run: `make clean && make setup && make build`
- Check the specific error messages for missing dependencies

## Next Steps

Choose your implementation approach:

- **[Approach 1: Single-Language](../tutorials/INTEGRATED_HSU_SINGLE_REPO_GO_GUIDE.md)** - Start with Go or Python
- **[Approach 2: Multi-Language](../tutorials/INTEGRATED_HSU_SINGLE_REPO_MULTI_LANG_GUIDE.md)** - Coordinate Go and Python  
- **[Approach 3: Multi-Repository](../tutorials/INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md)** - Independent microservices

Or review the comprehensive guide:
- **[Complete HSU Implementation Guide](../tutorials/INTEGRATED_HSU_GUIDE.md)** - All approaches with working examples 

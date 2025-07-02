# HSU Testing and Deployment Guide

This guide covers testing strategies and deployment practices for HSU servers using the Universal Makefile System and current working examples.

## Testing Strategy

### Unit Testing

Test domain logic separately from gRPC concerns using the working examples as patterns.

#### Go Unit Tests

```go
// cmd/srv/domain/simple_handler_test.go (from hsu-example2)
package domain

import (
    "context"
    "testing"
)

func TestSimpleHandler_Echo(t *testing.T) {
    handler := NewSimpleHandler()

    ctx := context.Background()
    message := "test message"

    response, err := handler.Echo(ctx, message)
    if err != nil {
        t.Errorf("Expected no error, got %v", err)
    }

    expected := "go-simple-echo: test message"
    if response != expected {
        t.Errorf("Expected %q, got %q", expected, response)
    }
}
```

#### Python Unit Tests

```python
# srv/domain/test_simple_handler.py (from hsu-example2)
import unittest
from srv.domain.simple_handler import SimpleHandler

class TestSimpleHandler(unittest.TestCase):
    
    def setUp(self):
        self.handler = SimpleHandler()
    
    def test_echo(self):
        message = "test message"
        response = self.handler.Echo(message)
        expected = "py-simple-echo: test message"
        self.assertEqual(response, expected)

if __name__ == '__main__':
    unittest.main()
```

### Integration Testing

Use the Universal Makefile System for consistent testing across all approaches.

#### Testing with hsu-example2 (Multi-Language)

**Start Go server:**
```bash
cd hsu-example2
make setup && make build

# Terminal 1: Start Go server
make go-run-server
```

**Start Python server:**
```bash
# Terminal 2: Start Python server  
make py-run-server
```

**Test both servers:**
```bash
# Terminal 3: Test Go server
make go-run-client

# Terminal 4: Test Python server  
make py-run-client
```

#### Testing with hsu-example1-go (Single-Language Go)

```bash
cd hsu-example1-go
make setup && make build

# Terminal 1: Start server
make run-server

# Terminal 2: Test client
make run-client
```

#### Testing with hsu-example1-py (Single-Language Python)

```bash
cd hsu-example1-py  
make setup && make build

# Terminal 1: Start server
make run-server

# Terminal 2: Test client
make run-client
```

### Automated Testing

Run tests using the Universal Makefile System:

```bash
# In any hsu-example* directory
make test           # Run all tests
make go-test        # Run Go tests only (multi-language repos)
make py-test        # Run Python tests only (multi-language repos)
```

## Health Check Testing

All HSU servers provide standardized health checks:

```bash
# Test core service health (works with any HSU server)
grpcurl -plaintext localhost:50055 proto.CoreService/Ping

# Expected response:
{
  "success": true,
  "message": "pong"
}
```

## Load Testing

### Using grpcurl

Install grpcurl:
```bash
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest
```

Test echo service:
```bash
# Test Go implementation
grpcurl -plaintext -d '{"message": "hello"}' localhost:50055 proto.EchoService/Echo

# Expected response:
{
  "message": "go-simple-echo: hello"
}

# Test Python implementation (different port)
grpcurl -plaintext -d '{"message": "hello"}' localhost:50056 proto.EchoService/Echo

# Expected response:
{
  "message": "py-simple-echo: hello"  
}
```

### Concurrent Load Testing

```bash
# Simple concurrent test
for i in {1..100}; do
  grpcurl -plaintext -d '{"message": "load-test-'$i'"}' localhost:50055 proto.EchoService/Echo &
done
wait
```

## Deployment

### Development Deployment

Use the Universal Makefile System for consistent development workflow across all approaches:

#### Common Commands (All Approaches)
```bash
make setup          # Install dependencies
make proto          # Generate protocol buffers  
make build          # Build all components
make test           # Run tests
make run-server     # Start development server
make run-client     # Test with example client
make clean          # Clean build artifacts
```

#### Multi-Language Specific Commands (hsu-example2)
```bash
make go-build       # Build Go components
make py-build       # Build Python components  
make go-run-server  # Start Go server
make py-run-server  # Start Python server
make go-run-client  # Test Go server
make py-run-client  # Test Python server
make go-test        # Run Go tests
make py-test        # Run Python tests
```

### Production Deployment

#### Docker Deployment

**Go Dockerfile (hsu-example1-go pattern):**
```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN make build

FROM alpine:latest
RUN apk --no-cache add ca-certificates
WORKDIR /root/
COPY --from=builder /app/cmd/srv/echogrpcsrv/echogrpcsrv .
EXPOSE 50055
CMD ["./echogrpcsrv", "--port", "50055"]
```

**Python Dockerfile (hsu-example1-py pattern):**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 50055
CMD ["python", "srv/run_server.py", "--port", "50055"]
```

**Multi-Language Docker Compose (hsu-example2 pattern):**
```yaml
# docker-compose.yml
version: '3.8'
services:
  go-server:
    build: 
      context: .
      dockerfile: go/Dockerfile
    ports:
      - "50055:50055"
    command: ["./echogrpcsrv", "--port", "50055"]
    
  python-server:
    build:
      context: .  
      dockerfile: python/Dockerfile
    ports:
      - "50056:50056"
    command: ["python", "srv/run_server.py", "--port", "50056"]
```

#### Binary Deployment

**Go Binary (Single executable):**
```bash
cd hsu-example1-go
make build
# Deploy: cmd/srv/echogrpcsrv/echogrpcsrv
```

**Python Binary (Nuitka compilation):**
```bash
cd hsu-example1-py
make build          # Builds binary with Nuitka
# Deploy: srv/run_server.bin
```

### Environment Configuration

All HSU implementations support environment-based configuration:

```bash
# Common environment variables
export PORT=50055
export LOG_LEVEL=INFO
export HSU_CONFIG_FILE=/etc/hsu/config.yaml

# Start server with environment config
make run-server
```

## Monitoring and Observability

### Health Monitoring

```bash
# Health check endpoint (all HSU servers)
curl -X POST http://localhost:8080/health

# gRPC health check
grpcurl -plaintext localhost:50055 proto.CoreService/Ping
```

### Performance Monitoring

```bash
# Enable performance profiling (Go servers)
export HSU_ENABLE_PPROF=true
make run-server

# Access profiling endpoint
curl http://localhost:6060/debug/pprof/
```

### Log Monitoring

```bash
# Structured JSON logging
export LOG_FORMAT=json
make run-server

# Debug logging
export LOG_LEVEL=DEBUG  
make run-server
```

## Continuous Integration

### GitHub Actions Example

```yaml
# .github/workflows/test.yml
name: Test HSU Services
on: [push, pull_request]

jobs:
  test-go:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-go@v3
        with:
          go-version: '1.22'
      - run: make setup
      - run: make build  
      - run: make test

  test-python:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v3
      - uses: actions/setup-python@v3
        with:
          python-version: '3.11'
      - run: make setup
      - run: make build
      - run: make test
```

## Performance Benchmarking

### Go Benchmarks

```go
// cmd/srv/domain/simple_handler_bench_test.go
func BenchmarkSimpleHandler_Echo(b *testing.B) {
    handler := NewSimpleHandler()
    ctx := context.Background()
    
    for i := 0; i < b.N; i++ {
        handler.Echo(ctx, "benchmark message")
    }
}
```

Run benchmarks:
```bash
cd hsu-example1-go
go test -bench=. ./cmd/srv/domain/
```

### Python Performance Testing

```python
# srv/domain/bench_simple_handler.py
import time
from simple_handler import SimpleHandler

def benchmark_echo():
    handler = SimpleHandler()
    start = time.time()
    
    for i in range(10000):
        handler.Echo(f"benchmark message {i}")
    
    duration = time.time() - start
    print(f"10,000 calls in {duration:.2f}seconds")

if __name__ == '__main__':
    benchmark_echo()
```

## Troubleshooting

### Common Issues

**Build failures:**
```bash
make clean && make setup && make build
# Check specific error messages for missing dependencies
```

**Port conflicts:**
```bash
# Check if port is in use
netstat -tlnp | grep 50055

# Use different port
export PORT=50056
make run-server
```

**Import/dependency issues:**
```bash
# Clean and rebuild protocol buffers
make proto-clean && make proto

# Update dependencies
make setup
```

### Debug Mode

Enable debug logging and verbose output:
```bash
export LOG_LEVEL=DEBUG
export GRPC_GO_LOG_VERBOSITY_LEVEL=99
export GRPC_GO_LOG_SEVERITY_LEVEL=info
make run-server
```

## Next Steps

- **[Complete Implementation Guide](../tutorials/INTEGRATED_HSU_GUIDE.md)** - Choose your approach
- **[Universal Makefile Guide](../makefile_guide/index.md)** - Master the build system  
- **[Best Practices](HSU_BEST_PRACTICES.md)** - Follow platform conventions
- **[Repository Framework](../repositories/framework-overview.md)** - Understand the architecture

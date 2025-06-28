# HSU Testing and Deployment Guide

This guide covers testing strategies and deployment practices for HSU servers across Go and Python implementations.

## Testing Strategy

### Unit Testing

Test domain logic separately from gRPC concerns.

#### Go Unit Tests

```go
// internal/domain/super_handler_test.go
package domain

import (
    "context"
    "testing"
)

func TestSuperHandler_Echo(t *testing.T) {
    logger := &mockLogger{}
    handler := NewSuperHandler(logger)

    ctx := context.Background()
    message := "test message"

    response, err := handler.Echo(ctx, message)
    if err != nil {
        t.Errorf("Expected no error, got %v", err)
    }

    expected := "go-super-echo: test message"
    if response != expected {
        t.Errorf("Expected %q, got %q", expected, response)
    }
}

type mockLogger struct{}
func (l *mockLogger) Debugf(format string, args ...interface{}) {}
func (l *mockLogger) Infof(format string, args ...interface{})  {}
func (l *mockLogger) Warnf(format string, args ...interface{})  {}
func (l *mockLogger) Errorf(format string, args ...interface{}) {}
```

#### Python Unit Tests

```python
# test_super_handler.py
import unittest
from super_handler import SuperHandler

class TestSuperHandler(unittest.TestCase):
    
    def setUp(self):
        self.handler = SuperHandler()
    
    def test_echo(self):
        message = "test message"
        response = self.handler.Echo(message)
        expected = "py-super-echo: test message"
        self.assertEqual(response, expected)

if __name__ == '__main__':
    unittest.main()
```

## Integration Testing

### Using the Test Client

Use the common domain client from `hsu-example3-common/cmd/echogrpccli/` to test both Go and Python implementations:

```bash
# Test Go server
cd hsu-example3-srv-go
go build -o bin/echogrpcsrv cmd/echogrpcsrv/*.go
./bin/echogrpcsrv --port 50055 &

# In another terminal
cd hsu-example3-common/cmd/echogrpccli
go run main.go --address localhost:50055

# Test Python server
cd hsu-example3-srv-py
make run &

# Test with same client
cd hsu-example3-common/cmd/echogrpccli
go run main.go --address localhost:50055
```

## Deployment

### Development

Use Makefiles for consistent development workflow:

**Go Makefile:**
```makefile
.PHONY: build run test clean

build:
	go build -o bin/echogrpcsrv cmd/echogrpcsrv/*.go

run: build
	./bin/echogrpcsrv --port 50055

test:
	go test ./...
```

**Python Makefile:**
```makefile
.PHONY: setup run clean update-submodules

setup: update-submodules
	pip install -r requirements.txt

run: setup
	python run_server.py --port 50055

update-submodules:
	git submodule update --init --recursive
```

### Docker

Create Dockerfiles for each implementation:

**Go Dockerfile:**
```dockerfile
FROM golang:1.22-alpine AS builder
WORKDIR /app
COPY . .
RUN go build -o bin/echogrpcsrv cmd/echogrpcsrv/*.go

FROM alpine:latest
COPY --from=builder /app/bin/echogrpcsrv .
EXPOSE 50055
CMD ["./echogrpcsrv", "--port", "50055"]
```

**Python Dockerfile:**
```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install -r requirements.txt
COPY . .
EXPOSE 50055
CMD ["python", "run_server.py", "--port", "50055"]
```

## Monitoring

### Health Checks

HSU servers provide health checks through the core service:

```bash
grpcurl -plaintext localhost:50055 proto.CoreService/Ping
```

### Load Testing

```bash
# Install grpcurl
go install github.com/fullstorydev/grpcurl/cmd/grpcurl@latest

# Test echo service
grpcurl -plaintext -d '{"message": "hello"}' localhost:50055 proto.EchoService/Echo
```

## Next Steps

- [Go Implementation Guide](INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md) - Learn Go patterns
- [Python Implementation Guide](INTEGRATED_HSU_MULTI_REPO_PYTHON_GUIDE.md) - Learn Python patterns
- [Best Practices](HSU_BEST_PRACTICES.md) - Follow platform conventions 
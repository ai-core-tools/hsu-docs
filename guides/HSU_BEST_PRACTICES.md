# HSU Best Practices

This guide outlines best practices and conventions for developing HSU servers and maintaining the HSU platform ecosystem.

## Development Principles

### Contract-First Design

Always start with defining the domain contract before implementing gRPC or business logic:

1. **Define the interface** - What operations does your domain provide?
2. **Design the protocol buffer** - How will clients communicate with your service?
3. **Implement the adapter** - Convert between gRPC and domain types
4. **Build the implementation** - Focus on business logic

### Separation of Concerns

Keep distinct layers separate:
- **Domain logic**: Pure business logic, no gRPC dependencies
- **gRPC adapters**: Convert between proto and domain types
- **Infrastructure**: Logging, configuration, server setup

## Repository Management

### Go Development

#### Version Management

**Production Dependencies:**
```go
// Use specific versions in production
require (
    github.com/core-tools/hsu-core v1.2.3
    google.golang.org/grpc v1.64.0
)
```

**Development Dependencies:**
```go
// For local development, the repo-portability framework 
// automatically handles module resolution via replace directives
// See: docs/repositories/portability-mechanics.md
```

### Python Development

#### Modern Package Management

**Use pyproject.toml for all Python projects:**
```toml
[project]
name = "my-hsu-service"
version = "1.0.0"
dependencies = [
    "grpcio>=1.64.0",
    "grpcio-tools>=1.64.0",
    "protobuf>=5.27.0"
]

[project.optional-dependencies]
dev = ["pytest", "black", "flake8"]
build = ["nuitka"]
```

#### Requirements Management

```txt
# requirements.txt - Pin specific versions
grpcio==1.64.0
grpcio-tools==1.64.0
protobuf==5.27.0

# Development requirements (separate file)
# requirements-dev.txt
pytest==7.4.0
black==23.0.0
flake8==6.0.0
```

**Important**: Avoid editable installs (`pip install -e .`) when using Nuitka compilation. Use standard installation for production builds.

## Error Handling

### Go Error Patterns

```go
func (h *grpcServerHandler) Echo(ctx context.Context, req *proto.EchoRequest) (*proto.EchoResponse, error) {
    // Validate input
    if req.Message == "" {
        h.logger.Warnf("Empty message received")
        return nil, status.Error(codes.InvalidArgument, "message cannot be empty")
    }

    // Call domain handler
    response, err := h.handler.Echo(ctx, req.Message)
    if err != nil {
        h.logger.Errorf("Echo handler failed: %v", err)
        
        // Convert domain errors to gRPC status codes
        switch err {
        case domain.ErrInvalidInput:
            return nil, status.Error(codes.InvalidArgument, err.Error())
        case domain.ErrResourceExhausted:
            return nil, status.Error(codes.ResourceExhausted, err.Error())
        default:
            return nil, status.Error(codes.Internal, "internal server error")
        }
    }

    h.logger.Debugf("Echo processed successfully")
    return &proto.EchoResponse{Message: response}, nil
}
```

### Python Error Patterns

```python
def Echo(self, request, context):
    try:
        // Validate input
        if not request.message:
            context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
            context.set_details("message cannot be empty")
            return None

        // Call domain handler
        response = self.handler.Echo(request.message)
        return echoservice_pb2.EchoResponse(message=response)
        
    except ValueError as e:
        context.set_code(grpc.StatusCode.INVALID_ARGUMENT)
        context.set_details(str(e))
        return None
    except Exception as e:
        print(f"Unexpected error: {e}")
        traceback.print_exc()
        context.set_code(grpc.StatusCode.INTERNAL)
        context.set_details("internal server error")
        return None
```

## Logging

### Structured Logging

Use consistent log levels and include context:

#### Go Logging

```go
// At start of request
h.logger.Infof("Processing echo request, message_length=%d", len(req.Message))

// For debugging
h.logger.Debugf("Echo response prepared: %s", response)

// For warnings
h.logger.Warnf("Slow response time: %v for message: %s", duration, req.Message)

// For errors
h.logger.Errorf("Failed to process echo: %v, message: %s", err, req.Message)
```

#### Python Logging

```python
// Use proper logging instead of print
import logging

logger = logging.getLogger(__name__)

// Log levels
logger.info(f"Processing echo request, message_length={len(request.message)}")
logger.debug(f"Echo response prepared: {response}")
logger.warning(f"Slow response time: {duration} for message: {request.message}")
logger.error(f"Failed to process echo: {error}, message: {request.message}")
```

## Configuration Management

### Environment-Based Configuration

#### Go Configuration

```go
type Config struct {
    Port        int    `env:"PORT" envDefault:"50055"`
    LogLevel    string `env:"LOG_LEVEL" envDefault:"INFO"`
    MaxRetries  int    `env:"MAX_RETRIES" envDefault:"3"`
    Timeout     string `env:"TIMEOUT" envDefault:"30s"`
}

func LoadConfig() (*Config, error) {
    cfg := &Config{}
    if err := env.Parse(cfg); err != nil {
        return nil, err
    }
    return cfg, nil
}
```

#### Python Configuration

```python
import os
from dataclasses import dataclass

@dataclass
class Config:
    port: int = int(os.getenv("PORT", "50055"))
    log_level: str = os.getenv("LOG_LEVEL", "INFO")
    max_retries: int = int(os.getenv("MAX_RETRIES", "3"))
    timeout: str = os.getenv("TIMEOUT", "30s")

def load_config():
    return Config()
```

## Testing

### Test Structure

Organize tests by layer:

```
tests/
├── unit/
│   ├── domain/          // Pure domain logic tests
│   └── handlers/        // Handler tests with mocks
├── integration/         // End-to-end gRPC tests
└── fixtures/           // Test data and utilities
```

### Mock Patterns

#### Go Mocking

```go
//go:generate mockgen -source=contract.go -destination=mocks/mock_contract.go

type MockHandler struct {
    EchoFunc func(ctx context.Context, message string) (string, error)
}

func (m *MockHandler) Echo(ctx context.Context, message string) (string, error) {
    if m.EchoFunc != nil {
        return m.EchoFunc(ctx, message)
    }
    return "mock-echo: " + message, nil
}
```

#### Python Mocking

```python
from unittest.mock import Mock, patch

class TestGRPCHandler(unittest.TestCase):
    
    def setUp(self):
        self.mock_handler = Mock()
        self.grpc_handler = GRPCServerHandler(self.mock_handler)
    
    def test_echo_success(self):
        // Setup mock
        self.mock_handler.Echo.return_value = "mocked response"
        
        // Create request
        request = echoservice_pb2.EchoRequest(message="test")
        context = Mock()
        
        // Call and verify
        response = self.grpc_handler.Echo(request, context)
        self.assertEqual(response.message, "mocked response")
        self.mock_handler.Echo.assert_called_once_with("test")
```

## Performance

### Resource Management

#### Go Resource Patterns

```go
type Handler struct {
    pool     *sync.Pool
    metrics  *Metrics
    shutdown chan struct{}
}

func (h *Handler) Echo(ctx context.Context, message string) (string, error) {
    // Use context for timeouts
    select {
    case <-ctx.Done():
        return "", ctx.Err()
    default:
    }

    // Use object pools for frequent allocations
    buffer := h.pool.Get().(*bytes.Buffer)
    defer func() {
        buffer.Reset()
        h.pool.Put(buffer)
    }()

    // Process with buffer...
    return "processed: " + message, nil
}
```

#### Python Resource Patterns

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

class Handler:
    def __init__(self):
        self.executor = ThreadPoolExecutor(max_workers=4)
    
    def Echo(self, message: str) -> str:
        // For CPU-intensive work, use thread pool
        if len(message) > 1000:  // Large message
            future = self.executor.submit(self._process_large_message, message)
            return future.result(timeout=30)
        
        return f"processed: {message}"
    
    def _process_large_message(self, message: str) -> str:
        // CPU-intensive processing
        return f"large-processed: {message}"
```

## Security

### Input Validation

Always validate inputs at the gRPC boundary:

#### Go Validation

```go
func validateEchoRequest(req *proto.EchoRequest) error {
    if req == nil {
        return status.Error(codes.InvalidArgument, "request cannot be nil")
    }
    
    if len(req.Message) > 10000 {
        return status.Error(codes.InvalidArgument, "message too long")
    }
    
    // Check for malicious patterns
    if strings.Contains(req.Message, "<?xml") {
        return status.Error(codes.InvalidArgument, "XML not allowed")
    }
    
    return nil
}
```

#### Python Validation

```python
def validate_echo_request(request):
    if not request:
        raise ValueError("request cannot be None")
    
    if len(request.message) > 10000:
        raise ValueError("message too long")
    
    // Check for malicious patterns
    if "<?xml" in request.message:
        raise ValueError("XML not allowed")
```

### TLS Configuration

For production, always use TLS:

```go
// Go TLS setup
creds, err := credentials.LoadTLSConfig(&tls.Config{
    ServerName: "your-service.example.com",
})
if err != nil {
    log.Fatal(err)
}

server := grpc.NewServer(grpc.Creds(creds))
```

## Monitoring and Observability

### Metrics

Implement basic metrics in your handlers:

#### Go Metrics

```go
type Metrics struct {
    requestCount  prometheus.Counter
    responseTime  prometheus.Histogram
    errorCount    prometheus.Counter
}

func (h *Handler) Echo(ctx context.Context, message string) (string, error) {
    start := time.Now()
    defer func() {
        h.metrics.requestCount.Inc()
        h.metrics.responseTime.Observe(time.Since(start).Seconds())
    }()

    response, err := h.processEcho(ctx, message)
    if err != nil {
        h.metrics.errorCount.Inc()
    }
    
    return response, err
}
```

#### Python Metrics

```python
class Metrics:
    def __init__(self):
        self.request_count = 0
        self.error_count = 0
        self.total_response_time = 0.0
    
    def record_request(self, duration, error=False):
        self.request_count += 1
        self.total_response_time += duration
        if error:
            self.error_count += 1

class Handler:
    def __init__(self):
        self.metrics = Metrics()
    
    def Echo(self, message: str) -> str:
        start = time.time()
        try:
            response = self._process_echo(message)
            self.metrics.record_request(time.time() - start)
            return response
        except Exception as e:
            self.metrics.record_request(time.time() - start, error=True)
            raise
```

## Troubleshooting

### Common Issues

#### gRPC Connection Issues

```bash
// Test connectivity
grpcurl -plaintext localhost:50055 list

// Test specific service
grpcurl -plaintext localhost:50055 proto.CoreService/Ping

// Check service methods
grpcurl -plaintext localhost:50055 describe proto.EchoService
```

#### Import Path Issues (Go)

```bash
// Clean module cache
go clean -modcache

// Verify module paths in current working examples
cd hsu-example1-go && go mod graph | grep hsu-example

// Use makefile for consistent builds
make clean && make setup && make build
```

#### Python Package Issues

```bash
// Use makefile for consistent Python setup
make clean && make setup && make build

// For Nuitka issues, avoid editable installs
pip install . // instead of pip install -e .
```

### Debug Logging

Enable debug logging for troubleshooting:

```bash
// Go debug logging
GRPC_GO_LOG_VERBOSITY_LEVEL=99 GRPC_GO_LOG_SEVERITY_LEVEL=info make run-server

// Python debug logging
GRPC_VERBOSITY=DEBUG GRPC_TRACE=all make run-server
```

## Universal Makefile Integration

All HSU projects benefit from using the **[Universal Makefile System](../makefile_guide/index.md)**:

```bash
// Consistent commands across all repository approaches
make setup          // Install dependencies
make proto          // Generate gRPC code
make build          // Build all components  
make test           // Run tests
make run-server     // Start development server
make clean          // Clean build artifacts
```

## Next Steps

- **[Repository Framework](../repositories/framework-overview.md)** - Understand the organization
- **[Complete Implementation Guide](../tutorials/INTEGRATED_HSU_GUIDE.md)** - Build your first HSU service
- **[Testing and Deployment](HSU_TESTING_DEPLOYMENT.md)** - Deploy your servers
- **[Universal Makefile System](../makefile_guide/index.md)** - Master the build system

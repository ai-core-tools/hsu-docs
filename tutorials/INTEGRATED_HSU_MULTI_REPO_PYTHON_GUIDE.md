# HSU Python Implementation Guide

This guide walks you through creating Python-based HSU servers using the established patterns from the `hsu-example3-common` reference implementation.

## Overview

Creating a Python-based HSU server involves:
1. Setting up Python support in the common domain repository
2. Using git submodules for dependency management
3. Implementing Python domain contracts and gRPC handlers
4. Building and packaging Python server implementations

## Step 1: Add Python Support to Common Domain Repository

### Python Directory Structure

Add to your common domain repository:

```
hsu-example3-common/
├── py/
│   ├── api/proto/          # Generated Python gRPC code
│   ├── control/
│   │   ├── handler.py      # Python gRPC ↔ domain adapter
│   │   └── serve_echo.py   # Helper function for servers
│   └── domain/
│       └── contract.py     # Python ABC definition
```

### Python Domain Contract

Create `py/domain/contract.py`:

```python
from abc import ABC, abstractmethod

class Contract(ABC):
    
    @abstractmethod
    def Echo(self, message: str) -> str:
        pass
```

### Code Generation

Create `api/proto/generate-py.sh`:

```bash
#!/bin/bash
python -m grpc_tools.protoc -I. --python_out=../../py/api/proto \
    --grpc_python_out=../../py/api/proto echoservice.proto
```

Run the generator:

```bash
cd api/proto
chmod +x generate-py.sh
./generate-py.sh
```

### Python gRPC Handler

Create `py/control/handler.py`:

```python
import sys
import os
import grpc

# Add path for proto imports
parent_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(parent_dir)
proto_dir = os.path.join(parent_dir, "api", "proto")
sys.path.append(proto_dir)

from ..api.proto import echoservice_pb2
from ..api.proto import echoservice_pb2_grpc
from ..domain.contract import Contract

def register_grpc_server_handler(grpc_server, handler: Contract):
    service = GRPCServerHandler(handler)
    echoservice_pb2_grpc.add_EchoServiceServicer_to_server(service, grpc_server)
    return service

class GRPCServerHandler(echoservice_pb2_grpc.EchoServiceServicer):
    
    def __init__(self, handler):
        self.handler = handler
    
    def Echo(self, request, context):
        try:
            response = self.handler.Echo(request.message)
            return echoservice_pb2.EchoResponse(message=response)
        except Exception as e:
            context.set_code(grpc.StatusCode.INTERNAL)
            context.set_details(f"Exception: {str(e)}")
            return None
```

### Python Helper Function

Create `py/control/serve_echo.py`:

```python
from hsu_core.py.control.server import Server
from hsu_core.py.control.def_handler import register_grpc_default_server_handler as register_core_grpc_default_server_handler
from .handler import register_grpc_server_handler as register_echo_grpc_server_handler

def serve_echo(handler):
    import argparse

    parser = argparse.ArgumentParser(description="Echo gRPC Server")
    parser.add_argument("--port", type=int, default=50055, help="Port to listen on")
    args = parser.parse_args()
    
    server = Server(args.port)
    register_core_grpc_default_server_handler(server.GRPC())
    register_echo_grpc_server_handler(server.GRPC(), handler)
    server.run(None)
```

## Step 2: Create Python Server Implementation

### Create New Repository

```bash
mkdir hsu-example3-srv-py
cd hsu-example3-srv-py
git init
```

### Add Git Submodules

```bash
# Add submodules for dependencies
git submodule add https://github.com/core-tools/hsu-core.git hsu_core
git submodule add https://github.com/core-tools/hsu-example3-common.git hsu_echo
```

### Directory Structure

```
hsu-example3-srv-py/
├── hsu_core/              # Git submodule to hsu-core
├── hsu_echo/              # Git submodule to common domain repo
├── super_handler.py       # Business logic implementation
├── run_server.py          # Entry point
├── requirements.txt       # Python dependencies
├── Makefile              # Build automation
├── .gitmodules           # Git submodule configuration
└── README.md
```

### Implement Business Logic

Create `super_handler.py`:

```python
from hsu_echo.py.domain.contract import Contract

class SuperHandler(Contract):
    def __init__(self):
        pass

    def Echo(self, message: str) -> str:
        return "py-super-echo: " + message
```

### Create Entry Point

Create `run_server.py`:

```python
#!/usr/bin/env python
"""
Entry point script for the Echo gRPC server.
"""

from hsu_echo.py.control.serve_echo import serve_echo
from super_handler import SuperHandler

def serve():
    handler = SuperHandler()
    serve_echo(handler)

if __name__ == "__main__":
    serve()
```

### Dependencies

Create `requirements.txt`:

```txt
grpcio==1.64.0
grpcio-tools==1.64.0
protobuf==5.27.0

# Optional: Add domain-specific dependencies
# numpy==1.24.0
# torch==2.0.0
```

### Build Automation

Create `Makefile`:

```makefile
.PHONY: setup run clean update-submodules

setup: update-submodules
	pip install -r requirements.txt

update-submodules:
	git submodule update --init --recursive
	git submodule foreach git pull origin main

run: setup
	python run_server.py --port 50055

clean:
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
```

## Step 3: Build and Test

### Setup and Run

```bash
make setup
make run
```

### Test with Client

The Python server can be tested with the same Go client from the common domain repository:

```bash
# In hsu-example3-common/cmd/echogrpccli/
go run main.go --address localhost:50055
```

Expected output:
```
✓ Core service health check passed
✓ Echo response: py-super-echo: Hello World!
✓ All tests passed!
```

## Key Patterns

### Git Submodules for Dependencies
Python servers use git submodules to include common domain repositories:
```bash
git submodule add https://github.com/core-tools/hsu-example3-common.git hsu_echo
```

### Helper Function Usage
Similar to Go, Python servers use the common domain's helper function:
```python
serve_echo(SuperHandler())
```

### Error Handling Pattern
Convert Python exceptions to gRPC status codes in the gRPC handler layer.

## Development Tips

### Updating Submodules

```bash
# Update all submodules to latest
git submodule foreach git pull origin main

# Update specific submodule
cd hsu_echo
git pull origin main
cd ..
git add hsu_echo
git commit -m "Update hsu_echo submodule"
```

### Managing Dependencies

For development with local changes:
```bash
# Temporarily modify submodule
cd hsu_echo
# Make changes...
cd ..

# To reset submodule to committed version
git submodule update --init hsu_echo
```

### Testing During Development

```bash
# Install development dependencies
pip install -r requirements.txt

# Run with verbose output
python run_server.py --port 50055
```

## Advanced Patterns

### Complex Handlers

For more complex domains, implement additional methods:

```python
class DataProcessorHandler(Contract):
    def __init__(self):
        self.config = {}
        self.metrics = {"processed": 0}
    
    def process_batch(self, items, options):
        # Process batch of items
        results = []
        for item in items:
            # Process each item
            processed = self.process_item(item, options)
            results.append(processed)
        
        self.metrics["processed"] += len(items)
        return results
    
    def get_metrics(self):
        return self.metrics
    
    def configure(self, config):
        self.config.update(config)
```

### Async Processing

```python
import asyncio
from concurrent.futures import ThreadPoolExecutor

class AsyncHandler(Contract):
    def __init__(self):
        self.executor = ThreadPoolExecutor(max_workers=4)
    
    def Echo(self, message: str) -> str:
        # For async processing, you might process in background
        # and return immediately, or use proper async gRPC
        return f"async-echo: {message}"
```

## Migration from Submodules

The platform plans to migrate from git submodules to Python packages:

### Current (Submodules)
```python
from hsu_echo.py.control.serve_echo import serve_echo
```

### Future (Packages)
```python
from hsu_echo.control import serve_echo
```

The import structure will remain similar, making migration straightforward.

## Next Steps

- [Go Implementation Guide](INTEGRATED_HSU_MULTI_REPO_GO_GUIDE.md) - Create Go servers
- [Testing and Deployment](../guides/HSU_TESTING_DEPLOYMENT.md) - Test and deploy your servers
- [Best Practices](../guides/HSU_BEST_PRACTICES.md) - Follow platform conventions 
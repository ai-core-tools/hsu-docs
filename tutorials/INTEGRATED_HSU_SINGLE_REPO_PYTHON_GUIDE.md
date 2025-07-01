# Single-Repository HSU Python Implementation Guide

This guide walks you through creating a single-repository, self-contained Python-based HSU server. This approach uses git submodules for dependencies and includes both server and client implementations.

## Overview

A single-repository HSU Python implementation includes:
- Protocol Buffer definitions and generated code
- Domain contracts and business logic  
- Server setup and entry point
- Python client for testing
- Git submodules for HSU core dependencies

This is ideal for:
- Learning the HSU platform with Python
- Single-implementation Python services
- Teams comfortable with Python development
- When multi-repository complexity isn't needed

## Prerequisites

- Python 3.8+
- Protocol Buffers compiler (`protoc`)
- Git (for submodules)
- Basic understanding of gRPC and Python

## Step 1: Create Project Structure

```bash
mkdir hsu-example2-py
cd hsu-example2-py
git init
```

Create the directory structure:

```
hsu-example2-py/
├── api/
│   └── proto/
│       ├── echoservice.proto
│       ├── generate-py.sh
│       └── generate-py.bat
├── src/
│   ├── api/
│   │   └── proto/            # Generated Python gRPC code
│   ├── control/
│   │   ├── handler.py        # gRPC ↔ domain adapter
│   │   ├── gateway.py        # Client gateway
│   │   └── serve_echo.py     # Server setup helper
│   └── domain/
│       ├── contract.py       # Domain ABC
│       └── simple_handler.py # Business logic
├── hsu_core/                 # Git submodule
├── run_server.py             # Server entry point
├── run_client.py             # Client for testing
├── requirements.txt          # Python dependencies
├── Makefile                  # Build automation
├── .gitmodules              # Git submodule config
└── README.md
```

## Step 2: Add Git Submodules

```bash
# Add HSU core dependency
git submodule add https://github.com/core-tools/hsu-core.git hsu_core
git submodule update --init --recursive
```

## Step 3: Define Protocol Buffer Service

Create `api/proto/echoservice.proto`:

```proto
syntax = "proto3";

option go_package = "github.com/your-org/hsu-example2-py/api/proto";

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

## Step 4: Generate Python Code

Create `api/proto/generate-py.sh`:

```bash
#!/bin/bash
python -m grpc_tools.protoc -I. --python_out=../../src/api/proto \
    --grpc_python_out=../../src/api/proto echoservice.proto
```

Create `api/proto/generate-py.bat` (Windows):

```batch
@echo off
python -m grpc_tools.protoc -I. --python_out=../../src/api/proto ^
    --grpc_python_out=../../src/api/proto echoservice.proto
```

## Step 5: Setup Dependencies

Create `requirements.txt`:

```txt
grpcio==1.64.0
grpcio-tools==1.64.0
protobuf==5.27.0
```

Install dependencies:

```bash
pip install -r requirements.txt
```

Generate the code:

```bash
cd api/proto
chmod +x generate-py.sh
./generate-py.sh
```

## Step 6: Define Domain Contract

Create `src/domain/contract.py`:

```python
from abc import ABCMeta, abstractmethod

class Contract:
    __metaclass__ = ABCMeta

    @abstractmethod
    def Echo(self, message: str) -> str:
        pass
```

## Step 7: Implement Business Logic  

Create `src/domain/simple_handler.py`:

```python
from .contract import Contract

class SimpleHandler(Contract):
    def __init__(self):
        pass

    def Echo(self, message: str) -> str:
        print(f"Processing echo request: {message}")
        response = "py-simple-echo: " + message
        print(f"Echo response: {response}")
        return response
```

## Step 8: Create gRPC Handler

Create `src/control/handler.py`:

```python
import sys
import os
import grpc

# Add path for proto imports
current_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(current_dir)
proto_dir = os.path.join(current_dir, "api", "proto")
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

## Step 9: Create Server Setup Helper

Create `src/control/serve_echo.py`:

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

## Step 10: Create Server Entry Point

Create `run_server.py`:

```python
#!/usr/bin/env python
"""
Entry point script for the Echo gRPC server.
"""

from src.control.serve_echo import serve_echo
from src.domain.simple_handler import SimpleHandler

def serve():
    handler = SimpleHandler()
    serve_echo(handler)

if __name__ == "__main__":
    serve()
```

## Step 11: Create Test Client

Create `src/control/gateway.py`:

```python
import sys
import os

# Add path for proto imports
current_dir = os.path.dirname(os.path.dirname(os.path.abspath(__file__)))
sys.path.append(current_dir)

from .api.proto import echoservice_pb2
from .api.proto import echoservice_pb2_grpc

class Gateway:
    
    def __init__(self, grpc_channel):
        self.stub = echoservice_pb2_grpc.EchoServiceStub(grpc_channel)
    
    def Echo(self, message: str) -> str:
        request = echoservice_pb2.EchoRequest(message=message)
        response = self.stub.Echo(request)
        return response.message
```

Create `run_client.py`:

```python
import argparse
import time

parser = argparse.ArgumentParser(description="Echo gRPC Client")
parser.add_argument("--port", type=int, default=50055, help="Port to connect to")
args = parser.parse_args()

from hsu_core.py.control.client_conn import ClientConn
from hsu_core.py.control.gateway import Gateway as CoreGateway
from src.control.gateway import Gateway as EchoGateway

retry_period = 1
while True:
    try:
        client_conn = ClientConn(args.port)
        core_gateway = CoreGateway(client_conn.GRPC())
        echo_gateway = EchoGateway(client_conn.GRPC())

        # Test core service (health check)
        core_gateway.Ping()
        print("✓ Core service health check passed")

        # Test echo service
        message = echo_gateway.Echo("Hello, World!")
        print(f"✓ Echo response: {message}")
        print("✓ All tests passed!")

        break
    except Exception as e:
        if "Connection refused" in str(e):
            print(f"Connection error, retrying in {retry_period} second...")
            time.sleep(retry_period)
            retry_period *= 2
            continue
        else:
            print(f"Error: {e}")
            raise e
```

## Step 12: Create Build Automation

Create `Makefile`:

```makefile
.PHONY: setup run run-client clean update-submodules

setup: update-submodules
	pip install -r requirements.txt

update-submodules:
	git submodule update --init --recursive
	git submodule foreach git pull origin main

run: setup
	python run_server.py --port 50055

run-client: setup
	python run_client.py --port 50055

clean:
	find . -name "*.pyc" -delete
	find . -name "__pycache__" -delete
```

## Step 13: Build and Run

### Setup Environment

```bash
make setup
```

### Run the Server

```bash
make run
# or
python run_server.py --port 50055
```

### Test with Client

In another terminal:

```bash
make run-client
# or
python run_client.py --port 50055
```

Expected output:
```
✓ Core service health check passed
✓ Echo response: py-simple-echo: Hello, World!
✓ All tests passed!
```

## Key Features

### Git Submodules
- Exact version control of dependencies
- Offline development capability
- Simple setup for development teams

### Python Client Integration
- Complete client implementation included
- Shows both server and client patterns
- Easy testing and validation

### Self-Contained Structure
- All code in one repository
- Direct control over implementation
- Easy to understand and modify

## Development Workflow

### Updating Dependencies

```bash
# Update all submodules
make update-submodules

# Or manually:
cd hsu_core
git pull origin main
cd ..
git add hsu_core
git commit -m "Update hsu_core submodule"
```

### Development with Local Changes

```bash
# Make changes to submodule
cd hsu_core
# Make your changes...
cd ..

# To reset submodule to committed version
git submodule update --init hsu_core
```

## Key Advantages

### Single-Repository Setup
- Single repository with everything needed
- Git submodules handle dependencies reliably
- Make commands automate common tasks

### Python-First Development
- Natural Python project structure
- Includes both server and client examples
- Easy integration with Python ecosystem

### Perfect for Learning
- All patterns visible in one place
- Easy to trace execution flow
- Complete working example

## When to Use Single-Repository vs Multi-Repository Structure

### Use Single-Repository Structure When:
- Learning the HSU platform with Python
- Building a single Python server implementation  
- Rapid prototyping with Python
- Small teams or individual development
- Don't need multiple language implementations

### Consider Multi-Repository Structure When:
- Need both Go and Python implementations
- Want to share common components across teams
- Building production systems with multiple variants
- Need independent versioning of implementations

## Migration Path

This single-repository structure can easily evolve:

1. **Current**: Everything in one repository with submodules
2. **Future**: Extract to multi-repository structure when needed
3. **Package Migration**: Later migrate from submodules to Python packages

## Next Steps

- Study the [Protocol Buffer Definition Guide](../guides/HSU_PROTOCOL_BUFFERS.md) to understand gRPC contracts
- Explore the [Multi-Repository Implementation Guides](INTEGRATED_HSU_MULTI_REPO_PYTHON_GUIDE.md) when you need multi-repository structure
- Check [Best Practices](../guides/HSU_BEST_PRACTICES.md) for production deployment 
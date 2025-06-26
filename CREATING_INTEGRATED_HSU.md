# Creating an Integrated HSU

This guide walks you through creating an Integrated HSU process that implements both core HSU functionality and custom business logic through gRPC APIs, following the HSU platform's repository structure pattern.

## Overview

An Integrated HSU is a process that:
- **Implements Core HSU Interface**: Provides health checks, logging, and lifecycle management
- **Exposes Business APIs**: Custom gRPC services for domain-specific functionality
- **Self-Manages**: Handles graceful startup and shutdown
- **Integrates Deeply**: Communicates with master processes through type-safe gRPC APIs

## Quick Start

1. **[Understand the Repository Structure](HSU_REPOSITORY_STRUCTURE.md)** - Learn the HSU platform's approach to organizing code across repositories
2. **[Create a Go Server Implementation](HSU_GO_IMPLEMENTATION.md)** - Build an HSU server using Go
3. **[Create a Python Server Implementation](HSU_PYTHON_IMPLEMENTATION.md)** - Build an HSU server using Python
4. **[Test and Deploy](HSU_TESTING_DEPLOYMENT.md)** - Test your implementation and deploy it
5. **[Follow Best Practices](HSU_BEST_PRACTICES.md)** - Ensure your implementation follows platform conventions

## Prerequisites

- Go 1.22+ or Python 3.8+ installed
- Basic understanding of gRPC and Protocol Buffers
- Git for managing repositories and submodules (Python)
- Familiarity with the HSU platform concepts

## Complete Example

The `hsu-echo` domain serves as the reference implementation demonstrating all patterns:

- **Common domain repository**: [`hsu-echo/`](../hsu-echo/) - Contains shared protocol buffers, contracts, and utilities
- **Go server implementation**: [`hsu-echo-super-srv-go/`](../hsu-echo-super-srv-go/) - Simple Go server 
- **Python server implementation**: [`hsu-echo-super-srv-py/`](../hsu-echo-super-srv-py/) - Python server with submodules

## Guide Structure

### [Repository Structure](HSU_REPOSITORY_STRUCTURE.md)
Learn about the HSU platform's repository organization philosophy, including:
- Common domain repositories vs server implementation repositories
- The rationale behind separating shared components from implementations
- How to manage multiple language implementations

### [Go Implementation Guide](HSU_GO_IMPLEMENTATION.md)
Step-by-step guide for creating Go-based HSU servers:
- Setting up the common domain repository with Go support
- Creating gRPC service definitions and generating Go code
- Implementing domain contracts and gRPC handlers
- Building and running Go server implementations

### [Python Implementation Guide](HSU_PYTHON_IMPLEMENTATION.md)
Complete guide for Python-based HSU servers:
- Setting up Python support in the common domain repository
- Using git submodules for dependency management
- Implementing Python domain contracts and gRPC handlers
- Building and packaging Python server implementations

### [Testing and Deployment](HSU_TESTING_DEPLOYMENT.md)
Best practices for testing and deploying HSU servers:
- Creating client applications for testing
- Integration testing across language implementations
- Deployment strategies and monitoring

### [Best Practices](HSU_BEST_PRACTICES.md)
Platform conventions and recommendations:
- Error handling patterns
- Logging and monitoring
- Configuration management
- Repository management workflows

## Next Steps

Once you've created your HSU implementation, explore these related topics:

- [Working with gRPC Services](GRPC_SERVICES.md) - Advanced gRPC patterns
- [Multi-Language Support](MULTI_LANGUAGE.md) - Language-specific considerations
- [Process Management](PROCESS_MANAGEMENT.md) - Managing HSU processes
- [Creating HSU Masters](CREATING_HSU_MASTER.md) - Building master processes

## Getting Help

- Check the [troubleshooting sections](HSU_BEST_PRACTICES.md#troubleshooting) in each guide
- Review the reference implementation in `hsu-echo/`
- Consult the [Developer Guide](DEVELOPER_GUIDE.md) for broader platform concepts 
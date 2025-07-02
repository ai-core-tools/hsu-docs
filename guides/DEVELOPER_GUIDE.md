# HSU Platform Developer Guide

This guide helps developers create HSU master processes and integrated HSU units. The HSU platform is currently in early development but already provides core functionality for building microservice architectures.

## Quick Navigation

### Getting Started
- [Development Setup](DEVELOPMENT_SETUP.md) - Setting up your development environment
- [HSU Master Guide](HSU_MASTER_GUIDE.md) - Comprehensive platform overview

### Implementation Guides
- [Creating an HSU Master Process](HSU_MASTER_GUIDE.md) - Step-by-step guide for building master processes
- [**Complete HSU Implementation Guide**](../tutorials/INTEGRATED_HSU_GUIDE.md) - **Comprehensive guide covering all 3 approaches with working examples**
- [HSU Tutorial Index](../tutorials/index.md) - Navigation hub for approach-specific tutorials
- [Working with gRPC Services](../reference/GRPC_SERVICES.md) - Defining and implementing gRPC interfaces

### Reference Documentation
- [Platform API Reference](../reference/API_REFERENCE.md) - Complete API documentation
- [Configuration Guide](../deployment/CONFIGURATION.md) - Configuration management and best practices
- [Examples and Patterns](../reference/EXAMPLES.md) - Code examples and common patterns

### Advanced Topics
- [Multi-Language Support](MULTI_LANGUAGE.md) - Implementing HSUs in different languages
- [Process Management](PROCESS_MANAGEMENT.md) - Advanced process lifecycle control
- [Testing and Debugging](TESTING_DEBUGGING.md) - Testing strategies and debugging techniques

## Current Implementation Status

The HSU platform currently supports:

✅ **Core Infrastructure**
- gRPC-based service definitions (CoreService, EchoService)
- Go and Python client/server libraries
- Cross-platform process management
- Basic logging and error handling

✅ **Master Process Capabilities**
- gRPC server hosting multiple services
- Process lifecycle management (spawn, monitor, restart)
- Client connection management
- Graceful shutdown handling

✅ **Integrated HSU Support**
- Service registration and discovery
- Health check mechanisms (ping)
- Multi-service hosting in single process
- Language-agnostic client libraries

🚧 **In Development**
- Configuration management
- Advanced health monitoring
- Auto-scaling capabilities
- Service mesh features

## Architecture Summary

```
┌─────────────────────────────────────────────────────────────┐
│                    HSU Ecosystem                            │
├─────────────────────────────────────────────────────────────┤
│                                                             │
│  ┌─────────────────┐    gRPC     ┌──────────────────────┐   │
│  │   HSU Master    │◄────────────┤  Integrated HSU      │   │
│  │   Process       │             │  Process             │   │
│  │                 │             │                      │   │
│  │ • Service       │             │ • Business Logic     │   │
│  │   Discovery     │             │ • Core + Custom APIs │   │
│  │ • Process Mgmt  │             │ • Health Checks      │   │
│  │ • Load Balance  │             │ • Graceful Shutdown  │   │
│  └─────────────────┘             └──────────────────────┘   │
│         │                                   │               │
│         │ Process                          │                │
│         │ Control                          │                │
│         ▼                                   ▼               │
│  ┌─────────────────┐             ┌──────────────────────┐   │
│  │   Managed HSU   │             │   Unmanaged HSU      │   │
│  │   Process       │             │   Process            │   │
│  │                 │             │                      │   │
│  │ • Full Control  │             │ • Discovery Only     │   │
│  │ • Restart Logic │             │ • Basic Monitoring   │   │
│  │ • I/O Capture   │             │ • External Lifecycle │   │
│  └─────────────────┘             └──────────────────────┘   │
│                                                             │
└─────────────────────────────────────────────────────────────┘
```

## Example Applications

The platform includes several working examples organized by repository approach:

**Core Framework:**
- **hsu-core** - Core platform libraries for Go and Python

**Approach 1: Single-Repository + Single-Language**
- **hsu-example1-go** - Pure Go implementation with full gRPC stack
- **hsu-example1-py** - Pure Python implementation with gRPC services

**Approach 2: Single-Repository + Multi-Language**
- **hsu-example2** - Go and Python services in one repository with shared protocols

**Approach 3: Multi-Repository Architecture**
- **hsu-example3-common** - Shared protocols and client libraries
- **hsu-example3-srv-go** - Go microservice implementation
- **hsu-example3-srv-py** - Python microservice implementation

## Next Steps

1. **For Platform Users**: Start with [Creating an HSU Master Process](HSU_MASTER_GUIDE.md)
2. **For Service Developers**: Begin with [Creating an Integrated HSU](../tutorials/INTEGRATED_HSU_GUIDE.md)
3. **For Contributors**: Review [Development Setup](DEVELOPMENT_SETUP.md) and the platform source code

## Need Help?

- Check the [Examples and Patterns](../reference/EXAMPLES.md) for common implementation patterns
- Review the working examples in the repository
- For advanced scenarios, see the [API Reference](../reference/API_REFERENCE.md)

The HSU platform is designed to grow with your needs - start simple and add complexity as your requirements evolve. 
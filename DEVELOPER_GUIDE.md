# HSU Platform Developer Guide

This guide helps developers create HSU master processes and integrated HSU units. The HSU platform is currently in early development but already provides core functionality for building microservice architectures.

## Quick Navigation

### Getting Started
- [Platform Overview](PLATFORM_OVERVIEW.md) - Understanding HSU concepts and architecture
- [Development Setup](DEVELOPMENT_SETUP.md) - Setting up your development environment

### Implementation Guides
- [Creating an HSU Master Process](CREATING_HSU_MASTER.md) - Step-by-step guide for building master processes
- [Creating an Integrated HSU](CREATING_INTEGRATED_HSU.md) - Step-by-step guide for building HSU units
- [Working with gRPC Services](GRPC_SERVICES.md) - Defining and implementing gRPC interfaces

### Reference Documentation
- [Platform API Reference](API_REFERENCE.md) - Complete API documentation
- [Configuration Guide](CONFIGURATION.md) - Configuration management and best practices
- [Examples and Patterns](EXAMPLES.md) - Code examples and common patterns

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

The platform includes several working examples:

- **hsu-core** - Core platform libraries for Go and Python
- **hsu-echo** - Simple echo service demonstrating gRPC integration
- **hsu-echo-cli-go** - Go client demonstrating master-to-HSU communication
- **hsu-echo-super-srv-go** - Go server implementing integrated HSU pattern
- **hsu-echo-super-srv-py** - Python server demonstrating cross-language support

## Next Steps

1. **For Platform Users**: Start with [Creating an HSU Master Process](CREATING_HSU_MASTER.md)
2. **For Service Developers**: Begin with [Creating an Integrated HSU](CREATING_INTEGRATED_HSU.md)
3. **For Contributors**: Review [Development Setup](DEVELOPMENT_SETUP.md) and the platform source code

## Need Help?

- Check the [Examples and Patterns](EXAMPLES.md) for common implementation patterns
- Review the working examples in the repository
- For advanced scenarios, see the [API Reference](API_REFERENCE.md)

The HSU platform is designed to grow with your needs - start simple and add complexity as your requirements evolve. 
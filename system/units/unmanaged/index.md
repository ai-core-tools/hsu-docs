# Creating an Unmanaged Unit Integration

This guide walks you through integrating existing processes as Unmanaged Units in your HSU system.

## What is an Unmanaged Unit?

An Unmanaged Unit is a process whose **lifecycle is NOT controlled** by the master process, but can still be integrated into the HSU ecosystem through:
- **Discovery**: Locate processes by name, PID, or network endpoints
- **Monitoring**: Track memory usage, CPU consumption, and health status
- **Basic Control**: Terminate or signal processes when necessary
- **Integration**: Include in master process orchestration and monitoring

Unmanaged units are ideal for **existing systems** that you want to integrate without modification, providing HSU-style management of legacy or third-party processes.

## Architecture Integration

```
┌─────────────────┐    Discovery     ┌─────────────────┐
│   Master        │◄────────────────►│   Unmanaged     │
│   Process       │    Monitoring    │   Unit          │
│                 │◄────────────────►│   (External)    │
│                 │    Control       │                 │
└─────────────────┘                  └─────────────────┘
```

The master process uses **OS-level APIs** to interact with unmanaged units:
- **Windows**: Process APIs, Performance Counters, WMI
- **Linux**: `/proc` filesystem, `ps`, `kill`, `systemctl`
- **macOS**: Process APIs, `ps`, `kill`, `launchctl`

## Use Cases and Examples

### Database Integration
Monitor and manage database servers without modifying their configuration:

```go
// PostgreSQL monitoring example
postgres := &UnmanagedUnit{
    Name: "postgresql",
    ProcessName: "postgres",
    Port: 5432,
    HealthCheck: func() error {
        conn, err := sql.Open("postgres", "postgres://...")
        if err != nil {
            return err
        }
        defer conn.Close()
        return conn.Ping()
    },
}
```

### System Service Integration
Integrate with system daemons and services:

```go
// SSH daemon monitoring
sshd := &UnmanagedUnit{
    Name: "sshd",
    ProcessName: "sshd",
    Port: 22,
    ServiceName: "ssh", // For systemd/Windows services
    MonitoringConfig: MonitoringConfig{
        CPUThreshold: 80.0,
        MemoryThreshold: 512 * 1024 * 1024, // 512MB
        HealthInterval: 30 * time.Second,
    },
}
```

### Third-Party Application Integration
Monitor existing applications and services:

```go
// Redis monitoring
redis := &UnmanagedUnit{
    Name: "redis",
    ProcessName: "redis-server",
    Port: 6379,
    HealthCheck: func() error {
        conn, err := net.Dial("tcp", "localhost:6379")
        if err != nil {
            return err
        }
        defer conn.Close()
        // Send PING command
        _, err = conn.Write([]byte("PING\r\n"))
        return err
    },
}
```

### Legacy System Integration
Integrate with existing enterprise systems:

```go
// Legacy application monitoring
legacyApp := &UnmanagedUnit{
    Name: "legacy-erp",
    ProcessName: "erp-server",
    Port: 8080,
    DiscoveryConfig: DiscoveryConfig{
        Method: "process-name", // or "port", "pid-file"
        CheckInterval: 60 * time.Second,
    },
    AlertConfig: AlertConfig{
        OnProcessDown: true,
        OnHighCPU: true,
        OnHighMemory: true,
    },
}
```

## Implementation Guide

### Step 1: Discovery Configuration

Choose how the master process will discover your unmanaged unit:

```go
type DiscoveryConfig struct {
    Method string // "process-name", "port", "pid-file", "service-name"
    
    // Process name discovery
    ProcessName string
    ProcessArgs []string // Optional: match by command line args
    
    // Port discovery
    Port int
    Protocol string // "tcp", "udp"
    
    // PID file discovery
    PIDFile string
    
    // Service discovery (systemd, Windows services)
    ServiceName string
    
    // Discovery frequency
    CheckInterval time.Duration
}
```

### Step 2: Monitoring Configuration

Define what metrics to track and thresholds for alerts:

```go
type MonitoringConfig struct {
    // Resource monitoring
    CPUThreshold    float64        // CPU percentage threshold
    MemoryThreshold int64          // Memory usage threshold in bytes
    
    // Health checking
    HealthInterval  time.Duration  // How often to check health
    HealthTimeout   time.Duration  // Health check timeout
    HealthCheck     func() error   // Custom health check function
    
    // Network monitoring
    NetworkCheck    bool           // Monitor network connections
    PortCheck       bool           // Check if port is listening
    
    // Log monitoring (if accessible)
    LogFile         string         // Log file to monitor
    LogPatterns     []string       // Patterns to watch for
}
```

### Step 3: Control Configuration

Define what control operations are available:

```go
type ControlConfig struct {
    // Basic control
    CanTerminate bool              // Can send SIGTERM/SIGKILL
    CanRestart   bool              // Can restart (via service manager)
    
    // Service manager integration
    ServiceManager string          // "systemd", "windows", "launchd"
    ServiceName    string          // Service name for restart
    
    // Process signals
    AllowedSignals []os.Signal     // Allowed signals to send
    
    // Graceful shutdown
    GracefulTimeout time.Duration  // Time to wait for graceful shutdown
}
```

### Step 4: Master Process Integration

Integrate unmanaged units into your master process:

```go
// In your master process
func (m *HSUMaster) RegisterUnmanagedUnit(unit *UnmanagedUnit) error {
    // Start discovery
    if err := m.startDiscovery(unit); err != nil {
        return err
    }
    
    // Start monitoring
    if err := m.startMonitoring(unit); err != nil {
        return err
    }
    
    // Register for control operations
    m.registerControlHandlers(unit)
    
    m.unmanagedUnits[unit.Name] = unit
    return nil
}

func (m *HSUMaster) startDiscovery(unit *UnmanagedUnit) error {
    ticker := time.NewTicker(unit.DiscoveryConfig.CheckInterval)
    go func() {
        for range ticker.C {
            if err := m.discoverUnit(unit); err != nil {
                m.logger.Warnf("Discovery failed for %s: %v", unit.Name, err)
            }
        }
    }()
    return nil
}

func (m *HSUMaster) discoverUnit(unit *UnmanagedUnit) error {
    switch unit.DiscoveryConfig.Method {
    case "process-name":
        return m.discoverByProcessName(unit)
    case "port":
        return m.discoverByPort(unit)
    case "pid-file":
        return m.discoverByPIDFile(unit)
    case "service-name":
        return m.discoverByServiceName(unit)
    default:
        return fmt.Errorf("unknown discovery method: %s", unit.DiscoveryConfig.Method)
    }
}
```

### Step 5: Cross-Platform Process Operations

Implement OS-specific operations using HSU Core library:

```go
import (
    coreProcess "github.com/core-tools/hsu-core/go/process"
)

func (m *HSUMaster) getProcessInfo(unit *UnmanagedUnit) (*ProcessInfo, error) {
    // Use HSU Core cross-platform process operations
    processes, err := coreProcess.FindProcessesByName(unit.ProcessName)
    if err != nil {
        return nil, err
    }
    
    if len(processes) == 0 {
        return nil, fmt.Errorf("process %s not found", unit.ProcessName)
    }
    
    proc := processes[0] // Take first match
    
    // Get process details
    info := &ProcessInfo{
        PID:        proc.PID,
        Name:       proc.Name,
        CPUPercent: proc.CPUPercent(),
        MemoryUsage: proc.MemoryUsage(),
        Status:     proc.Status(),
        StartTime:  proc.StartTime(),
    }
    
    return info, nil
}
```

## Integration Patterns

### Pattern 1: Passive Monitoring
Monitor existing services without any control:

```go
unit := &UnmanagedUnit{
    Name: "monitoring-only",
    DiscoveryConfig: DiscoveryConfig{
        Method: "process-name",
        ProcessName: "existing-service",
        CheckInterval: 30 * time.Second,
    },
    MonitoringConfig: MonitoringConfig{
        CPUThreshold: 90.0,
        MemoryThreshold: 1024 * 1024 * 1024, // 1GB
        HealthInterval: 60 * time.Second,
    },
    ControlConfig: ControlConfig{
        CanTerminate: false, // Read-only monitoring
        CanRestart: false,
    },
}
```

### Pattern 2: Service Manager Integration
Integrate with systemd, Windows services, or launchd:

```go
unit := &UnmanagedUnit{
    Name: "service-managed",
    DiscoveryConfig: DiscoveryConfig{
        Method: "service-name",
        ServiceName: "nginx",
        CheckInterval: 30 * time.Second,
    },
    ControlConfig: ControlConfig{
        CanTerminate: true,
        CanRestart: true,
        ServiceManager: "systemd",
        ServiceName: "nginx",
    },
}
```

### Pattern 3: Health Check Integration
Add custom health checks for better monitoring:

```go
unit := &UnmanagedUnit{
    Name: "health-checked",
    ProcessName: "web-server",
    MonitoringConfig: MonitoringConfig{
        HealthInterval: 30 * time.Second,
        HealthCheck: func() error {
            resp, err := http.Get("http://localhost:8080/health")
            if err != nil {
                return err
            }
            defer resp.Body.Close()
            
            if resp.StatusCode != http.StatusOK {
                return fmt.Errorf("health check failed: %d", resp.StatusCode)
            }
            return nil
        },
    },
}
```

### Pattern 4: Hybrid HSU System
Combine unmanaged units with managed and integrated units:

```go
func (m *HSUMaster) setupHybridSystem() {
    // Unmanaged: Existing database
    postgres := &UnmanagedUnit{
        Name: "postgres",
        ProcessName: "postgres",
        Port: 5432,
    }
    m.RegisterUnmanagedUnit(postgres)
    
    // Managed: Background workers
    worker := &ManagedUnit{
        Name: "data-processor",
        ExecutablePath: "./bin/worker",
        Args: []string{"--config", "worker.conf"},
    }
    m.RegisterManagedUnit(worker)
    
    // Integrated: Main API server
    api := &IntegratedUnit{
        Name: "api-server",
        ExecutablePath: "./bin/api-server",
        GRPCPort: 50051,
    }
    m.RegisterIntegratedUnit(api)
}
```

## Next Steps

- **[Master Process Guide](../../master/index.md)** - Implement master process with unmanaged unit support
- **[Managed Unit Guide](../managed/index.md)** - Add managed units for full lifecycle control
- **[Integrated Unit Guide](../integrated/index.md)** - Implement deep gRPC integration

---

*You are here: System > Units > **Unmanaged Units***

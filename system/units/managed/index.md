# Creating a Managed Unit

This guide walks you through implementing processes as Managed Units in your HSU system.

## What is a Managed Unit?

A Managed Unit is a process whose **complete lifecycle is controlled** by the master process, including:
- **Process Control**: Start, stop, restart, and signal operations
- **Environment Management**: Working directory, environment variables, and PATH
- **I/O Handling**: stdout/stderr redirection, logging, and processing
- **Configuration**: Command-line parameters and runtime arguments
- **Resource Management**: CPU, RAM limits, and process constraints
- **Monitoring**: Health checks, performance metrics, and failure detection

Managed units are ideal for **custom applications** designed to work within the HSU ecosystem, providing full orchestration control while maintaining process isolation.

## Architecture Integration

```
┌─────────────────┐    Full Control   ┌─────────────────┐
│   Master        │◄─────────────────►│   Managed       │
│   Process       │   Start/Stop      │   Unit          │
│                 │   Environment     │   (Controlled)  │
│                 │   I/O & Logs      │                 │
│                 │   Resources       │                 │
└─────────────────┘                   └─────────────────┘
```

The master process uses **OS-level process control** to manage units:
- **Process Creation**: `exec`, `CreateProcess`
- **Signal Handling**: `SIGTERM`, `SIGKILL`, `SIGINT`
- **Resource Control**: `setrlimit`, `cgroups`, process priority
- **I/O Redirection**: pipes, files, logging systems

## Use Cases and Examples

### Background Workers
Spawn and manage data processing workers:

```go
// Data processing worker
worker := &ManagedUnit{
    Name: "data-processor",
    ExecutablePath: "./bin/worker",
    Args: []string{
        "--config", "worker.conf",
        "--batch-size", "1000",
        "--workers", "4",
    },
    Environment: map[string]string{
        "LOG_LEVEL": "info",
        "DATABASE_URL": "postgres://localhost/mydb",
    },
    WorkingDirectory: "/opt/myapp",
    RestartPolicy: RestartAlways,
}
```

### Microservice Components
Control custom REST APIs and services:

```go
// API microservice
api := &ManagedUnit{
    Name: "user-api",
    ExecutablePath: "./bin/user-api",
    Args: []string{"--port", "8080"},
    Environment: map[string]string{
        "PORT": "8080",
        "ENV": "production",
    },
    HealthCheck: HealthCheckConfig{
        Type: "http",
        URL: "http://localhost:8080/health",
        Interval: 30 * time.Second,
        Timeout: 5 * time.Second,
    },
    ResourceLimits: ResourceLimits{
        CPU: 2.0,        // 2 CPU cores
        Memory: 1024 * 1024 * 1024, // 1GB
    },
}
```

### Batch Processing Jobs
Manage temporary compute tasks:

```go
// Batch job
batch := &ManagedUnit{
    Name: "nightly-report",
    ExecutablePath: "./bin/report-generator",
    Args: []string{
        "--date", time.Now().Format("2006-01-02"),
        "--format", "pdf",
        "--output", "/tmp/reports/",
    },
    Schedule: ScheduleConfig{
        Type: "cron",
        Expression: "0 2 * * *", // 2 AM daily
    },
    RestartPolicy: RestartOnFailure,
    MaxRetries: 3,
}
```

### Development Tools
Control development servers and build processes:

```go
// Development server
devServer := &ManagedUnit{
    Name: "dev-server",
    ExecutablePath: "npm",
    Args: []string{"run", "dev"},
    Environment: map[string]string{
        "NODE_ENV": "development",
        "PORT": "3000",
    },
    WorkingDirectory: "/path/to/frontend",
    RestartPolicy: RestartOnFailure,
    AutoStart: true,
}
```

## Implementation Guide

### Step 1: Process Configuration

Define the basic process parameters:

```go
type ManagedUnit struct {
    // Identity
    Name        string
    Description string
    
    // Process execution
    ExecutablePath   string
    Args            []string
    Environment     map[string]string
    WorkingDirectory string
    
    // Process control
    RestartPolicy   RestartPolicy
    AutoStart       bool
    MaxRetries      int
    
    // Resource management
    ResourceLimits  ResourceLimits
    Priority        int
    
    // I/O handling
    LogConfig       LogConfig
    StdoutRedirect  string
    StderrRedirect  string
    
    // Health monitoring
    HealthCheck     HealthCheckConfig
    
    // Scheduling
    Schedule        ScheduleConfig
}
```

### Step 2: Restart Policy Configuration

Define how the master process should handle failures:

```go
type RestartPolicy string

const (
    RestartNever        RestartPolicy = "never"
    RestartOnFailure    RestartPolicy = "on-failure"
    RestartAlways       RestartPolicy = "always"
    RestartUnlessStopped RestartPolicy = "unless-stopped"
)

type RestartConfig struct {
    Policy      RestartPolicy
    MaxRetries  int
    RetryDelay  time.Duration
    BackoffRate float64  // Exponential backoff multiplier
}
```

### Step 3: Resource Management

Control CPU, memory, and process limits:

```go
type ResourceLimits struct {
    // CPU limits
    CPU         float64     // Number of CPU cores
    CPUShares   int         // CPU weight (Linux cgroups)
    
    // Memory limits
    Memory      int64       // Memory limit in bytes
    MemorySwap  int64       // Memory + swap limit
    
    // Process limits
    MaxProcesses int        // Maximum number of processes
    MaxOpenFiles int        // Maximum open file descriptors
    
    // I/O limits
    IOWeight    int         // I/O priority weight
    IOReadBPS   int64       // Read bandwidth limit
    IOWriteBPS  int64       // Write bandwidth limit
}
```

### Step 4: Health Check Configuration

Define how to monitor process health:

```go
type HealthCheckConfig struct {
    Type     string        // "http", "tcp", "exec", "process"
    
    // HTTP health check
    URL      string
    Method   string
    Headers  map[string]string
    
    // TCP health check
    Address  string
    Port     int
    
    // Exec health check
    Command  string
    Args     []string
    
    // Check configuration
    Interval time.Duration
    Timeout  time.Duration
    Retries  int
    
    // Success/failure thresholds
    SuccessThreshold int
    FailureThreshold int
}
```

### Step 5: Master Process Integration

Integrate managed units into your master process:

```go
// In your master process
func (m *HSUMaster) RegisterManagedUnit(unit *ManagedUnit) error {
    // Validate configuration
    if err := m.validateManagedUnit(unit); err != nil {
        return err
    }
    
    // Create process manager
    manager := &ProcessManager{
        Unit:   unit,
        Logger: m.logger.WithField("unit", unit.Name),
    }
    
    // Start if auto-start is enabled
    if unit.AutoStart {
        if err := manager.Start(); err != nil {
            return err
        }
    }
    
    // Register for control operations
    m.managedUnits[unit.Name] = manager
    
    // Start health monitoring
    if unit.HealthCheck.Type != "" {
        m.startHealthMonitoring(manager)
    }
    
    return nil
}
```

### Step 6: Process Manager Implementation

Implement the core process management logic:

```go
type ProcessManager struct {
    Unit     *ManagedUnit
    Process  *os.Process
    Logger   logging.Logger
    
    // State tracking
    State      ProcessState
    StartTime  time.Time
    ExitCode   int
    RestartCount int
    
    // Channels for control
    stopChan   chan struct{}
    restartChan chan struct{}
}

func (pm *ProcessManager) Start() error {
    pm.Logger.Infof("Starting managed unit: %s", pm.Unit.Name)
    
    // Prepare command
    cmd := exec.Command(pm.Unit.ExecutablePath, pm.Unit.Args...)
    
    // Set working directory
    if pm.Unit.WorkingDirectory != "" {
        cmd.Dir = pm.Unit.WorkingDirectory
    }
    
    // Set environment
    cmd.Env = os.Environ()
    for key, value := range pm.Unit.Environment {
        cmd.Env = append(cmd.Env, fmt.Sprintf("%s=%s", key, value))
    }
    
    // Configure I/O redirection
    if err := pm.configureIO(cmd); err != nil {
        return err
    }
    
    // Apply resource limits
    if err := pm.applyResourceLimits(cmd); err != nil {
        return err
    }
    
    // Start the process
    if err := cmd.Start(); err != nil {
        return err
    }
    
    pm.Process = cmd.Process
    pm.State = ProcessRunning
    pm.StartTime = time.Now()
    
    // Monitor process
    go pm.monitorProcess(cmd)
    
    return nil
}

func (pm *ProcessManager) Stop() error {
    if pm.Process == nil {
        return nil
    }
    
    pm.Logger.Infof("Stopping managed unit: %s", pm.Unit.Name)
    
    // Try graceful shutdown first
    if err := pm.Process.Signal(os.Interrupt); err != nil {
        pm.Logger.Warnf("Failed to send interrupt: %v", err)
    }
    
    // Wait for graceful shutdown
    gracefulTimeout := 30 * time.Second
    if pm.Unit.GracefulTimeout > 0 {
        gracefulTimeout = pm.Unit.GracefulTimeout
    }
    
    done := make(chan error, 1)
    go func() {
        _, err := pm.Process.Wait()
        done <- err
    }()
    
    select {
    case <-done:
        pm.Logger.Infof("Process stopped gracefully")
    case <-time.After(gracefulTimeout):
        pm.Logger.Warnf("Process didn't stop gracefully, forcing kill")
        if err := pm.Process.Kill(); err != nil {
            return err
        }
    }
    
    pm.State = ProcessStopped
    pm.Process = nil
    return nil
}
```

### Step 7: Health Monitoring

Implement health checking for managed units:

```go
func (m *HSUMaster) startHealthMonitoring(manager *ProcessManager) {
    ticker := time.NewTicker(manager.Unit.HealthCheck.Interval)
    
    go func() {
        for {
            select {
            case <-ticker.C:
                if err := m.performHealthCheck(manager); err != nil {
                    m.logger.Warnf("Health check failed for %s: %v", 
                        manager.Unit.Name, err)
                    m.handleHealthFailure(manager)
                }
            case <-manager.stopChan:
                ticker.Stop()
                return
            }
        }
    }()
}

func (m *HSUMaster) performHealthCheck(manager *ProcessManager) error {
    config := manager.Unit.HealthCheck
    
    switch config.Type {
    case "http":
        return m.httpHealthCheck(config)
    case "tcp":
        return m.tcpHealthCheck(config)
    case "exec":
        return m.execHealthCheck(config)
    case "process":
        return m.processHealthCheck(manager)
    default:
        return fmt.Errorf("unknown health check type: %s", config.Type)
    }
}
```

## Integration Patterns

### Pattern 1: Worker Pool
Manage multiple instances of the same process:

```go
// Create worker pool
for i := 0; i < workerCount; i++ {
    worker := &ManagedUnit{
        Name: fmt.Sprintf("worker-%d", i),
        ExecutablePath: "./bin/worker",
        Args: []string{
            "--id", fmt.Sprintf("%d", i),
            "--queue", "work-queue",
        },
        Environment: map[string]string{
            "WORKER_ID": fmt.Sprintf("%d", i),
        },
        RestartPolicy: RestartAlways,
    }
    
    m.RegisterManagedUnit(worker)
}
```

### Pattern 2: Service Dependencies
Start services in dependency order:

```go
// Database first
database := &ManagedUnit{
    Name: "database",
    ExecutablePath: "./bin/db-server",
    HealthCheck: HealthCheckConfig{
        Type: "tcp",
        Address: "localhost",
        Port: 5432,
    },
}

// API server depends on database
api := &ManagedUnit{
    Name: "api-server",
    ExecutablePath: "./bin/api",
    Dependencies: []string{"database"},
    HealthCheck: HealthCheckConfig{
        Type: "http",
        URL: "http://localhost:8080/health",
    },
}
```

### Pattern 3: Scheduled Tasks
Run periodic batch jobs:

```go
// Nightly backup
backup := &ManagedUnit{
    Name: "backup-job",
    ExecutablePath: "./bin/backup",
    Args: []string{"--full"},
    Schedule: ScheduleConfig{
        Type: "cron",
        Expression: "0 2 * * *", // 2 AM daily
    },
    RestartPolicy: RestartNever,
}
```

### Pattern 4: Development Environment
Manage development tools and servers:

```go
// Frontend development server
frontend := &ManagedUnit{
    Name: "frontend-dev",
    ExecutablePath: "npm",
    Args: []string{"run", "dev"},
    WorkingDirectory: "./frontend",
    Environment: map[string]string{
        "NODE_ENV": "development",
        "PORT": "3000",
    },
    RestartPolicy: RestartOnFailure,
}

// Backend API server
backend := &ManagedUnit{
    Name: "backend-dev",
    ExecutablePath: "go",
    Args: []string{"run", "main.go"},
    WorkingDirectory: "./backend",
    Environment: map[string]string{
        "ENV": "development",
        "PORT": "8080",
    },
    RestartPolicy: RestartOnFailure,
}
```

## Quick Start Guide

### 1. Simple Worker Process
```go
worker := &ManagedUnit{
    Name: "simple-worker",
    ExecutablePath: "./bin/worker",
    Args: []string{"--config", "worker.conf"},
    RestartPolicy: RestartAlways,
    AutoStart: true,
}
master.RegisterManagedUnit(worker)
```

### 2. Web Server with Health Check
```go
server := &ManagedUnit{
    Name: "web-server",
    ExecutablePath: "./bin/server",
    Args: []string{"--port", "8080"},
    HealthCheck: HealthCheckConfig{
        Type: "http",
        URL: "http://localhost:8080/health",
        Interval: 30 * time.Second,
    },
    RestartPolicy: RestartOnFailure,
}
master.RegisterManagedUnit(server)
```

### 3. Batch Job with Resource Limits
```go
batch := &ManagedUnit{
    Name: "data-processor",
    ExecutablePath: "./bin/processor",
    Args: []string{"--batch-size", "1000"},
    ResourceLimits: ResourceLimits{
        CPU: 2.0,
        Memory: 2 * 1024 * 1024 * 1024, // 2GB
    },
    RestartPolicy: RestartNever,
}
master.RegisterManagedUnit(batch)
```

## Troubleshooting

### Common Issues

**Process fails to start**
```go
// Check executable path and permissions
unit.ExecutablePath = "/usr/local/bin/myapp"
// Verify working directory exists
unit.WorkingDirectory = "/opt/myapp"
```

**Process exits immediately**
```go
// Check command line arguments
unit.Args = []string{"--config", "/etc/myapp/config.yaml"}
// Verify environment variables
unit.Environment["PATH"] = "/usr/local/bin:/usr/bin:/bin"
```

**Health checks failing**
```go
// Increase timeout for slow-starting processes
unit.HealthCheck.Timeout = 30 * time.Second
// Adjust failure threshold
unit.HealthCheck.FailureThreshold = 5
```

### Debug Mode
Enable debug logging for troubleshooting:

```go
unit.DebugMode = true
unit.LogConfig.Level = "debug"
```

## Next Steps

- **[Master Process Guide](../../master/index.md)** - Implement master process with managed unit support
- **[Unmanaged Unit Guide](../unmanaged/index.md)** - Integrate existing processes
- **[Integrated Unit Guide](../integrated/index.md)** - Add deep gRPC integration

---

*You are here: System > Units > **Managed Units***

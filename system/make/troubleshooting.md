# HSU Make System - Troubleshooting

Common issues and solutions for the HSU Make System.

## 🚨 **Common Issues**

### **System Loading Problems**

#### **"include HSU_MAKEFILE_*.mk: No such file or directory"**

**Cause**: System files not deployed or wrong `INCLUDE_PREFIX` configuration.

**Solutions**:
```bash
# 1. Verify system files are copied
ls make/HSU_MAKEFILE_*.mk

# 2. Check INCLUDE_PREFIX in Makefile.config
cat Makefile.config | grep INCLUDE_PREFIX

# 3. Add/update system files if missing
git submodule add https://github.com/Core-Tools/make.git make
git submodule update --init --recursive

# 4. Correct INCLUDE_PREFIX if wrong
# In Makefile.config:
INCLUDE_PREFIX := make/    # Should match where files are located
```

#### **"No rule to make target 'help'"**

**Cause**: HSU system files not properly included.

**Solutions**:
```bash
# 1. Check Makefile content
cat Makefile

# Should contain:
# include make/HSU_MAKEFILE_ROOT.mk

# 2. Verify system files exist
ls -la make/

# 3. Test manual include
make -f make/HSU_MAKEFILE_ROOT.mk help
```

### **Language Detection Issues**

#### **"No rule to make target 'go-build'"**

**Cause**: Go not auto-detected or explicitly disabled.

**Solutions**:
```bash
# 1. Check auto-detection
make info

# Should show:
# ENABLE_GO: yes
# GO_DIR: . (or go/)

# 2. Verify Go files exist
ls go.mod         # For single-language
ls go/go.mod      # For multi-language

# 3. Force enable Go if needed
# In Makefile.config:
ENABLE_GO := yes

# 4. Check Go installation
go version
```

#### **"No rule to make target 'py-build'"**

**Cause**: Python not auto-detected or explicitly disabled.

**Solutions**:
```bash
# 1. Check auto-detection
make info

# Should show:
# ENABLE_PYTHON: yes
# PYTHON_DIR: . (or python/)

# 2. Verify Python files exist
ls pyproject.toml requirements.txt setup.py
ls python/pyproject.toml python/requirements.txt

# 3. Force enable Python if needed
# In Makefile.config:
ENABLE_PYTHON := yes

# 4. Check Python installation
python --version
pip --version
```

### **Build Target Detection Issues**

#### **"No CLI targets found" (Windows)**

**Cause**: Windows-MSYS path detection issues (fixed in v1.1.0).

**Solutions**:
```bash
# 1. Update system files to latest version
git submodule update --remote

# 2. Check detection manually
make info

# 3. Verify CLI structure
ls cmd/cli/*/main.go     # Go
ls cli/*.py              # Python

# 4. Force CLI detection if needed
# In Makefile.config:
CLI_TARGETS := cmd/cli/mycli
```

#### **"No server targets found"**

**Cause**: Server files not in expected locations.

**Solutions**:
```bash
# 1. Check expected locations
ls cmd/srv/*/main.go     # Go servers
ls srv/*.py              # Python servers

# 2. Check auto-detection
make info

# 3. Custom server locations
# In Makefile.config:
SRV_BUILD_DIR := custom/server/path
SRV_TARGETS := custom/server/myserver
```

## 🐍 **Python-Specific Issues**

### **Dependency Installation Problems**

#### **"pip install failed"**

**Solutions**:
```bash
# 1. Check Python environment
python --version
pip --version

# 2. Upgrade pip
python -m pip install --upgrade pip

# 3. Use virtual environment
python -m venv .venv
source .venv/bin/activate  # Linux/macOS
.venv\Scripts\activate     # Windows

# 4. Install dependencies manually
pip install -r requirements.txt
pip install .
```

#### **"pyproject.toml not found"**

**Solutions**:
```bash
# 1. Check if requirements.txt exists instead
ls requirements.txt

# 2. Create minimal pyproject.toml
cat > pyproject.toml << EOF
[build-system]
requires = ["setuptools", "wheel"]
build-backend = "setuptools.build_meta"

[project]
name = "my-project"
version = "0.1.0"
EOF

# 3. Or use requirements.txt approach
# System supports both automatically
```

### **Nuitka Compilation Issues**

#### **"nuitka: command not found"**

**Solutions**:
```bash
# 1. Install Nuitka
pip install nuitka

# 2. Verify installation
nuitka --version

# 3. Check PATH
which nuitka

# 4. Disable Nuitka if not needed
# In Makefile.config:
ENABLE_NUITKA := no
```

#### **"ModuleNotFoundError" during Nuitka build**

**Cause**: Missing dependencies or editable package installation.

**Solutions**:
```bash
# 1. Use non-editable installation (CRITICAL)
pip uninstall my-package
pip install .  # NOT pip install -e .

# 2. Add missing modules to configuration
# In Makefile.config:
NUITKA_EXTRA_MODULES := missing.module.name
NUITKA_EXTRA_PACKAGES := missing_package
NUITKA_EXTRA_FOLLOW_IMPORTS := external_dep

# 3. Check package installation
pip list | grep my-package

# 4. Verify module paths
python -c "import my_package; print(my_package.__file__)"
```

#### **"Nuitka build succeeds but binary fails to run"**

**Cause**: Usually editable package installation or missing dependencies.

**Solutions**:
```bash
# 1. Reinstall as non-editable (MOST COMMON FIX)
pip uninstall my-package
pip install .

# 2. Add missing imports
# In Makefile.config:
NUITKA_EXTRA_FOLLOW_IMPORTS := hsu_core,external_lib

# 3. Check for hidden imports
python -c "import pkgutil; print([name for _, name, _ in pkgutil.iter_modules()])"

# 4. Use standalone mode for debugging
# In Makefile.config:
NUITKA_BUILD_MODE := standalone
```

## 🐹 **Go-Specific Issues**

### **Module and Import Problems**

#### **"go.mod not found"**

**Solutions**:
```bash
# 1. Initialize Go module
go mod init github.com/myorg/myproject

# 2. Check directory structure
ls go.mod        # Single-language
ls go/go.mod     # Multi-language

# 3. Verify auto-detection
make info
```

#### **"Domain import resolution failed"**

**Cause**: Domain import configuration issues.

**Solutions**:
```bash
# 1. Check domain configuration
# In Makefile.config:
PROJECT_DOMAIN := echo
DOMAIN_IMPORT_PREFIX := github.com/core-tools/hsu-$(PROJECT_DOMAIN)
DOMAIN_REPLACE_TARGET := .

# 2. Run domain import diagnostics
make go-lint-diag

# 3. Apply automatic fixes
make go-lint-fix

# 4. Manual go.mod fix
go mod edit -replace github.com/core-tools/hsu-example2=.
```

#### **"Build failed with race detector"**

**Solutions**:
```bash
# 1. Disable race detector temporarily
# In Makefile.config:
GO_BUILD_FLAGS := -v

# 2. Fix race conditions in code
# Use go test -race to identify issues

# 3. Platform-specific race detector issues
# Some platforms don't support -race flag
```

### **Cross-Compilation Issues**

#### **"Cross-compilation failed"**

**Solutions**:
```bash
# 1. Check target platform support
go tool dist list

# 2. Set target explicitly
GOOS=linux GOARCH=amd64 make go-build

# 3. Install cross-compilation tools if needed
# Usually automatic in modern Go versions
```

## 🌐 **Cross-Platform Issues**

### **Windows-Specific Problems**

#### **"bash: make: command not found" (Windows)**

**Solutions**:
```powershell
# 1. Install make for Windows
choco install make

# 2. Or use WSL
wsl make help

# 3. Or use GNU Make for Windows
# Download from: http://gnuwin32.sourceforge.net/packages/make.htm
```

#### **"Permission denied" errors (Windows)**

**Solutions**:
```powershell
# 1. Run as Administrator
# Right-click PowerShell -> Run as Administrator

# 2. Check file permissions
Get-Acl make\HSU_MAKEFILE_*.mk

# 3. Unblock files if downloaded
Unblock-File make\HSU_MAKEFILE_*.mk
```

#### **"MSYS path issues"**

**Cause**: Path separator confusion between Windows and MSYS.

**Solutions**:
```bash
# 1. Update to latest HSU version (includes fixes)
git submodule update --remote

# 2. Check shell detection
make info

# Should show correct SHELL_TYPE

# 3. Force shell type if needed
# In Makefile.config:
SHELL_TYPE := powershell  # or bash
```

### **macOS-Specific Problems**

#### **"xcrun: error: invalid active developer path"**

**Solutions**:
```bash
# 1. Install Xcode command line tools
xcode-select --install

# 2. Reset developer path
sudo xcode-select --reset

# 3. Verify installation
xcode-select -p
```

### **Linux-Specific Problems**

#### **"make: command not found"**

**Solutions**:
```bash
# Ubuntu/Debian
sudo apt-get update
sudo apt-get install build-essential

# CentOS/RHEL
sudo yum groupinstall "Development Tools"

# Arch Linux
sudo pacman -S base-devel
```

## 🔍 **Diagnostic Commands**

### **System Diagnostics**

```bash
# Show complete environment
make info

# Show Go-specific configuration
make go-info

# Show Python-specific configuration
make py-info

# Show available targets
make help
```

### **Build Diagnostics**

```bash
# Verbose build output
make build V=1

# Debug mode
make build DEBUG=1

# Go-specific diagnostics
make go-lint-diag

# Check dependency resolution
make py-install --dry-run
```

### **File System Diagnostics**

```bash
# Check system files
ls -la make/HSU_MAKEFILE_*.mk

# Check configuration
cat Makefile.config

# Check project structure
find . -name "*.go" -o -name "*.py" | head -10

# Check build artifacts
find . -name "*.exe" -o -name "build" -o -name "dist"
```

## 🛠️ **Advanced Troubleshooting**

### **Clean Slate Rebuild**

When everything seems broken, start fresh:

```bash
# 1. Clean all artifacts
make clean

# 2. Remove virtual environments
rm -rf .venv __pycache__ *.egg-info

# 3. Clear module cache
go clean -cache -modcache  # Go
pip cache purge           # Python

# 4. Reinitialize system files
rm -rf make/
git submodule add https://github.com/Core-Tools/make.git make
git submodule update --init --recursive

# 5. Test basic functionality
make help
make info
make setup
```

### **Manual System Testing**

Test system components individually:

```bash
# Test system file loading
make -f make/HSU_MAKEFILE_ROOT.mk help

# Test language detection
make -f make/HSU_MAKEFILE_ROOT.mk info

# Test specific language
make -f make/HSU_MAKEFILE_GO.mk go-info
make -f make/HSU_MAKEFILE_PYTHON.mk py-info
```

### **Configuration Debugging**

Debug configuration issues:

```bash
# Show all make variables
make -p | grep "^[A-Z]"

# Show specific variables
make -f make/HSU_MAKEFILE_ROOT.mk info | grep ENABLE

# Test configuration loading
make -f make/HSU_MAKEFILE_CONFIG.mk help
```

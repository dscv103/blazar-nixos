# Development Shell Guide

This NixOS configuration includes comprehensive development shells with direnv integration for automatic environment switching.

## 🚀 Quick Start

### 1. Enable Direnv (Automatic)

Direnv is automatically configured via home-manager. After rebuilding your system, it will be available in all shells.

### 2. Using Development Shells

#### Option A: Automatic with Direnv (Recommended)

1. Copy the example `.envrc` to your project:
   ```bash
   cp .envrc.example /path/to/your/project/.envrc
   ```

2. Allow direnv to load the environment:
   ```bash
   cd /path/to/your/project
   direnv allow
   ```

3. The development environment will automatically activate when you enter the directory!

#### Option B: Manual with `nix develop`

```bash
# Use the default full-stack devshell
nix develop

# Use the NixOS configuration devshell
nix develop .#nixos
```

## 📦 Available Development Shells

### Default Shell (Full-Stack)

**Access:** `nix develop` or `use flake` in `.envrc`

Includes everything you need for Python and Node.js development:

#### Python 3.13 Ecosystem
- **Python 3.13.6** - Latest Python version
- **uv** (0.8.6) - Extremely fast Python package installer and resolver
- **hatch** (1.14.1) - Modern Python project manager
- **ruff** (0.12.8) - Fast linter, formatter, and import sorter (all-in-one)
- **pyright** (1.1.403) - Type checker for Python
- **pytest** - Testing framework with coverage support
- **bandit** (1.8.6) - Security-oriented static analyzer
- **coverage** (7.10.2) - Code coverage measurement

#### Node.js Ecosystem
- **Node.js 24.7.0** - Latest Node.js version
- **pnpm 10.15.0** - Fast, disk space efficient package manager
- **bun 1.2.21** - Incredibly fast JavaScript runtime and package manager

#### Formatting & Linting
- **treefmt** (2.3.1) - Universal code formatter (configured in `treefmt.toml`)

#### Utilities
- **direnv** - Automatic environment switching
- **nix-direnv** - Fast direnv integration for Nix
- **git** - Version control

### NixOS Shell

**Access:** `nix develop .#nixos`

Minimal shell for NixOS configuration work:
- **nixpkgs-fmt** - Nix code formatter
- **nil** - Nix language server
- **git** - Version control

## 🐍 Python Development Workflow

### Using UV (Recommended)

UV is an extremely fast Python package manager written in Rust:

```bash
# Create a new project
uv init my-project
cd my-project

# Install dependencies
uv add requests pytest ruff

# Run Python
uv run python script.py

# Run tests
uv run pytest

# Sync dependencies
uv sync
```

### Using Hatch

Hatch is a modern Python project manager:

```bash
# Create a new project
hatch new my-project
cd my-project

# Create and enter a virtual environment
hatch shell

# Run tests
hatch run test

# Build package
hatch build
```

### Ruff - All-in-One Python Tool

Ruff combines linting, formatting, and import sorting:

```bash
# Format code
ruff format .

# Lint and auto-fix
ruff check --fix .

# Just check (no fixes)
ruff check .

# Sort imports (included in check)
ruff check --select I --fix .
```

### Type Checking with Pyright

```bash
# Check types in current directory
pyright

# Check specific file
pyright src/main.py

# Watch mode
pyright --watch
```

### Testing with Pytest

```bash
# Run all tests
pytest

# Run with coverage
pytest --cov=src --cov-report=html

# Run specific test
pytest tests/test_example.py::test_function
```

### Security Scanning with Bandit

```bash
# Scan all Python files
bandit -r src/

# Generate report
bandit -r src/ -f json -o bandit-report.json
```

## 📦 Node.js Development Workflow

### Using pnpm

```bash
# Initialize project
pnpm init

# Install dependencies
pnpm add express
pnpm add -D typescript @types/node

# Run scripts
pnpm run dev
pnpm test

# Install all dependencies
pnpm install
```

### Using Bun

```bash
# Initialize project
bun init

# Install dependencies
bun add express
bun add -d typescript

# Run scripts
bun run dev
bun test

# Run file directly
bun run index.ts
```

## 🎨 Code Formatting with Treefmt

Treefmt provides a unified interface for all formatters:

```bash
# Format all files
treefmt

# Check what would be formatted (dry-run)
treefmt --fail-on-change

# Format specific directory
treefmt src/
```

Configuration is in `treefmt.toml`. Currently configured for:
- **Python** - Ruff (format + check)
- **Nix** - nixpkgs-fmt

## 🔧 Direnv Configuration

### Basic `.envrc`

```bash
# Use the default devshell
use flake
```

### Advanced `.envrc`

```bash
# Use the default devshell
use flake

# Add project-specific environment variables
export DATABASE_URL="postgresql://localhost/mydb"
export API_KEY="development-key"
export DEBUG="true"

# Add local bin to PATH
PATH_add ./bin
PATH_add ./node_modules/.bin

# Load .env file if it exists
dotenv_if_exists .env

# Set Python virtual environment (if using venv)
# layout python python3.13
```

### Direnv Commands

```bash
# Allow direnv in current directory
direnv allow

# Reload environment
direnv reload

# Deny direnv in current directory
direnv deny

# Show current environment
direnv status
```

## 📝 Example Project Structures

### Python Project with UV

```
my-python-project/
├── .envrc              # use flake
├── pyproject.toml      # UV/Hatch configuration
├── src/
│   └── my_package/
│       └── __init__.py
├── tests/
│   └── test_example.py
└── README.md
```

### Node.js Project with pnpm

```
my-node-project/
├── .envrc              # use flake
├── package.json
├── pnpm-lock.yaml
├── src/
│   └── index.ts
├── tests/
│   └── example.test.ts
└── README.md
```

### Full-Stack Project

```
my-fullstack-project/
├── .envrc              # use flake
├── treefmt.toml        # Formatting configuration
├── backend/            # Python with UV
│   ├── pyproject.toml
│   └── src/
├── frontend/           # Node.js with pnpm
│   ├── package.json
│   └── src/
└── README.md
```

## 🎯 Best Practices

1. **Always use direnv** - Automatic environment switching prevents version conflicts
2. **Use UV for Python** - It's significantly faster than pip/poetry
3. **Run treefmt before commits** - Keep code consistently formatted
4. **Use ruff for everything** - One tool for linting, formatting, and import sorting
5. **Type check with pyright** - Catch errors before runtime
6. **Test with pytest** - Write tests and measure coverage
7. **Scan with bandit** - Find security issues early

## 🔍 Troubleshooting

### Direnv not loading

```bash
# Check direnv status
direnv status

# Reload direnv
direnv reload

# Re-allow direnv
direnv allow
```

### Python packages not found

```bash
# Make sure you're in the devshell
echo $UV_PYTHON  # Should show path to Python 3.13

# Sync UV dependencies
uv sync
```

### Node.js packages not found

```bash
# Install dependencies
pnpm install
# or
bun install
```

## 📚 Additional Resources

- [UV Documentation](https://github.com/astral-sh/uv)
- [Hatch Documentation](https://hatch.pypa.io/)
- [Ruff Documentation](https://docs.astral.sh/ruff/)
- [Pyright Documentation](https://github.com/microsoft/pyright)
- [Direnv Documentation](https://direnv.net/)
- [Treefmt Documentation](https://github.com/numtide/treefmt)


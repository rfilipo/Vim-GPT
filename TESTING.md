# Vim-GPT Testing Guide

## Overview

This document describes the comprehensive test suite created for the Vim-GPT plugin, designed for continuous integration with Travis CI and GitHub Actions.

## Test Directory Structure

```
t/
├── README.md                    # Test suite documentation
├── run_tests.sh                 # Main test runner with colored output
├── 00-setup.t                   # Basic plugin structure validation (5 tests)
├── 01-python-backend.t          # Python backend functionality (6 tests)
├── 02-vim-syntax.t              # Vim script syntax and commands (8 tests)
├── 03-installation.t            # Installation scripts validation (7 tests)
├── 04-documentation.t           # Documentation completeness (10 tests)
└── 05-sqlite-integration.t      # SQLite logging functionality (6 tests)
```

**Total: 6 test suites with 42 individual test cases**

## CI/CD Configuration

### Travis CI (`.travis.yml`)
- Multi-version Python testing (3.8, 3.9, 3.10, 3.11)
- Ubuntu and macOS testing
- PHP 8.1 integration testing (per user preference)
- Installation script validation
- Email notifications

### GitHub Actions (`.github/workflows/ci.yml`)
- Matrix testing across Python versions
- macOS and Linux testing environments
- Code linting and style checks (flake8, black, isort)
- Shell script checking (shellcheck)
- Package building tests
- Daily scheduled runs (2 AM UTC)

## Running Tests

### Local Testing

```bash
# Run all tests with the main runner
bash t/run_tests.sh

# Or use the Makefile
make test

# Run individual test suites
make test-setup      # Basic structure tests
make test-python     # Python backend tests
make test-vim        # Vim script tests
make test-install    # Installation tests
make test-docs       # Documentation tests
make test-sqlite     # SQLite integration tests

# Quick tests (fastest subset)
make test-quick

# Run with verbose output
make test-verbose
```

### CI Testing

```bash
# Run in CI mode (no colors, TAP output only)
make test-ci
```

## Test Features

### TAP Protocol Support
All tests produce TAP (Test Anything Protocol) output for compatibility with various test harnesses and CI systems.

### Test Coverage Areas

1. **Structure Validation** (`00-setup.t`)
   - Plugin directory structure
   - Required files existence
   - Configuration directories

2. **Python Backend Testing** (`01-python-backend.t`)
   - Syntax validation
   - Module imports
   - Argument parsing
   - Hash functions

3. **Vim Script Testing** (`02-vim-syntax.t`)
   - Vim script syntax validation
   - Command definitions
   - Function definitions

4. **Installation Testing** (`03-installation.t`)
   - Installation script syntax
   - Dependency references
   - Package building scripts

5. **Documentation Testing** (`04-documentation.t`)
   - README completeness
   - Required sections
   - Command documentation

6. **SQLite Integration** (`05-sqlite-integration.t`)
   - Database operations
   - Logging functionality
   - File system operations

### Environment Compatibility

#### System Requirements
- **Linux**: Ubuntu 18.04+, Debian 9+
- **macOS**: 10.15+
- **Python**: 3.8, 3.9, 3.10, 3.11
- **PHP**: 8.1 (for environment compatibility)

#### Dependencies
- **Required**: vim, python3, sqlite3, bash
- **Optional**: openai (Python package), flake8, black, isort

## Development Workflow

### Adding New Tests

1. Create new test file: `t/XX-testname.t`
2. Make executable: `chmod +x t/XX-testname.t`
3. Add to test runner array in `t/run_tests.sh`
4. Update documentation

### Code Quality

```bash
# Run linting tools
make lint

# Run syntax checks
make check

# Set up development environment
make dev-setup
```

### Build and Packaging

```bash
# Build Debian package
make build

# Clean build artifacts
make clean
```

## CI Integration Benefits

1. **Early Bug Detection**: Catches syntax errors and structural issues
2. **Cross-platform Validation**: Tests on multiple OS and Python versions
3. **Documentation Verification**: Ensures README and docs stay current
4. **Installation Validation**: Confirms installation scripts work correctly
5. **Dependency Tracking**: Monitors required packages and modules
6. **PHP 8.1 Compatibility**: Validates environment per user preferences

## Test Performance

- **Quick tests**: ~2-5 seconds (basic structure + vim syntax)
- **Full test suite**: ~15-30 seconds (all 6 suites)
- **CI pipeline**: ~3-5 minutes (including setup and multiple environments)

## Troubleshooting

### Common Issues

1. **Permission errors**: Run `chmod +x t/*.t`
2. **Missing dependencies**: Tests skip optional deps gracefully
3. **Path issues**: Always run from project root directory

### Debug Mode

```bash
set -x  # Enable bash debug mode
bash t/run_tests.sh
```

## Integration with Existing Workflows

The test suite is designed to integrate seamlessly with:

- **Git hooks**: Can be used in pre-commit/pre-push hooks
- **IDE integration**: TAP output works with most editors
- **Custom CI systems**: Standard exit codes and TAP format
- **Docker**: All tests work in containerized environments

## Future Enhancements

Potential areas for test suite expansion:

1. **Performance testing**: Timing analysis for plugin operations  
2. **Memory usage**: Resource consumption monitoring
3. **Integration testing**: Full API integration tests (with mock)
4. **Security testing**: Input validation and sanitization
5. **Compatibility testing**: Extended Vim version matrix

---

*This test suite was created to ensure the Vim-GPT plugin maintains high quality and reliability across different environments and use cases.*

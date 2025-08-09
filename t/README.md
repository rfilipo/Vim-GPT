# Vim-GPT Test Suite

This directory contains the test suite for the Vim-GPT plugin, designed to work with Travis CI and GitHub Actions.

## Test Structure

The test suite follows the TAP (Test Anything Protocol) format and includes:

### Test Files

- **`00-setup.t`** - Basic plugin structure validation
- **`01-python-backend.t`** - Python backend functionality tests  
- **`02-vim-syntax.t`** - Vim script syntax and functionality tests
- **`03-installation.t`** - Installation scripts and packaging tests
- **`04-documentation.t`** - Documentation and README content tests
- **`05-sqlite-integration.t`** - SQLite integration and logging functionality tests

### Test Runner

- **`run_tests.sh`** - Main test runner script with colored output and summary

## Running Tests

### Locally

```bash
# Run all tests
bash t/run_tests.sh

# Run individual test
bash t/00-setup.t
```

### Prerequisites

- Python 3.8+ 
- Vim/Neovim
- SQLite3
- bash

### Optional Dependencies

- OpenAI Python package (for full integration tests)
- PHP 8.1 (for environment compatibility testing)

## CI/CD Integration

### Travis CI

The project includes `.travis.yml` configuration for Travis CI with:

- Multi-version Python testing (3.8, 3.9, 3.10, 3.11)
- Ubuntu and macOS testing
- PHP 8.1 integration testing
- Installation script validation

### GitHub Actions  

The project includes `.github/workflows/ci.yml` with:

- Matrix testing across Python versions
- macOS and Linux testing
- Code linting and style checks
- Package building tests
- Daily scheduled runs

## Test Features

### TAP Output Format

All tests produce TAP (Test Anything Protocol) output for compatibility with various test harnesses:

```
TAP version 13
1..5
ok 1 - Plugin directory exists
ok 2 - Main plugin vim script exists
# Tests run: 5, Passed: 5, Failed: 0
```

### Error Handling

- Tests are designed to be non-destructive
- Temporary files and directories are cleaned up
- Tests continue even if optional dependencies are missing

### Coverage Areas

1. **Structure Validation** - Ensures all required files and directories exist
2. **Syntax Checking** - Validates Vim script and Python code syntax
3. **Functionality Testing** - Tests core plugin functions without requiring API keys
4. **Integration Testing** - Tests SQLite logging and caching functionality
5. **Documentation Testing** - Validates README and documentation completeness
6. **Installation Testing** - Tests installation and packaging scripts

## Adding New Tests

To add a new test file:

1. Create `t/XX-testname.t` (where XX is the next number in sequence)
2. Make it executable: `chmod +x t/XX-testname.t`
3. Follow TAP output format
4. Add to `test_files` array in `run_tests.sh`
5. Update this README

### Test File Template

```bash
#!/usr/bin/env bash
# t/XX-testname.t - Description of test

set -e

# Test framework setup
test_count=0
pass_count=0
fail_count=0

test_description() {
    echo "# $1"
}

ok() {
    test_count=$((test_count + 1))
    if [ $1 -eq 0 ]; then
        echo "ok $test_count - $2"
        pass_count=$((pass_count + 1))
    else
        echo "not ok $test_count - $2"
        fail_count=$((fail_count + 1))
    fi
}

# Start TAP output
echo "TAP version 13"
echo "1..N"  # N = number of tests

test_description "Your test description"

# Your tests here...

# Summary
echo "# Tests run: $test_count, Passed: $pass_count, Failed: $fail_count"
exit $fail_count
```

## Troubleshooting

### Common Issues

1. **Permission Denied**: Run `chmod +x t/*.t` to make test files executable
2. **Missing Dependencies**: Tests are designed to skip optional dependencies gracefully
3. **Path Issues**: Tests should be run from the project root directory

### Debug Mode

To run tests with verbose output:

```bash
set -x  # Enable debug mode
bash t/run_tests.sh
```

## Contributing

When contributing to the test suite:

1. Ensure tests are deterministic and don't depend on external services
2. Clean up any temporary files or directories
3. Use meaningful test descriptions
4. Follow the existing TAP format
5. Test on both Linux and macOS when possible

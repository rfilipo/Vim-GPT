# Vim-GPT Makefile
# Provides convenient commands for testing, building, and development

.PHONY: test test-verbose clean build install help lint check

# Default target
help:
	@echo "Vim-GPT Plugin - Available Make targets:"
	@echo ""
	@echo "  test         - Run all tests"
	@echo "  test-verbose - Run tests with verbose output"
	@echo "  lint         - Run code linting (Python)"
	@echo "  check        - Run syntax checks"
	@echo "  build        - Build Debian package"
	@echo "  install      - Install plugin (requires sudo for system dependencies)"
	@echo "  clean        - Clean build artifacts"
	@echo "  help         - Show this help message"
	@echo ""

# Run test suite
test:
	@echo "Running Vim-GPT test suite..."
	@chmod +x t/*.t t/run_tests.sh
	@bash t/run_tests.sh

# Run tests with verbose output
test-verbose:
	@echo "Running Vim-GPT test suite (verbose)..."
	@chmod +x t/*.t t/run_tests.sh
	@set -x && bash t/run_tests.sh

# Run individual test files
test-setup:
	@chmod +x t/00-setup.t && bash t/00-setup.t

test-python:
	@chmod +x t/01-python-backend.t && bash t/01-python-backend.t

test-vim:
	@chmod +x t/02-vim-syntax.t && bash t/02-vim-syntax.t

test-install:
	@chmod +x t/03-installation.t && bash t/03-installation.t

test-docs:
	@chmod +x t/04-documentation.t && bash t/04-documentation.t

test-sqlite:
	@chmod +x t/05-sqlite-integration.t && bash t/05-sqlite-integration.t

# Linting and code quality
lint:
	@echo "Running Python linting..."
	@if command -v flake8 >/dev/null 2>&1; then \
		flake8 vim-gpt/python/ --count --select=E9,F63,F7,F82 --show-source --statistics || echo "No critical syntax errors"; \
		flake8 vim-gpt/python/ --count --exit-zero --max-complexity=10 --max-line-length=127 --statistics; \
	else \
		echo "flake8 not installed. Install with: pip install flake8"; \
	fi
	@if command -v black >/dev/null 2>&1; then \
		black --check --diff vim-gpt/python/ || echo "Code formatting suggestions available"; \
	else \
		echo "black not installed. Install with: pip install black"; \
	fi

# Syntax checks
check:
	@echo "Running syntax checks..."
	@echo "Checking Python syntax..."
	@python3 -m py_compile vim-gpt/python/gpt_client.py
	@echo "✓ Python syntax OK"
	@echo "Checking Vim script syntax..."
	@vim -e -s -c "source vim-gpt/plugin/gpt.vim" -c "qa!" /dev/null 2>/dev/null
	@echo "✓ Vim script syntax OK"
	@echo "Checking shell script syntax..."
	@bash -n install.sh
	@bash -n build_deb.sh
	@bash -n t/run_tests.sh
	@echo "✓ Shell script syntax OK"

# Build Debian package
build:
	@echo "Building Debian package..."
	@bash build_deb.sh
	@echo "✓ Package built successfully"

# Install plugin
install:
	@echo "Installing Vim-GPT plugin..."
	@echo "Note: This will install system dependencies and may require sudo"
	@bash install.sh

# Clean build artifacts
clean:
	@echo "Cleaning build artifacts..."
	@rm -rf deb_build/
	@rm -f vim-gpt_*.deb
	@rm -f vim-gpt/python/__pycache__/
	@rm -rf vim-gpt/python/*.pyc
	@find . -name "*.pyc" -delete
	@find . -name "__pycache__" -type d -exec rm -rf {} + 2>/dev/null || true
	@echo "✓ Clean completed"

# Development setup
dev-setup:
	@echo "Setting up development environment..."
	@if command -v pip3 >/dev/null 2>&1; then \
		pip3 install --user flake8 black isort pytest; \
		echo "✓ Development tools installed"; \
	else \
		echo "pip3 not found. Please install Python3 and pip first"; \
	fi

# Quick development test (fastest subset)
test-quick:
	@echo "Running quick tests..."
	@chmod +x t/00-setup.t t/02-vim-syntax.t
	@bash t/00-setup.t
	@bash t/02-vim-syntax.t
	@echo "✓ Quick tests completed"

# Run tests in CI mode (no colors, TAP output only)
test-ci:
	@chmod +x t/*.t t/run_tests.sh
	@for test in t/*.t; do \
		echo "Running $$test..."; \
		bash "$$test" || exit 1; \
	done

# Show test statistics
test-stats:
	@echo "Test suite statistics:"
	@echo "  Test files: $$(ls t/*.t | wc -l)"
	@echo "  Total test cases: $$(grep -r "^echo.*ok.*-" t/*.t | wc -l)"
	@echo "  Python files: $$(find vim-gpt -name "*.py" | wc -l)"
	@echo "  Vim script files: $$(find vim-gpt -name "*.vim" | wc -l)"

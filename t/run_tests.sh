#!/usr/bin/env bash
# t/run_tests.sh - Main test runner for Vim-GPT plugin

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

echo -e "${BLUE}=== Vim-GPT Test Suite ===${NC}"
echo ""

# Change to project root directory
cd "$(dirname "$0")/.."

# Counter variables
total_tests=0
total_passed=0
total_failed=0

# Function to run a single test file
run_test() {
    local test_file="$1"
    local test_name=$(basename "$test_file" .t)
    
    echo -e "${YELLOW}Running $test_name...${NC}"
    
    if [ -x "$test_file" ]; then
        if "$test_file"; then
            echo -e "${GREEN}✓ $test_name PASSED${NC}"
            return 0
        else
            echo -e "${RED}✗ $test_name FAILED${NC}"
            return 1
        fi
    else
        echo -e "${RED}✗ $test_name is not executable${NC}"
        return 1
    fi
}

# Make all test files executable
chmod +x t/*.t

# Run all test files in order
test_files=(
    "t/00-setup.t"
    "t/01-python-backend.t"
    "t/02-vim-syntax.t"
    "t/03-installation.t"
    "t/04-documentation.t"
    "t/05-sqlite-integration.t"
)

echo -e "${BLUE}Running ${#test_files[@]} test suites...${NC}"
echo ""

for test_file in "${test_files[@]}"; do
    if [ -f "$test_file" ]; then
        total_tests=$((total_tests + 1))
        if run_test "$test_file"; then
            total_passed=$((total_passed + 1))
        else
            total_failed=$((total_failed + 1))
        fi
        echo ""
    else
        echo -e "${RED}Warning: $test_file not found${NC}"
    fi
done

# Summary
echo -e "${BLUE}=== Test Summary ===${NC}"
echo -e "Total test suites: $total_tests"
echo -e "${GREEN}Passed: $total_passed${NC}"
echo -e "${RED}Failed: $total_failed${NC}"

if [ $total_failed -eq 0 ]; then
    echo -e "${GREEN}All tests passed! 🎉${NC}"
    exit 0
else
    echo -e "${RED}Some tests failed! ❌${NC}"
    exit 1
fi

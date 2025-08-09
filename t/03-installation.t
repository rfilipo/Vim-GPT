#!/usr/bin/env bash
# t/03-installation.t - Test installation scripts and packaging

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
echo "1..7"

test_description "Installation and packaging tests"

# Test 1: Install script exists
test -f "install.sh"
ok $? "Install script exists"

# Test 2: Install script has valid bash syntax
bash -n install.sh 2>/dev/null
ok $? "Install script has valid syntax"

# Test 3: Build deb script exists
test -f "build_deb.sh"
ok $? "Build deb script exists"

# Test 4: Build deb script has valid bash syntax
bash -n build_deb.sh 2>/dev/null
ok $? "Build deb script has valid syntax"

# Test 5: Check for required dependencies in install script
grep -q "pyenv\|python" install.sh
ok $? "Install script references Python"

# Test 6: Check for pyenv installation in install script
grep -q "pyenv" install.sh
ok $? "Install script includes pyenv setup"

# Test 7: Check for API key setup in install script
grep -q "apikey" install.sh
ok $? "Install script handles API key setup"

# Summary
echo "# Tests run: $test_count, Passed: $pass_count, Failed: $fail_count"
exit $fail_count

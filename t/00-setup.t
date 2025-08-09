#!/usr/bin/env bash
# t/00-setup.t - Basic setup tests for Vim-GPT plugin

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
    if [ $? -eq 0 ]; then
        echo "ok $test_count - $1"
        pass_count=$((pass_count + 1))
    else
        echo "not ok $test_count - $1"
        fail_count=$((fail_count + 1))
    fi
}

not_ok() {
    test_count=$((test_count + 1))
    if [ $? -ne 0 ]; then
        echo "ok $test_count - $1"
        pass_count=$((pass_count + 1))
    else
        echo "not ok $test_count - $1"
        fail_count=$((fail_count + 1))
    fi
}

# Start TAP output
echo "TAP version 13"
echo "1..5"

test_description "Basic plugin structure tests"

# Test 1: Plugin directory exists
test -d "vim-gpt"
ok "Plugin directory exists"

# Test 2: Main vim script exists
test -f "vim-gpt/plugin/gpt.vim"
ok "Main plugin vim script exists"

# Test 3: Python backend exists
test -f "vim-gpt/python/gpt_client.py"
ok "Python backend script exists"

# Test 4: Config directory exists
test -d "vim-gpt/config"
ok "Config directory exists"

# Test 5: Doc directory exists
test -d "vim-gpt/doc"
ok "Documentation directory exists"

# Summary
echo "# Tests run: $test_count, Passed: $pass_count, Failed: $fail_count"
exit $fail_count

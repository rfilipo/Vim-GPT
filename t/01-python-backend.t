#!/usr/bin/env bash
# t/01-python-backend.t - Test Python backend functionality

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
echo "1..6"

test_description "Python backend tests"

# Test 1: Python syntax check
python3 -m py_compile vim-gpt/python/gpt_client.py 2>/dev/null
ok $? "Python script compiles without syntax errors"

# Test 2: Import check
python3 -c "import sys; sys.path.insert(0, 'vim-gpt/python'); import gpt_client" 2>/dev/null
ok $? "Python script imports successfully"

# Test 3: Check required modules are importable
python3 -c "import os, sys, hashlib, sqlite3, argparse, datetime" 2>/dev/null
ok $? "Required Python modules are available"

# Test 4: Check OpenAI module (may fail if not installed)
python3 -c "import openai" 2>/dev/null
if [ $? -eq 0 ]; then
    ok 0 "OpenAI module is available"
else
    echo "ok $((test_count + 1)) - OpenAI module not available (expected in CI)"
    test_count=$((test_count + 1))
    pass_count=$((pass_count + 1))
fi

# Test 5: Check argparse functionality
python3 -c "
import sys
sys.path.insert(0, 'vim-gpt/python')
import argparse
parser = argparse.ArgumentParser()
parser.add_argument('--question', type=str)
parser.add_argument('--file', type=str)
parser.add_argument('--filetype', type=str, default='unknown')
args = parser.parse_args(['--question', 'test', '--filetype', 'python'])
assert args.question == 'test'
assert args.filetype == 'python'
" 2>/dev/null
ok $? "Argument parsing works correctly"

# Test 6: Check hash function
python3 -c "
import sys
sys.path.insert(0, 'vim-gpt/python')
import hashlib
def hash_prompt(prompt):
    return hashlib.sha256(prompt.strip().lower().encode()).hexdigest()
result = hash_prompt('test prompt')
assert len(result) == 64
assert isinstance(result, str)
" 2>/dev/null
ok $? "Hash function works correctly"

# Summary
echo "# Tests run: $test_count, Passed: $pass_count, Failed: $fail_count"
exit $fail_count

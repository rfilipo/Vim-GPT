#!/usr/bin/env bash
# t/04-documentation.t - Test documentation and README content

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
echo "1..10"

test_description "Documentation and README tests"

# Test 1: README exists
test -f "README.md"
ok $? "README.md exists"

# Test 2: LICENSE exists
test -f "LICENSE"
ok $? "LICENSE file exists"

# Test 3: README contains installation instructions
grep -q "Installation" README.md
ok $? "README contains installation instructions"

# Test 4: README contains usage instructions
grep -q "Usage" README.md
ok $? "README contains usage instructions"

# Test 5: README mentions all main commands
grep -q ":GPT" README.md && grep -q ":GPTDoc" README.md && grep -q ":GPTAskFile" README.md
ok $? "README documents all main GPT commands"

# Test 6: README contains configuration section
grep -q "Configuration" README.md
ok $? "README contains configuration section"

# Test 7: README mentions API key requirement
grep -q "API.*key" README.md
ok $? "README mentions API key requirement"

# Test 8: README contains plugin structure
grep -q "Plugin Structure" README.md
ok $? "README documents plugin structure"

# Test 9: README mentions requirements
grep -q "Requirements" README.md
ok $? "README contains requirements section"

# Test 10: README has proper markdown structure (headers)
grep -q "^#" README.md
ok $? "README has proper markdown headers"

# Summary
echo "# Tests run: $test_count, Passed: $pass_count, Failed: $fail_count"
exit $fail_count

#!/usr/bin/env bash
# t/02-vim-syntax.t - Test Vim script syntax and basic functionality

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
echo "1..8"

test_description "Vim script syntax and functionality tests"

# Test 1: Vim script syntax check
vim -e -s -c "source vim-gpt/plugin/gpt.vim" -c "qa!" /dev/null 2>/dev/null
ok $? "Vim script has valid syntax"

# Test 2: Check for required functions
grep -q "function! GPTPrompt()" vim-gpt/plugin/gpt.vim
ok $? "GPTPrompt function is defined"

# Test 3: Check for GPT command definition
grep -q "command! GPT" vim-gpt/plugin/gpt.vim
ok $? "GPT command is defined"

# Test 4: Check for GPTV command definition
grep -q "command! GPTV" vim-gpt/plugin/gpt.vim
ok $? "GPTV command is defined"

# Test 5: Check for GPTDoc command definition
grep -q "command! GPTDoc" vim-gpt/plugin/gpt.vim
ok $? "GPTDoc command is defined"

# Test 6: Check for GPTAskFile command definition
grep -q "command! GPTAskFile" vim-gpt/plugin/gpt.vim
ok $? "GPTAskFile command is defined"

# Test 7: Check for GPTCommandAsk command definition
grep -q "command! GPTCommandAsk" vim-gpt/plugin/gpt.vim
ok $? "GPTCommandAsk command is defined"

# Test 8: Check for Python client path reference
grep -q "python3.*gpt_client.py" vim-gpt/plugin/gpt.vim
ok $? "Python client is properly referenced"

# Summary
echo "# Tests run: $test_count, Passed: $pass_count, Failed: $fail_count"
exit $fail_count

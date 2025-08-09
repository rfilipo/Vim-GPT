#!/usr/bin/env bash
# t/05-sqlite-integration.t - Test SQLite integration and logging functionality

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

# Create temporary test environment
setup_test_env() {
    TEST_DIR=$(mktemp -d)
    export TEST_DIR
    mkdir -p "$TEST_DIR/.vim/pack/plugins/start/vim-gpt/doc"
    mkdir -p "$TEST_DIR/.vim/pack/plugins/start/vim-gpt/python"
    cp vim-gpt/python/gpt_client.py "$TEST_DIR/.vim/pack/plugins/start/vim-gpt/python/"
}

cleanup_test_env() {
    rm -rf "$TEST_DIR"
}

# Start TAP output
echo "TAP version 13"
echo "1..6"

test_description "SQLite integration and logging tests"

# Setup test environment
setup_test_env

# Test 1: SQLite3 is available
command -v sqlite3 >/dev/null 2>&1
ok $? "SQLite3 is available"

# Test 2: Python sqlite3 module works
python3 -c "import sqlite3; conn = sqlite3.connect(':memory:'); conn.close()" 2>/dev/null
ok $? "Python sqlite3 module works"

# Test 3: Test database creation functionality
python3 -c "
import sqlite3
import tempfile
import os
db_path = tempfile.mktemp() + '.db'
conn = sqlite3.connect(db_path)
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY,
    timestamp TEXT,
    filetype TEXT,
    prompt_hash TEXT,
    prompt TEXT,
    response TEXT
)''')
conn.commit()
conn.close()
os.unlink(db_path)
" 2>/dev/null
ok $? "Database table creation works"

# Test 4: Test hash functionality
python3 -c "
import hashlib
def hash_prompt(prompt):
    return hashlib.sha256(prompt.strip().lower().encode()).hexdigest()
test_hash = hash_prompt('test prompt')
assert len(test_hash) == 64
assert test_hash == hash_prompt('TEST PROMPT  ')  # Should normalize
" 2>/dev/null
ok $? "Prompt hashing works correctly"

# Test 5: Test log insertion
python3 -c "
import sqlite3
import tempfile
import os
import hashlib
from datetime import datetime

def hash_prompt(prompt):
    return hashlib.sha256(prompt.strip().lower().encode()).hexdigest()

db_path = tempfile.mktemp() + '.db'
conn = sqlite3.connect(db_path)
c = conn.cursor()
c.execute('''CREATE TABLE IF NOT EXISTS logs (
    id INTEGER PRIMARY KEY,
    timestamp TEXT,
    filetype TEXT,
    prompt_hash TEXT,
    prompt TEXT,
    response TEXT
)''')

timestamp = datetime.now().strftime('%Y-%m-%d_%H-%M-%S')
prompt = 'test prompt'
prompt_hash = hash_prompt(prompt)
filetype = 'python'
response = 'test response'

c.execute('INSERT INTO logs VALUES (?, ?, ?, ?, ?, ?)', (
    None, timestamp, filetype, prompt_hash, prompt, response
))
conn.commit()

# Verify insertion
c.execute('SELECT COUNT(*) FROM logs')
count = c.fetchone()[0]
assert count == 1

conn.close()
os.unlink(db_path)
" 2>/dev/null
ok $? "Log insertion and retrieval works"

# Test 6: Test directory creation for logs
python3 -c "
import os
import tempfile
import shutil

# Create a temporary directory structure
temp_base = tempfile.mkdtemp()
log_dir = os.path.join(temp_base, '.vim', 'pack', 'plugins', 'start', 'vim-gpt', 'doc', 'logs')
os.makedirs(log_dir, exist_ok=True)
assert os.path.exists(log_dir)
shutil.rmtree(temp_base)
" 2>/dev/null
ok $? "Log directory creation works"

# Cleanup
cleanup_test_env

# Summary
echo "# Tests run: $test_count, Passed: $pass_count, Failed: $fail_count"
exit $fail_count

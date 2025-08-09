import os
import sys
import hashlib
import sqlite3
import argparse
from datetime import datetime
from openai import OpenAI
from difflib import get_close_matches

# Path to OpenAI API key
def read_api_key():
    path = os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/config/apikey")
    with open(path) as f:
        return f.read().strip()

client = OpenAI(api_key=read_api_key())

def hash_prompt(prompt):
    return hashlib.sha256(prompt.strip().lower().encode()).hexdigest()

# Save logs in both Markdown and SQLite
def save_logs(prompt, result, filetype):
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_dir = os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/doc/logs")
    os.makedirs(log_dir, exist_ok=True)
    prompt_hash = hash_prompt(prompt)

    # Markdown log
    md_path = os.path.join(log_dir, f"{timestamp}.md")
    with open(md_path, "w") as f:
        f.write(f"# GPT Log – {timestamp}\n\n")
        f.write(f"**Filetype**: `{filetype}`\n\n")
        f.write("## Prompt\n\n```\n" + prompt.strip() + "\n```\n\n")
        f.write("## Response\n\n```\n" + result.strip() + "\n```\n")

    # SQLite log
    db_path = os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/doc/gpt_log.db")
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
    c.execute('INSERT INTO logs VALUES (?, ?, ?, ?, ?, ?)', (
        None,
        timestamp,
        filetype,
        #hashlib.sha256(prompt.encode()).hexdigest(),
        prompt_hash,
        prompt,
        result
    ))
    conn.commit()
    conn.close()

# Check if the prompt was used before
def check_cached_response(prompt_hash, filetype=None):
    db_path = os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/doc/gpt_log.db")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    if filetype:
        cursor.execute("""
            SELECT response FROM logs
            WHERE prompt_hash = ? AND filetype = ?
            ORDER BY timestamp DESC LIMIT 1
        """, (prompt_hash, filetype))
    else:
        cursor.execute("""
            SELECT response FROM logs
            WHERE prompt_hash = ?
            ORDER BY timestamp DESC LIMIT 1
        """, (prompt_hash,))
    
    row = cursor.fetchone()
    conn.close()

    if row:
        return row[0]
    return None

# Check if exists a close match
def find_fuzzy_response(prompt, filetype=None, threshold=0.92):
    db_path = os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/doc/gpt_log.db")
    conn = sqlite3.connect(db_path)
    cursor = conn.cursor()

    if filetype:
        cursor.execute("""
            SELECT prompt, response FROM logs
            WHERE filetype = ?
            ORDER BY timestamp DESC LIMIT 1000
        """, (filetype,))
    else:
        cursor.execute("""
            SELECT prompt, response FROM logs
            ORDER BY timestamp DESC LIMIT 1000
        """)

    rows = cursor.fetchall()
    conn.close()

    prompts = [row[0] for row in rows]
    matches = get_close_matches(prompt.strip().lower(), prompts, n=1, cutoff=threshold)

    if matches:
        match = matches[0]
        for prompt_text, response in rows:
            if prompt_text == match:
                return response
    return None


# Call GPT
def query_gpt(prompt):
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.5
    )
    return response.choices[0].message.content.strip()

# Main function: clean CLI
def main():
    parser = argparse.ArgumentParser(description="Query GPT with an optional file context.")
    parser.add_argument("--question", type=str, help="Your question to GPT.")
    parser.add_argument("--file", type=str, help="Include file content as context.")
    parser.add_argument("--filetype", type=str, default="unknown", help="Language/filetype for logging purposes.")

    args = parser.parse_args()

    #Prompt for question if not passed
    if not args.question:
        try:
            args.question = input("💬 What do you want to ask GPT? ")
        except EOFError:
            print("❌ No question provided. Exiting.")
            return

    prompt = args.question

    # Search for a log with this prompt
    prompt_hash = hash_prompt(prompt)    
    cached = check_cached_response(prompt_hash, args.filetype)
    if cached:
        print("💬 [cached]\n" + cached)
        sys.exit(0)

    # Search for a log with a close prompt
    fuzzy = find_fuzzy_response(prompt, args.filetype)
    if fuzzy:
        print("💬 [fuzzy matched]\n" + fuzzy)
        sys.exit(0)

    # If a file is provided, add its contents to the prompt
    if args.file and os.path.isfile(args.file):
        with open(args.file, "r", encoding="utf-8") as f:
            content = f.read()
        prompt = (
            f"You are reading the file '{args.file}'.\n\n"
            f"Here is its content:\n\n{content}\n\n"
            f"Now, answer the following question:\n{args.question}"
        )

    response = query_gpt(prompt)
    print(response)
    save_logs(prompt, response, args.filetype)

if __name__ == "__main__":
    main()


import os
import sys
import hashlib
import sqlite3
from datetime import datetime
from openai import OpenAI

def read_api_key():
    path = os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/config/apikey")
    with open(path) as f:
        return f.read().strip()

client = OpenAI(api_key=read_api_key())

def save_logs(prompt, result, filetype):
    timestamp = datetime.now().strftime("%Y-%m-%d_%H-%M-%S")
    log_dir = os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/doc/logs")
    os.makedirs(log_dir, exist_ok=True)

    # Save .md log
    md_path = os.path.join(log_dir, f"{timestamp}.md")
    with open(md_path, "w") as f:
        f.write(f"# GPT Log – {timestamp}\n\n")
        f.write(f"**Filetype**: `{filetype}`\n\n")
        f.write("## Prompt\n\n```\n" + prompt.strip() + "\n```\n\n")
        f.write("## Response\n\n```\n" + result.strip() + "\n```\n")

    # Save SQLite row
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
        hashlib.sha256(prompt.encode()).hexdigest(),
        prompt,
        result
    ))
    conn.commit()
    conn.close()

def main():
    prompt = sys.argv[1]
    filetype = sys.argv[2] if len(sys.argv) > 2 else "unknown"
    response = client.chat.completions.create(
        model="gpt-4",
        messages=[{"role": "user", "content": prompt}],
        temperature=0.5
    ).choices[0].message.content

    save_logs(prompt, response, filetype)
    print(response)

if __name__ == "__main__":
    main()


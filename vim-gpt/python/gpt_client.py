import sys
import os
from openai import OpenAI

def read_api_key():
    with open(os.path.expanduser("~/.vim/pack/plugins/start/vim-gpt/config/apikey")) as f:
        return f.read().strip()

def call_gpt(prompt):
    client = OpenAI(api_key=read_api_key())

    chat_completion = client.chat.completions.create(
        model="gpt-4",
        #model="gpt-3.5-turbo",
        messages=[
            {"role": "user", "content": prompt}
        ],
        temperature=0.7,
    )

    return chat_completion.choices[0].message.content

def more_one

if __name__ == "__main__":
    prompt = sys.argv[1]
    print(call_gpt(prompt))


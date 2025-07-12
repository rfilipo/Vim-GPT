function! GPTPrompt()
  let l:question = input('Ask GPT: ')
  if empty(l:question)
    echo "No question asked."
    return
  endif

  " Call Python script with shell command
  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:question) . '"'
  let l:result = system(l:cmd)

  " Show result in a new buffer
  new
  setlocal buftype=nofile
  call setline(1, split(l:result, "\n"))
endfunction

function! GPTVisual()
  " Save the current visual selection to a variable
  let l:old_reg = getreg('"')
  normal! gv"xy
  let l:question = getreg('x')
  call setreg('"', l:old_reg)

  if empty(l:question)
    echo "No text selected."
    return
  endif

  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:question) . '"'
  let l:result = system(l:cmd)

  " Show result in a new split
  belowright new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(l:result, "\n"))
endfunction

function! GPTDoc()
  " Get start and end line of last selection (works with mouse)
  let l:start_line = getpos("'<")[1]
  let l:end_line   = getpos("'>")[1]

  if l:end_line < l:start_line
    let l:tmp = l:end_line
    let l:end_line = l:start_line
    let l:start_line = l:tmp
  endif

  let l:lines = getline(l:start_line, l:end_line)
  let l:code = join(l:lines, "\n")

  if empty(l:code)
    echo "No code selected."
    return
  endif

  " Detect filetype
  let l:filetype = &filetype

  " Comment style hints
  let l:comment_styles = {
  \ 'php':     '/** DOC */',
  \ 'javascript': '/** DOC */',
  \ 'typescript': '/** DOC */',
  \ 'c':       '/* DOC */',
  \ 'cpp':     '/* DOC */',
  \ 'java':    '/** DOC */',
  \ 'python':  '""" DOC """',
  \ 'perl':    '# DOC',
  \ 'ruby':    '# DOC',
  \ 'sh':      '# DOC',
  \ 'bash':    '# DOC',
  \ 'html':    '<!-- DOC -->',
  \ 'css':     '/* DOC */',
  \ 'go':      '// DOC',
  \ 'rust':    '/// DOC',
  \ 'lua':     '-- DOC',
  \ 'default': '// DOC'
  \ }

  let l:style = get(l:comment_styles, l:filetype, l:comment_styles['default'])

  " Prompt: absolutely forbid GPT from repeating the code
  let l:prompt = "You are an expert developer.\n"
        \ . "Generate concise documentation for the following " . l:filetype . " code.\n"
        \ . "Format the documentation using " . l:style . ".\n"
        \ . "DO NOT include the code itself. ONLY return the documentation.\n\n"
        \ . l:code

  echo "💬 GPT is documenting " . l:filetype . " code..."

  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:prompt) . '" ' . shellescape(l:filetype)
  " let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:prompt) . '"'

  " Execute GPT
  try
    let l:doc = system(l:cmd)
    if v:shell_error != 0 || l:doc =~? 'Traceback\|Error'
      echohl ErrorMsg
      echom "⚠️ GPT Error: ".l:doc
      echohl None
      return
    endif
  catch /.*/
    echohl ErrorMsg
    echom "💥 Unexpected error: ".v:exception
    echohl None
    return
  endtry

  " Clean result
  let l:doc_lines = split(l:doc, '\n')
  if len(l:doc_lines) > 0 && empty(l:doc_lines[-1])
    call remove(l:doc_lines, -1)
  endif

  " Match indentation of selected code
  let l:indent = matchstr(getline(l:start_line), '^\s*')
  let l:doc_lines = map(l:doc_lines, {_, val -> l:indent . val})

  " Insert documentation ABOVE the selected code
  call append(l:start_line - 1, l:doc_lines)

  echo "✅ Documentation inserted above selected " . l:filetype . " code."
endfunction

function! GPTComplete(...) range
  " Detect filetype
  let l:filetype = &filetype

  " Use argument if provided, else use visual selection
  if a:0 > 0
    let l:prompt = a:1
  else
    let l:start_line = getpos("'<")[1]
    let l:end_line = getpos("'>")[1]
    let l:lines = getline(l:start_line, l:end_line)
    let l:prompt = join(l:lines, "\n")
    if empty(l:prompt)
      echo "No input or selection provided."
      return
    endif
  endif

  " Form full prompt for code completion
  let l:full_prompt = "Continue or complete this " . l:filetype . " code intelligently:\n\n" . l:prompt

  echo "💬 GPT is completing code..."

  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:full_prompt) . '"'

  " Execute
  try
    let l:response = system(l:cmd)
    if v:shell_error != 0 || l:response =~? 'Traceback\|Error'
      echohl ErrorMsg
      echom "⚠️ GPT Error: ".l:response
      echohl None
      return
    endif
  catch /.*/
    echohl ErrorMsg
    echom "💥 Unexpected error: ".v:exception
    echohl None
    return
  endtry

  " Insert response below selection or current line
  if a:0 == 0
    call append(l:end_line, split(l:response, '\n'))
  else
    let l:line = line(".")
    call append(l:line, split(l:response, '\n'))
  endif

  echo "✅ GPT code completion inserted."
endfunction

function! GPTInlineComplete()
  let l:line = getline(".")
  let l:filetype = &filetype

  if empty(l:line)
    echo "⚠️ No code to complete."
    return
  endif

  let l:prompt = "Complete the following " . l:filetype . " code:\n\n" . l:line
  echo "💬 GPT is generating inline completion..."

  " let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:prompt) . '"'
  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:prompt) . '" ' . shellescape(l:filetype)


  try
    let l:response = system(l:cmd)
    if v:shell_error != 0 || l:response =~? 'Traceback\|Error'
      echohl ErrorMsg
      echom "⚠️ GPT Error: ".l:response
      echohl None
      return
    endif
  catch /.*/
    echohl ErrorMsg
    echom "💥 Unexpected error: ".v:exception
    echohl None
    return
  endtry

  let l:lines = split(l:response, '\n')
  let l:current = line(".")
  call append(l:current, l:lines)

  " Delay slightly and return to insert mode
  call timer_start(500, { -> feedkeys('a', 'n') })

  echo "✅ Inline GPT completion inserted."
endfunction

map <Nul> <c-space>
map! <Nul> <c-space>
inoremap <c-space> <c-n>

inoremap <C-Space> <Esc>:call GPTInlineComplete()<CR>

command! -nargs=? -range GPTComplete call GPTComplete(<f-args>)
command! GPT call GPTPrompt()
command! GPTV call GPTVisual()
command! GPTDoc call GPTDoc()


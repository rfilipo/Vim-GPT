" Vim-GPT: plugin/gpt.vim

map <Nul> <c-space>
map! <Nul> <c-space>
inoremap <c-space> <c-n>

inoremap <C-Space> <Esc>:call GPTInlineComplete()<CR>

command! -nargs=? -range GPTComplete call GPTComplete(<f-args>)
command! GPT call GPTPrompt()
command! GPTV call GPTVisual()
command! GPTDoc call GPTDoc()
command! GPTAskFile call GPTAskFile()
command! GPTCommandAsk call GPTCommandAsk()

function! GPTCheckCommandExecution(result, orig_win)
  echo "💬 Vim-GPT is analyzing the result..."

  let l:lines = split(a:result, "\n")
  let l:vimcmd = ''
  let l:shellcmd = ''

  " Step 1: Look for backtick-enclosed Vim or shell commands
  for line in l:lines
    " Match `:set number`
    let l:vim_match = matchstr(line, '`:\zs[^`]*\ze`')
    if !empty(l:vim_match)
      let l:vimcmd = l:vim_match
      break
    endif

    " Match `!ls -l`
    let l:shell_match = matchstr(line, '`!\zs[^`]*\ze`')
    if !empty(l:shell_match)
      let l:shellcmd = l:shell_match
      break
    endif
  endfor

  " Step 2: If not found, look for raw Vim command like :wq
  if empty(l:vimcmd)
    for line in l:lines
      let l:raw_vim_match = matchstr(line, ':\zs\w\+\s\+\S\+')
      if !empty(l:raw_vim_match)
        let l:vimcmd = l:raw_vim_match
        break
      endif
    endfor
  endif

  " Step 3: Run Vim command
  if !empty(l:vimcmd)
    echo "💬 Found Vim command: :" . l:vimcmd
    let l:confirm = confirm("Execute Vim command: :" . l:vimcmd . " ?", "&Yes\n&No", 2)
    if l:confirm == 1
      execute a:orig_win . 'wincmd w'
      execute ':' . l:vimcmd
    endif
    return
  endif

  " Step 4: Run shell command
  if !empty(l:shellcmd)
    echo "💬 Found shell command: !" . l:shellcmd
    let l:confirm = confirm("Execute shell command: !" . l:shellcmd . " ?", "&Yes\n&No", 2)
    if l:confirm == 1
      execute a:orig_win . 'wincmd w'
      call system(l:shellcmd)
    endif
    return
  endif

  echo "💬 No command found..."
endfunction


function! GPTPrompt()
  let l:question = input('Ask GPT: ')
  if empty(l:question)
    echo "No question asked."
    return
  endif
  echo "\n💬 Vim-GPT is thinking..."

  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py --question "' . shellescape(l:question) . '"'
  let l:result = system(l:cmd)

  "new
  "setlocal buftype=nofile
  "call setline(1, split(l:result, "\n"))


  " Display result
 " new
 " setlocal buftype=nofile
 " call setline(1, split(l:result, "\n"))
  
  " Extract first line and check for Vim or shell command
  " let l:firstline = getline(1)
  " if l:firstline =~ '^:'
  "   let l:confirm = confirm("Execute suggested Vim command: " . l:firstline . " ?", "&Yes\n&No", 2)
  "   if l:confirm == 1
  "     execute l:firstline
  "   endif
  " elseif l:firstline =~ '^!'
  "   let l:shellcmd = substitute(l:firstline, '^!', '', '')
  "   let l:confirm = confirm("Execute shell command: " . l:shellcmd . " ?", "&Yes\n&No", 2)
  "   if l:confirm == 1
  "     call system(l:shellcmd)
  "   endif
  " endif
  "
  " Save current window and show result in a new buffer
  let l:orig_win = winnr()
  belowright new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(l:result, "\n"))

  " Analyze GPT response for command execution
  call GPTCheckCommandExecution(l:result, l:orig_win)
endfunction

function! GPTVisual()
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

  belowright new
  setlocal buftype=nofile bufhidden=wipe noswapfile
  call setline(1, split(l:result, "\n"))
endfunction

function! GPTDoc()
  echo "\n💬 Vim-GPT is thinking..."
  let l:old_reg = getreg('"')
  normal! gv"xy
  let l:code = getreg('x')
  call setreg('"', l:old_reg)

  if empty(l:code)
    echo "No code selected."
    return
  endif

  let l:filetype = &filetype
  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py --question "Write documentation for the following ' . l:filetype . ' code:" --filetype ' . l:filetype
  let l:inputfile = tempname()
  call writefile(split(l:code, "\n"), l:inputfile)
  let l:cmd .= ' --file ' . l:inputfile

  let l:result = system(l:cmd)
  call delete(l:inputfile)

  execute "normal! O" . substitute(l:result, '\n', "\r", 'g')
endfunction

function! GPTAskFile()
  let l:files = split(globpath(getcwd(), '*'), "\n")
  if empty(l:files)
    echo "No files found in current directory."
    return
  endif

  let l:choices = map(copy(l:files), 'fnamemodify(v:val, ":t")')
  let l:idx = inputlist(['Choose a file:'] + l:choices)

  if l:idx <= 0 || l:idx > len(l:files)
    echo "Cancelled."
    return
  endif

  " let l:filename = l:files[l:idx - 1]
  let l:file = l:files[l:idx - 1]



  " let l:file = input('File to ask GPT about: ')
  if empty(l:file) || !filereadable(l:file)
    echo "File not found."
    return
  endif

  let l:question = input('Question about the file: ')
  if empty(l:question)
    echo "No question asked."
    return
  endif
  echo "\n💬 Vim-GPT is thinking..."

  let l:filetype = &filetype
  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py --question "' . shellescape(l:question) . '" --file ' . shellescape(l:file) . ' --filetype ' . l:filetype
  let l:result = system(l:cmd)

  new
  setlocal buftype=nofile
  call setline(1, split(l:result, "\n"))
endfunction

function! GPTInlineComplete()
  let l:line = getline(".")
  let l:filetype = &filetype

  if empty(l:line)
    echo "⚠️ No code to complete."
    return
  endif
  echo "\n💬 Vim-GPT is thinking..."

  let l:prompt = "Complete the following " . l:filetype . " code:\n\n" . l:line
  echo "💬 GPT is generating inline completion..."

  " let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py "' . shellescape(l:prompt) . '"'
  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py --question ' . shellescape(l:prompt)

  echo "💬 Command: " . l:cmd

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

function! GPTCommandAsk()
  let l:cmd_input = input('System command to run: ')
  if empty(l:cmd_input)
    echo "No command entered."
    return
  endif

  let l:question = input('What do you want to ask about the output? ')
  if empty(l:question)
    echo "No question asked."
    return
  endif
  echo "\n💬 Vim-GPT is thinking..."

  let l:tempfile = tempname()
  call writefile(split(system(l:cmd_input), "\n"), l:tempfile)

  let l:filetype = &filetype
  let l:cmd = 'python3 ~/.vim/pack/plugins/start/vim-gpt/python/gpt_client.py --question "' . shellescape(l:question) . '" --file ' . l:tempfile . ' --filetype ' . l:filetype
  let l:result = system(l:cmd)

  call delete(l:tempfile)

  new
  setlocal buftype=nofile
  call setline(1, split(l:result, "\n"))
endfunction


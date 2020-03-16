"
"                                _   -.--.
"         ,---. --,          --/ /| /    ',----.
"        /__./,-.'|  __  ,-,-. :/  :  /`. \  /  \
"     ,-.;  ; | |,  , ,'/ /: : ' / |  |--`| :    |                    .-.--.
"    /_/ \  | `-'_  ' | |' | '  / ::  ;_  | | .\ : --.     -.    --. / /    '
"    \ ;  \ ' ,','| | |   ,' |  | \ \    `. : |: |/   \   /  \  /   \    /`./
"     \ \  \: ' | | ' :  / | |   \ \ \-.  | |  \ .- -. | / / ' /  /      ;_
"      ; \  ' | | : | | '  ' : |. \_ \  \ | : .  |\\ . .. ' / .  ' / \ \    `.
"       \ \   ' : |_; : |  | | ' \ |/`--' :   |`-',..; |'  :__' ;   / `---.   \
"        \ `  | | '.| , ;  ' : |--/'.     : : :  /  .  |'  '.'' |  / / /`--'  /
"         : \ ; :  |`--'   ; |,'   --'---'| | : ;   '   |     | :    --.     /
"          '-"| ,  |       '-'            `-'.| |    .-./\\  / \ \  / `-'---'
"              --`-'                       `--`  `--'     `-'   ---'
"
"
let s:virk_settings_dir = ""
let s:virk_moved        = ""
let s:virk_dirname      = ""
let s:virk_errors       = []

" ------------- Sourcing functions -------------

function! virkspaces#source_virk_settings()
  if ! g:virk_enable | return | endif
  let l:fn = s:virk_settings_dir . "/" . g:virk_settings_filename
  if filereadable(l:fn) && buflisted(bufnr("%"))
    silent exec "source " . l:fn
  endif
endfunction

function! virkspaces#source_session()
  let l:fn = s:virk_settings_dir . "/" . g:virk_session_filename
  if filereadable(l:fn)
    silent exe "source " . l:fn
  endif
endfunction

function! virkspaces#source_vonce()
  let l:fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if filereadable(l:fn)
    silent exec "source " . l:fn
  endif
endfunction

" ------------- Directory functions -------------

function! s:findVirkDirRecursive(dirname) abort
  if strpart(a:dirname, 0, stridx(a:dirname, "://")) != ""
        \ || a:dirname == $HOME
    return "NONE"
  endif
  if g:virk_ignore_enable && filereadable(a:dirname . "/" . g:virk_ignore_filename)
    return "IGNORE"
  endif
  for l:vdn in g:virk_dirnames
    let l:settingsDir = a:dirname . "/" . l:vdn
    if isdirectory(l:settingsDir)
      let g:virk_root_dir = a:dirname
      let s:virk_dirname = l:vdn
      return l:settingsDir
    endif
  endfor
  let l:parentDir = strpart(a:dirname, 0, strridx(a:dirname, "/"))
  if isdirectory(l:parentDir)
    return s:findVirkDirRecursive(l:parentDir)
  endif
endfunction

function! virkspaces#find_virk_dir() abort
  let l:curDir = getcwd()
  let s:virk_settings_dir = s:findVirkDirRecursive(l:curDir)
endfunction

" ------------- Deletion functions -------------

function! virkspaces#clean_virkspace() abort
  if s:virk_settings_dir == "IGNORE"
    return
  endif
  let l:delall = s:yesno("Delete all in " . s:virk_settings_dir . "?")
  for l:fn in [
        \   g:virk_settings_filename,
        \   g:virk_session_filename,
        \   g:virk_vonce_filename,
        \   g:virk_tags_filename,
        \ ]
    let l:fn = s:virk_settings_dir . "/" . l:fn
    if filereadable(l:fn)
      if l:delall
        call delete(l:fn)
      else
        if s:yesno("Delete " . l:fn . "?")
          call delete(l:fn)
        endif
      endif
    endif
  endfor
endfunction

" ------------- Creation functions -------------

function! virkspaces#create_virkspace() abort
  let l:projDir = input("Dir: ", expand("%:p:h"))
  if ! isdirectory(l:projDir)
    if ! s:yesno("\"" . l:projDir . "\" is not a directory, make dirs?")
      return
    endif
  endif
  if isdirectory(l:projDir . "/" . g:virk_dirnames[0])
    if ! s:yesno("\"" . l:projDir . "/" . g:virk_dirnames[0] . "\" exists, overwrite?")
      return
    else
      if delete(fnameescape(l:projDir . "/" . g:virk_dirnames[0]))
        echom "[VirkSpaces] \"" . l:projDir . "/" . g:virk_dirnames[0] . " could not be deleted, exiting..."
        return
      endif
    endif
  endif
  call mkdir(l:projDir . "/" . g:virk_dirnames[0])
  echom "[VirkSpaces] Project directory created"
  if g:virk_cd_on_create == 0
    if s:yesno("CD to project directory parent?")
      return
    endif
  endif
  call virkspaces#load_virkspace()
  call <SID>virk_error_report()
endfunction

" https://github.com/neoclide/coc.nvim/pull/1110/commits/3bf6e19ea
function! virkspaces#coc_create()
  let currentDir = getcwd()
  let fsRootDir = fnamemodify($HOME, ":p:h:h:h")

  if currentDir == $HOME
    echom "Can't resolve local config from current working directory."
    return
  endif

  while isdirectory(currentDir) && !(currentDir ==# $HOME) && !(currentDir ==# fsRootDir)
    if isdirectory(currentDir . "/" . s:virk_dirname)
      execute "edit " . currentDir . "/" . s:virk_dirname . "/coc-settings.json"
      return
    endif
    let currentDir = fnamemodify(currentDir, ":p:h:h")
  endwhile

  if coc#util#prompt_confirm("No local config detected, would you like to create "
        \ . s:virk_dirname . "/coc-settings.json?")
    call mkdir(s:virk_dirname, "p")
    execute "edit "s:virk_dirname."/coc-settings.json"
  endif
endfunction

function! virkspaces#make_tags_file()
  let l:fn = s:virk_settings_dir . "/" . g:virk_tags_filename
  let l:exc = ""
  if len(g:virk_tags_excludes) > 0
    let l:exc = join(" --exclude ", g:virk_tags_excludes)
  endif
  exec "set tags=" . l:fn
  silent exec "!" . g:virk_tags_bin . " " . g:virk_tags_flags . " " . l:fn . " " . l:exc . " " . g:virk_root_dir
endfunction

function! virkspaces#make_vonce_file()
  let l:vonce_file = s:virk_settings_dir . "/" . g:virk_vonce_filename
  exec "e " . l:vonce_file
  exec "au! BufWrite <buffer> so %"
endfunction

function! virkspaces#make_virk_file()
  let l:virk_file = s:virk_settings_dir . "/" . g:virk_settings_filename
  exec "e " . l:virk_file
  exec "au! BufWrite <buffer> so %"
endfunction

function! virkspaces#make_session()
  let l:ssop = &ssop
  exec 'set ssop=' . g:virk_ssop
  exec "mksession! " . s:virk_settings_dir . "/" . g:virk_session_filename
  let &ssop = l:ssop
endfunction

" ------------- Updating functions -------------

function! virkspaces#vonce_write(cmd, odr)
  let l:fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if ! filereadable(l:fn)
    call writefile([a:cmd], l:fn)
    return
  endif
  let l:vonce = readfile(l:fn)
  for line in l:vonce
    if line =~ a:cmd
      return
    endif
  endfor
  if a:odr
    call add(l:vonce, a:cmd)
  else
    call insert(l:vonce, a:cmd, 0)
  endif
  call writefile(l:vonce, l:fn)
endfunction

function! virkspaces#vonce_remove(cmd)
  let l:fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if ! filereadable(l:fn)
    return
  endif
  let l:vonce = readfile(l:fn)
  let l:idx = index(l:vonce, a:cmd)
  if l:idx == -1
    return
  endif
  call remove(l:vonce, l:idx)
  call writefile(l:vonce, l:fn)
endfunction

function! virkspaces#nerd_tree_save()
  exec "NERDTreeFocus"
  exec "NERDTreeProjectSave " . g:virk_root_dir
endfunction

function! s:close_dir_buffers()
  for i in map(copy(getbufinfo()), "v:val.bufnr")
    if isdirectory(buffer_name(i)) && bufexists(i)
      exec "bd!" . i
    endif
  endfor
endfunction

function s:handle_close(rgx, cmd)
  let l:found = v:false
  for b in filter(range(1, bufnr("$")), "bufexists(v:val)")
    let l:name = bufname(b)
    if match(l:name, a:rgx) != -1
      if bufwinnr(b) != -1
        let l:found = v:true
      endif
      exec "bw!" . b
    endif
  endfor
  if l:found
    call virkspaces#vonce_write(a:cmd, 1)
  else
    call virkspaces#vonce_remove(a:cmd)
  endif
endfunction

function! virkspaces#close_buffers(lst)
  if len(a:lst)
    exec 'call <SID>handle_close("\\(' . join(a:lst, "\\\\|") . '\\)", "")'
  endif
endfunction

function! s:close_others()
  call <SID>handle_close("__Tagbar__.[0-9]*", "TagbarOpen")
  call <SID>handle_close("__vista__", "Vista!! | wincmd h")
  call <SID>handle_close("\\[coc-explorer\\].*", "CocCommand explorer --toggle" )
  call <SID>handle_close("__Mundo__*", "MundoToggle" )
  call virkspaces#close_buffers(g:virk_close_regexes)
endfunction

function! s:close_nerdtree()
  let l:nt_msg = 'tabn 1 | NERDTreeToggle | exec "NERDTreeProjectLoadFromCWD" | normal! <C-w><C-l>'
  if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
    call virkspaces#nerd_tree_save()
    tabdo NERDTreeClose
    call virkspaces#vonce_write(l:nt_msg, 1)
  else
    call virkspaces#vonce_remove(l:nt_msg)
  endif
endfunction

function s:close_terminals()
  for b in filter(range(1, bufnr("$")), "bufexists(v:val)")
    if getbufvar(b, "&buftype", "ERROR") == "terminal"
      exec "bw!" . b
    endif
  endfor
endfunction

function! virkspaces#update_on_leave()
  if ! g:virk_update_on_leave | return | endif
  if g:virk_enable && s:virk_settings_dir != "IGNORE"
    call <SID>close_nerdtree()
    call <SID>close_others()
    call <SID>close_terminals()
    call <SID>close_dir_buffers()
    if g:virk_make_session_on_leave
      call virkspaces#make_session()
    endif
  endif
endfunction

"""""""" Helper functions

" https://vi.stackexchange.com/questions/9432
function! s:yesno(msg) abort
  echo a:msg . " [yn] "
  let l:ans = nr2char(getchar())
  if l:ans =~ "y"
    return 1
  elseif l:ans =~ "n"
    return 0
  else
    echo "[yn]"
    return s:yesno(a:msg)
  endif
endfunction

function! s:boolean_to_string(bool)
  if a:bool
    return "Enabled"
  endif
  return "Disabled"
endfunction

function! s:virk_file_exists(fn)
  if filereadable(s:virk_settings_dir . "/" . a:fn)
    return a:fn
  endif
  return "None"
endfunction

function s:virk_error_report()
  for l:e in s:virk_errors
    echom "[VirkSpaces] " . l:e
  endfor
  let s:virk_errors = []
endfunction

" ------------- Core functions -------------

function! virkspaces#reset_cwd()
  exe "cd " . g:virk_root_dir
endfunction

function! virkspaces#info()
  let l:tmpFile = tempname()
  if g:virk_enable
    call writefile([
          \   "VirkSpace enabled       : Enabled",
          \   "VirkSpace directory     : " . s:virk_settings_dir,
          \   "VirkSpace settings file : " . s:virk_file_exists(g:virk_settings_filename),
          \   "VirkSpace vonce file    : " . s:virk_file_exists(g:virk_vonce_filename),
          \   "VirkSpace session file  : " . s:virk_file_exists(g:virk_session_filename),
          \   "VirkSpace tags file     : " . s:virk_file_exists(g:virk_tags_filename),
          \   "Update Vonce on leave   : " . s:boolean_to_string(g:virk_update_on_leave),
          \   "Make session on leave   : " . s:boolean_to_string(g:virk_make_session_on_leave),
          \   "Errors                  : " . join(s:virk_errors, ",")
          \ ], l:tmpFile)
  else
    call writefile(["VirkSpace enabled: Disabled"], l:tmpFile)
  endif
  exec "split " . l:tmpFile
  setl buftype=nofile bufhidden=wipe nobuflisted ro
endfunction

function! virkspaces#source_all_settings()
  let l:argv = argv()
  if g:virk_tags_enable
    call virkspaces#make_tags_file()
  endif
  " Catch broken session file to prevent erroring
  if g:virk_source_session
    try
      call virkspaces#source_session()
    catch /E344:/
      call add(s:virk_errors, "[VirkSpaces] E344: Caused by malformed session file")
      call virkspaces#make_session()
    endtry
  endif
  call virkspaces#source_vonce()
  call virkspaces#source_virk_settings()
  %argdel
  silent exe "argadd " . join(l:argv, '')
endfunction

function! s:process_first_arg(first)
  if ! len(g:virk_root_dir) || fnamemodify(a:first, ":p") !~ "^" . g:virk_root_dir
    let s:virk_moved = " (moved)"
    if isdirectory(a:first)
      exec "cd " . a:first
    else
      let l:dir = fnamemodify(a:first, ":p:h")
      if isdirectory(l:dir)
        exec "cd " . l:dir
      else
        return
      endif
    endif
    call virkspaces#find_virk_dir()
  endif
endfunction

function! virkspaces#status()
  if ! exists('g:virk_root_dir')
    return ''
  endif
  let l:root = fnamemodify(g:virk_root_dir, ":t")
  if len(s:virk_moved) > 0
    return l:root . " (moved)"
  endif
  return l:root
endfunction

function! virkspaces#load_virkspace()
  if ! g:virk_enable | return | endif
  call virkspaces#find_virk_dir()
  if len(argv(0)) | call <SID>process_first_arg(argv(0)) | endif
  if s:virk_settings_dir == "IGNORE"
    let g:virk_enable = 0
    echom "[VirkSpaces] Found " . g:virk_ignore_filename
    return
  endif
  if s:virk_settings_dir == "NONE"
    let g:virk_enable = 0
    echom "[VirkSpaces] No virkspace found"
    return
  endif
  cd `=g:virk_root_dir`
  call virkspaces#source_all_settings() " Sources session, must be before buffer change
  if len(argv(0)) | exec "b " . argv(0) | endif
  echom "[VirkSpaces] Virkspace found: '"
        \ . fnamemodify(s:virk_settings_dir, ":h:t")
        \ . "' (" . s:virk_dirname . ")"
        \ . s:virk_moved
  call <SID>virk_error_report()
endfunction

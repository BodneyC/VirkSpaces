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
  if ! g:virk_enabled | return | endif
  let fn = s:virk_settings_dir . "/" . g:virk_settings_filename
  if filereadable(fn) && buflisted(bufnr("%"))
    silent exec "source " . fn
  endif
endfunction

function! virkspaces#source_session()
  let fn = s:virk_settings_dir . "/" . g:virk_session_filename
  if filereadable(fn)
    silent exe "source " . fn
  endif
endfunction

function! virkspaces#source_vonce()
  let fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if filereadable(fn)
    silent exec "source " . fn
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
  for vdn in g:virk_dirnames
    let settingsDir = a:dirname . "/" . vdn
    if isdirectory(settingsDir)
      let g:virk_root_dir = a:dirname
      let s:virk_dirname = vdn
      return settingsDir
    endif
  endfor
  let parentDir = strpart(a:dirname, 0, strridx(a:dirname, "/"))
  if isdirectory(parentDir)
    return s:findVirkDirRecursive(parentDir)
  endif
endfunction

function! virkspaces#find_virk_dir() abort
  let curDir = getcwd()
  let s:virk_settings_dir = s:findVirkDirRecursive(curDir)
endfunction

" ------------- Deletion functions -------------

function! virkspaces#clean_virkspace() abort
  if s:virk_settings_dir == "IGNORE"
    return
  endif
  let delall = s:yesno("Delete all in " . s:virk_settings_dir . "?")
  for fn in [
        \   g:virk_settings_filename,
        \   g:virk_session_filename,
        \   g:virk_vonce_filename,
        \   g:virk_tags_filename,
        \ ]
    let fn = s:virk_settings_dir . "/" . fn
    if filereadable(fn)
      if delall
        call delete(fn)
      else
        if s:yesno("Delete " . fn . "?")
          call delete(fn)
        endif
      endif
    endif
  endfor
endfunction

" ------------- Creation functions -------------

function! virkspaces#create_virkspace() abort
  let project_dir = input("Dir: ", expand("%:p:h"))
  if ! isdirectory(project_dir)
    if ! s:yesno("\"" . project_dir . "\" is not a directory, make dirs?")
      return
    endif
  endif
  if isdirectory(project_dir . "/" . g:virk_dirnames[0])
    if ! s:yesno("\"" . project_dir . "/" . g:virk_dirnames[0] . "\" exists, overwrite?")
      return
    else
      if delete(fnameescape(project_dir . "/" . g:virk_dirnames[0]))
        echom "[VirkSpaces] \"" . project_dir . "/" . g:virk_dirnames[0] . " could not be deleted, exiting..."
        return
      endif
    endif
  endif
  call mkdir(project_dir . "/" . g:virk_dirnames[0])
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
  let fn = s:virk_settings_dir . "/" . g:virk_tags_filename
  let exc = ""
  if len(g:virk_tags_excludes) > 0
    let exc = join(" --exclude ", g:virk_tags_excludes)
  endif
  exec "set tags=" . fn
  silent exec "!" . g:virk_tags_bin . " " . g:virk_tags_flags . " " . fn . " " . exc . " " . g:virk_root_dir
endfunction

function! virkspaces#make_vonce_file()
  let vonce_file = s:virk_settings_dir . "/" . g:virk_vonce_filename
  exec "e " . vonce_file
  exec "au! BufWrite <buffer> so %"
endfunction

function! virkspaces#make_virk_file()
  let virk_file = s:virk_settings_dir . "/" . g:virk_settings_filename
  exec "e " . virk_file
  exec "au! BufWrite <buffer> so %"
endfunction

function! virkspaces#make_session()
  let ssop = &ssop
  exec 'set ssop=' . g:virk_ssop
  exec "mksession! " . s:virk_settings_dir . "/" . g:virk_session_filename
  let &ssop = ssop
endfunction

" ------------- Updating functions -------------

function! virkspaces#vonce_write(cmd, odr)
  let fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if ! filereadable(fn)
    call writefile([a:cmd], fn)
    return
  endif
  let vonce = readfile(fn)
  for line in vonce
    if line =~ a:cmd
      return
    endif
  endfor
  if a:odr
    call add(vonce, a:cmd)
  else
    call insert(vonce, a:cmd, 0)
  endif
  call writefile(vonce, fn)
endfunction

function! virkspaces#vonce_remove(cmd)
  let fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if ! filereadable(fn)
    return
  endif
  let vonce = readfile(fn)
  let idx = index(vonce, a:cmd)
  if idx == -1
    return
  endif
  call remove(vonce, idx)
  call writefile(vonce, fn)
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
  let found = v:false
  for b in filter(range(1, bufnr("$")), "bufexists(v:val)")
    let name = bufname(b)
    if match(name, a:rgx) != -1
      if bufwinnr(b) != -1
        let found = v:true
      endif
      exec "bw!" . b
    endif
  endfor
  if found
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
  call <SID>handle_close("\\[coc-explorer\\].*", "CocCommand explorer --no-focus --toggle " . g:virk_root_dir)
  call <SID>handle_close("__Mundo__*", "MundoToggle" )
  call virkspaces#close_buffers(g:virk_close_regexes)
endfunction

function! virkspaces#close_known_if_last()
  call <SID>close_if_last('coc-explorer', 'CocCommand explorer --no-focus --toggle ' . g:virk_root_dir)
endfunction

function! s:close_if_last(ft, cmd)
  if winnr("$") == 1 && a:ft == &ft
    if a:ft == &ft
      call virkspaces#vonce_write(a:cmd, 1)
      bw | q
    else
      call virkspaces#vonce_remove(a:cmd)
    endif
  endif
endfunction

function! s:close_nerdtree()
  let nt_msg = 'tabn 1 | NERDTreeToggle | exec "NERDTreeProjectLoadFromCWD" | normal! <C-w><C-l>'
  if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
    call virkspaces#nerd_tree_save()
    tabdo NERDTreeClose
    call virkspaces#vonce_write(nt_msg, 1)
  else
    call virkspaces#vonce_remove(nt_msg)
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
  if g:virk_enabled && s:virk_settings_dir != "IGNORE"
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
  let ans = nr2char(getchar())
  if ans =~ "y"
    return 1
  elseif ans =~ "n"
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
  for e in s:virk_errors
    echom "[VirkSpaces] " . e
  endfor
  let s:virk_errors = []
endfunction

" ------------- Core functions -------------

function! virkspaces#reset_cwd()
  exe "cd " . g:virk_root_dir
endfunction

function! virkspaces#info()
  let tmpFile = tempname()
  if g:virk_enabled
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
          \ ], tmpFile)
  else
    call writefile(["VirkSpace enabled: Disabled"], tmpFile)
  endif
  exec "split " . tmpFile
  setl buftype=nofile bufhidden=wipe nobuflisted ro
endfunction

function! virkspaces#source_all_settings()
  let argv = argv()
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
  " Damn spaces
  silent exe "argadd " . join(map(argv, {i, e -> substitute(e, ' ', '\\ ', 'g')}), ' ')
endfunction

function! s:process_first_arg(first)
  if ! len(g:virk_root_dir) || fnamemodify(a:first, ":p") !~ "^" . g:virk_root_dir
    let s:virk_moved = " (moved)"
    if isdirectory(a:first)
      exec "cd " . a:first
    else
      let dir = fnamemodify(a:first, ":p:h")
      if isdirectory(dir)
        exec "cd " . dir
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
  let root = fnamemodify(g:virk_root_dir, ":t")
  if len(s:virk_moved) > 0
    return root . " (moved)"
  endif
  return root
endfunction

function! virkspaces#load_virkspace()
  if ! g:virk_enabled | return | endif
  call virkspaces#find_virk_dir()
  if len(argv(0)) && g:virk_move_virk_space
    call <SID>process_first_arg(argv(0))
  endif
  if s:virk_settings_dir == "IGNORE"
    let g:virk_enabled = 0
    echom "[VirkSpaces] Found " . g:virk_ignore_filename
    return
  endif
  if s:virk_settings_dir == "NONE"
    let g:virk_enabled = 0
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

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
let s:virk_settings_dir          = ""
let s:virk_errors                = []

" ------------- Sourcing functions -------------

function! virkspaces#virksourcevirksettings()
  let l:fn = s:virk_settings_dir . "/" . g:virk_settings_filename
  if filereadable(l:fn) && buflisted(bufnr("%"))
    exec "source " . l:fn
  endif
endfunction

function! virkspaces#virksourcesession()
  let l:fn = s:virk_settings_dir . "/" . g:virk_session_filename
  if filereadable(l:fn)
    exec "source " . l:fn
  endif
endfunction

function! virkspaces#virksourcevonce()
  let l:fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if filereadable(l:fn)
    exec "source " . l:fn
  endif
endfunction

function! virkspaces#virkcocsettings()
  let l:fn = s:virk_settings_dir . "/" . g:virk_coc_filename
  if filereadable(l:fn)
    let false = 0
    let true = 1
    let json = eval(join(readfile(l:fn)))
    for [k, v] in items(json)
      exec "call coc#config("" . k . "", " . v . ")"
    endfor
  endif
endfunction

" ------------- Directory functions -------------

function! s:findVirkDirRecursive(dirname) abort
  if strpart(a:dirname, 0, stridx(a:dirname, "://")) != ""
    return "0"
  endif
  if g:virk_ignore_enable && filereadable(a:dirname . "/" . g:virk_ignore_filename)
    return "1"
  endif
  let l:settingsDir = a:dirname . "/" . g:virk_dirname
  if isdirectory(l:settingsDir)
    let g:virk_root_dir = a:dirname
    return l:settingsDir
  endif
  let l:parentDir = strpart(a:dirname, 0, strridx(a:dirname, "/"))
  if isdirectory(l:parentDir)
    return s:findVirkDirRecursive(l:parentDir)
  endif
endfunction

function! virkspaces#virkfindvirkdir() abort
  let l:curDir = getcwd()
  let s:virk_settings_dir = s:findVirkDirRecursive(l:curDir)
endfunction

function! virkspaces#virkchangepwd()
  cd `=g:virk_root_dir`
endfunction

" ------------- Deletion functions -------------

function! virkspaces#virkcleanvirkspace() abort
  if s:virk_settings_dir == "0"
    return
  endif
  let l:delall = s:yesno("Delete all in " . s:virk_settings_dir . "?")
  for l:fn in [
        \   g:virk_settings_filename, 
        \   g:virk_session_filename, 
        \   g:virk_vonce_filename,
        \   g:virk_tags_filename, 
        \   g:virk_coc_filename
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

function! virkspaces#virkcreatevirkspace() abort
  let l:projDir = input("Dir: ", expand("%:p:h"))
  if ! isdirectory(l:projDir)
    if ! s:yesno("\"" . l:projDir . "\" is not a directory, make dirs?")
      return
    endif
  endif
  if isdirectory(l:projDir . "/" . g:virk_dirname)
    if ! s:yesno("\"" . l:projDir . "/" . g:virk_dirname . "\" exists, overwrite?")
      return
    else
      if delete(fnameescape(l:projDir . "/" . g:virk_dirname))
        echom "[VirkSpaces] \"" . l:projDir . "/" . g:virk_dirname . " could not be deleted, exiting..."
        return
      endif
    endif
  endif
  call mkdir(l:projDir . "/" . g:virk_dirname)
  echom "[VirkSpaces] Project directory created"
  if g:virk_cd_on_create == 0
    if s:yesno("CD to project directory parent?")
      return
    endif
  endif
  call virkspaces#virkloadvirkspace()
  call s:virk_error_report()
endfunction

" https://github.com/neoclide/coc.nvim/pull/1110/commits/3bf6e19ea
function! virkspaces#virkcoccreate()
  let currentDir = getcwd()
  let fsRootDir = fnamemodify($HOME, ":p:h:h:h")

  if currentDir == $HOME
    echom "Can't resolve local config from current working directory."
    return
  endif

  while isdirectory(currentDir) && !(currentDir ==# $HOME) && !(currentDir ==# fsRootDir)
    if isdirectory(currentDir.'/'.g:virk_dirname)
      execute 'edit '.currentDir.'/'.g:virk_dirname.'/coc-settings.json'
      return
    endif
    let currentDir = fnamemodify(currentDir, ':p:h:h')
  endwhile

  if coc#util#prompt_confirm("No local config detected, would you like to create ".g:virk_dirname."/coc-settings.json?")
    call mkdir(g:virk_dirname, 'p')
    execute 'edit 'g:virk_dirname."/coc-settings.json'
  endif
endfunction

function! virkspaces#virkmaketagsfile()
  let l:fn = s:virk_settings_dir . "/" . g:virk_tags_filename
  let l:exc = ""
  for exclude in g:virk_tags_excludes
    let l:exc .= "--exclude=" . exclude . " "
  endfor
  exec "set tags=" . l:fn
  silent exec "!" . g:virk_tags_bin . " " . g:virk_tags_flags . " " . l:fn . " " . l:exc . " " . g:virk_root_dir
endfunction

function! virkspaces#virkmakevoncefile()
  let l:vonce_file = s:virk_settings_dir . "/" . g:virk_vonce_filename
  exec "e " . l:vonce_file
  exec "au! BufWrite <buffer> so %"
endfunction

function! virkspaces#virkmakevirkfile()
  let l:virk_file = s:virk_settings_dir . "/" . g:virk_settings_filename
  exec "e " . l:virk_file
  exec "au! BufWrite <buffer> so %"
endfunction

function! virkspaces#virkmakesession()
  let sessionoptions = &sessionoptions
  set sessionoptions+=winsize,winpos sessionoptions-=blank,options,resize,folds
  exec "mksession! " . s:virk_settings_dir . "/" . g:virk_session_filename
  let &sessionoptions = sessionoptions
endfunction

" ------------- Updating functions -------------

function! virkspaces#virkvoncewrite(cmd, odr)
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

function! virkspaces#virkvonceremove(cmd)
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

function! virkspaces#virknerdtreesave()
  exec "NERDTreeFocus"
  exec "NERDTreeProjectSave " . g:virk_root_dir
endfunction

function! s:delDirBuffers()
  for i in map(copy(getbufinfo()), "v:val.bufnr")
    if isdirectory(buffer_name(i))
      exec "bd!" . i
    endif
  endfor
endfunction

function! s:close_others()
  let dict = { 
        \   "__Tagbar__.1": "TagbarOpen",
        \   "__vista__": "Vista!! | wincmd h",
        \   "\\[coc-explorer\\]": "CocCommand explorer --toggle" 
        \ }
  for [k, v] in items(dict)
    let winnr = bufwinnr(k)
    if winnr != -1
      exec winnr . "wincmd q"
      let bufnr = 0
      while bufnr != -1
        let bufnr = bufnr(k)
        try
          exec "bd!" . bufnr
        catch E516
          let bufnr = -1
        endtry
      endwhile
      call virkspaces#virkvoncewrite(v, 1)
    else
      call virkspaces#virkvonceremove(v)
    endif
  endfor
endfunction

function! s:close_nerdtree()
  let l:nt_msg = "tabn 1 | NERDTreeToggle | NERDTreeProjectLoadFromCWD"
  if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
    call virkspaces#virknerdtreesave()
    tabdo NERDTreeClose
    call virkspaces#virkvoncewrite(l:nt_msg, 1)
  else
    call virkspaces#virkvonceremove(l:nt_msg)
  endif
endfunction

function s:close_terminals()
  let buffers = filter(range(1, bufnr("$")), "bufexists(v:val)")
  for b in buffers
    if getbufvar(b, "&buftype", "ERROR") == "terminal"
      exec "bd!" . b
    endif
  endfor
endfunction

function! virkspaces#virkupdateonleave()
  if s:virk_settings_dir != "0"
    call s:close_nerdtree()
    call s:close_others()
    call s:close_terminals()
    call s:delDirBuffers()
    if g:virk_make_session_on_leave
      call virkspaces#virkmakesession()
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

function! virkspaces#virkinfo()
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
          \   "Source CoC settings     : " . s:boolean_to_string(g:virk_coc_settings_enable),
          \   "Errors                  : " . join(s:virk_errors, ",")
          \ ], l:tmpFile)
  else
    call writefile(["VirkSpace enabled: Disabled"], l:tmpFile)
  endif
  exec "split " . l:tmpFile
  setl buftype=nofile bufhidden=wipe nobuflisted ro
endfunction

function! virkspaces#virksourceallsettings()
  if g:virk_tags_enable
    call virkspaces#virkmaketagsfile()
  endif
  " Catch broken session file to prevent erroring
  if g:virk_source_session
    try
      call virkspaces#virksourcesession()
    catch /E344:/
      call add(s:virk_errors, "[VirkSpaces] E344: Caused by malformed session file")
      call virkspaces#virkmakesession()
    endtry
  endif
  if g:virk_coc_settings_enable != 0
    call virkspaces#virkcocsettings()
  endif
  call virkspaces#virksourcevonce()
  call virkspaces#virksourcevirksettings()
endfunction

function! virkspaces#virkloadvirkspace()
  if argc() > 0
    let l:first = argv()[0]
  endif
  if exists("l:first") && isdirectory(l:first)
    exec "cd " . l:first
  endif
  call virkspaces#virkfindvirkdir() 
  if s:virk_settings_dir == "1"
    echom "[VirkSpaces] Found " . g:virk_ignore_filename
    return
  endif
  if s:virk_settings_dir == "0"
    echom "[VirkSpaces] No virkspace found"
    return
  endif
  call virkspaces#virkchangepwd()
  call virkspaces#virksourceallsettings() " Sources session, must be before buffer change
  if exists("l:first")
    if ! isdirectory(l:first)
      exec "b " . l:first
    endif
  endif
  echom "[VirkSpaces] Virkspace found: " . s:virk_settings_dir
  call s:virk_error_report()
endfunction

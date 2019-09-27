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
let g:virk_enable                = get(g:, "virk_enable", 1)
let g:virk_ignore_enable         = get(g:, "virk_ignore_enable", 1)
let g:virk_ignore_filename       = get(g:, "virk_ignore_filename", ".virkignore")
let g:virk_dirname               = get(g:, "virk_dirname", ".virkspace")
let g:virk_cd_on_create          = get(g:, "virk_cd_on_create", 1)
let g:virk_settings_filename     = get(g:, "virk_settings_filename", "virkspace.vim")
let g:virk_vonce_filename        = get(g:, "virk_vonce_filename", "virkvonce.vim")
let g:virk_session_filename      = get(g:, "virk_session_filename", "session.vim")
let g:virk_tags_filename         = get(g:, "virk_tags_filename", "tags")
let g:virk_coc_filename          = get(g:, "virk_coc_filename", "coc-settings.json")
let g:virk_coc_settings_enable   = get(g:, "virk_coc_settings_enable", 1)
let g:virk_source_session        = get(g:, "virk_source_session", 1)
let g:virk_tags_enable           = get(g:, "virk_tags_enable", 1)
let g:virk_tags_bin              = get(g:, "virk_tags_bin", "ctags")
let g:virk_tags_flags            = get(g:, "virk_tags_flags", "-Rf")
let g:virk_tags_excludes         = get(g:, "virk_tags_excludes", [g:virk_dirname])
let g:virk_make_session_on_leave = get(g:, "virk_make_session_on_leave", 1)
let g:virk_update_on_leave       = get(g:, "virk_update_on_leave", 1)

let g:virk_root_dir              = ""

let s:virk_settings_dir          = ""
let s:virk_errors                = []

" ------------- Sourcing functions -------------

function! VSSourceVirkSettings()
  let l:fn = s:virk_settings_dir . "/" . g:virk_settings_filename
  if filereadable(l:fn) && buflisted(bufnr("%"))
    exec "source " . l:fn
  endif
endfunction
command! -nargs=0 VSSourceVirkSettings call VSSourceVirkSettings()

function! VSSourceSession()
  let l:fn = s:virk_settings_dir . "/" . g:virk_session_filename
  if filereadable(l:fn)
    exec "source " . l:fn
  endif
endfunction
command! -nargs=0 VSSourceSession call VSSourceSession()

function! VSSourceVonce()
  let l:fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if filereadable(l:fn)
    exec "source " . l:fn
  endif
endfunction
command! -nargs=0 VSSourceVonce call VSSourceVonce()

function! VSCoCSettings()
  let l:fn = s:virk_settings_dir . "/" . g:virk_coc_filename
  if filereadable(l:fn)
    let false = 0
    let true = 1
    let json = eval(join(readfile(l:fn)))
    for [k, v] in items(json)
      exec "call coc#config('" . k . "', " . v . ")"
    endfor
  endif
endfunction
command! -nargs=0 VSCoCSettings call VSCoCSettings()

" ------------- Directory functions -------------

function! s:findVirkDirRecursive(dirname) abort
  if strpart(a:dirname, 0, stridx(a:dirname, "://")) != ""
    return 0
  endif
  if g:virk_ignore_enable && filereadable(a:dirname . "/" . g:virk_ignore_filename)
    echom "CATS"
    return -1
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

function! VSFindVirkDir() abort
  let l:curDir = expand("%:p:h")
  let s:virk_settings_dir = s:findVirkDirRecursive(l:curDir)
endfunction
command! -nargs=0 VSFindVirkDir call VSFindVirkDir()

function! VSChangePWD()
  cd `=g:virk_root_dir`
endfunction
command! -nargs=0 VSChangePWD call VSChangePWD()

" ------------- Deletion functions -------------

function! VSCleanVirkSpace() abort
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
command! -nargs=0 VSCleanVirkSpace call VSCleanVirkSpace()

" ------------- Creation functions -------------

function! VSCreateVirkSpace() abort
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
  call VSLoadVirkSpace()
  call s:virk_error_report()
endfunction
command! -nargs=0 VSCreateVirkSpace call VSCreateVirkSpace()

function! VSMakeTagsFile()
  let l:fn = s:virk_settings_dir . "/" . g:virk_tags_filename
  let l:exc = ""
  for exclude in g:virk_tags_excludes
    let l:exc .= "--exclude=" . exclude . " "
  endfor
  exec "set tags=" . l:fn
  silent exec "!" . g:virk_tags_bin . " " . g:virk_tags_flags . " " . l:fn . " " . l:exc . " " . g:virk_root_dir
endfunction
command! -nargs=0 VSMakeTagsFile call VSMakeTagsFile()

function! VSMakeVonceFile()
  let l:vonce_file = s:virk_settings_dir . "/" . g:virk_vonce_filename
  exec "e " . l:vonce_file
  exec "au! BufWrite <buffer> so %"
endfunction
command! -nargs=0 VSMakeVonceFile call VSMakeVonceFile()

function! VSMakeVirkFile()
  let l:virk_file = s:virk_settings_dir . "/" . g:virk_settings_filename
  exec "e " . l:virk_file
  exec "au! BufWrite <buffer> so %"
endfunction
command! -nargs=0 VSMakeVirkFile call VSMakeVirkFile()

function! VSMakeSession()
  let sessionoptions = &sessionoptions
  set sessionoptions+=winsize,winpos sessionoptions-=blank,options,resize
  exec "mksession! " . s:virk_settings_dir . "/" . g:virk_session_filename
  let &sessionoptions = sessionoptions
endfunction
command! -nargs=0 VSMakeSession call VSMakeSession()

" ------------- Updating functions -------------

function! VSVonceWrite(cmd, odr)
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
command! -nargs=1 VSVonceWrite call VSVonceWrite(<f-args>)

function! VSVonceRemove(cmd)
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

function! VSNerdTreeSave()
  exec 'NERDTreeFocus'
  exec 'NERDTreeProjectSave ' . g:virk_root_dir
endfunction

function! s:delDirBuffers()
  for i in map(copy(getbufinfo()), 'v:val.bufnr')
    if isdirectory(buffer_name(i))
      exec 'bd ' . i
    endif
  endfor
endfunction

function! VSUpdateOnLeave()
  if s:virk_settings_dir != "0"
    let l:vista_msg = "Vista!! | wincmd h"
    if bufwinnr("__vista__") != -1
      tabdo Vista!
      call VSVonceWrite(l:vista_msg, 0)
    else
      call VSVonceRemove(l:vista_msg)
    endif
    let l:tagbar_msg = "TagbarOpen"
    if bufwinnr("__Tagbar__.1") != -1
      tabdo TagbarClose
      call VSVonceWrite(l:tagbar_msg, 1)
    else
      call VSVonceRemove(l:tagbar_msg)
    endif
    let l:nt_msg = "tabn 1 | NERDTreeToggle | NERDTreeProjectLoadFromCWD"
    if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
      call VSNerdTreeSave()
      tabdo NERDTreeClose
      call VSVonceWrite(l:nt_msg, 1)
    else
      call VSVonceRemove(l:nt_msg)
    endif
    call s:delDirBuffers()
    if g:virk_make_session_on_leave
      call VSMakeSession()
    endif
  endif
endfunction
command! -nargs=0 VSUpdateOnLeave call VSUpdateOnLeave()

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
    echom '[VirkSpaces] ' . l:e
  endfor
  let s:virk_errors = []
endfunction

" ------------- Core functions -------------

function! VSInfo()
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
          \   "Errors                  : " . join(s:virk_errors, ',')
          \ ], l:tmpFile)
  else
    call writefile(["VirkSpace enabled: Disabled"], l:tmpFile)
  endif
  exec 'split ' . l:tmpFile
  setl buftype=nofile bufhidden=wipe nobuflisted ro
endfunction
command! -nargs=0 VSInfo call VSInfo()

function! VSSourceAllSettings()
  if g:virk_tags_enable
    call VSMakeTagsFile()
  endif
  " Catch broken session file to prevent erroring
  if g:virk_source_session
    try
      call VSSourceSession()
    catch /E344:/
      call add(s:virk_errors, "[VirkSpaces] E344: Caused by malformed session file")
      call VSMakeSession()
    endtry
  endif
  if g:virk_coc_settings_enable != 0
    call VSCoCSettings()
  endif
  call VSSourceVonce()
  call VSSourceVirkSettings()
endfunction
command! -nargs=0 VSSourceAllSettings call VSSourceAllSettings

function! VSLoadVirkSpace()
  if argc() > 0
    let l:first = argv()[0]
  endif
  call VSFindVirkDir() 
  if s:virk_settings_dir == -1
    echom "[VirkSpaces] Found " . g:virk_ignore_filename
    return
  endif
  if s:virk_settings_dir == 0
    echom "[VirkSpaces] No virkspace found"
    return
  endif
  call VSChangePWD()
  call VSSourceAllSettings() " Sources session, must be before buffer change
  if exists("l:first")
    if ! isdirectory(l:first)
      exec 'b ' . l:first
    endif
  endif
  echom "[VirkSpaces] Virkspace found: " . s:virk_settings_dir
  call s:virk_error_report()
endfunction
command! -nargs=0 VSLoadVirkSpace call VSLoadVirkSpace()

" ------------- Automation AuGroups -------------

augroup virk-spaces
  autocmd!
  autocmd VimEnter * nested if g:virk_enable
        \ |   call VSLoadVirkSpace()
        \ | endif
  autocmd BufEnter * if g:virk_enable
        \ |   call VSSourceVirkSettings()
        \ | endif
  autocmd VimLeave * if g:virk_update_on_leave
        \ |   call VSUpdateOnLeave()
        \ | endif
augroup END

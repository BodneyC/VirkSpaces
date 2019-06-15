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
let g:virk_enable = get(g:, "virk_enable", 1)
let g:virk_dirname = get(g:, "virk_dirname", ".virkspace")
let g:virk_cd_on_create = get(g:, "virk_cd_on_create", 1)
let g:virk_settings_filename = get(g:, "virk_settings_filename", "virkspace.vim")
let g:virk_vonce_filename = get(g:, "virk_vonce_filename", "virkvonce.vim")
let g:virk_session_filename = get(g:, "virk_session_filename", "session.vim")
let g:virk_tags_filename = get(g:, "virk_tags_filename", "tags")
let g:virk_coc_filename = get(g:, "virk_coc_filename", "coc-settings.json")
let g:virk_coc_settings_enable = get(g:, "virk_coc_settings_enable", 1)
let g:virk_source_session = get(g:, "virk_source_session", 1)
let g:virk_make_session_on_leave = get(g:, "virk_make_session_on_leave", 1)

let s:virk_settings_dir = ""

" set ssop+=resize,winpos,winsize,folds

function! s:findSettingsDir(dirname) abort
  if strpart(a:dirname, 0, stridx(a:dirname, "://")) != ""
    return "None"
  endif
  let l:settingsDir = a:dirname . "/" . g:virk_dirname
  if isdirectory(l:settingsDir)
    return l:settingsDir
  endif
  let l:parentDir = strpart(a:dirname, 0, strridx(a:dirname, "/"))
  if isdirectory(l:parentDir)
    return s:findSettingsDir(l:parentDir)
  endif
endfunction

function! VSSetSettings()
  let b:coc_root_patterns = g:virk_dirname
  let l:fn = s:virk_settings_dir . "/" . g:virk_settings_filename
  if filereadable(l:fn) && buflisted(bufnr("%"))
    exec "source " . l:fn
  endif
endfunction
command! -nargs=0 VSSetSettings call VSSetSettings()

function! VSSetSession()
  let l:fn = s:virk_settings_dir . "/" . g:virk_session_filename
  if ! filereadable(l:fn)
    return
  endif
  exec "source " . l:fn
  let l:fn = g:virk_dirname . "/" . g:virk_session_filename
  if bufnr(l:fn)
    " exec "bd " . l:fn
  endif
endfunction
command! -nargs=0 VSSetSession call VSSetSession()

function! VSSetTags()
  let l:fn = s:virk_settings_dir . "/" . g:virk_tags_filename
  if filereadable(l:fn)
    exec "set tags=" . l:fn
  endif
endfunction
command! -nargs=0 VSSetTags call VSSetTags()

function! VSSetPWD()
  cd `=s:virk_settings_dir . "/.."`
endfunction
command! -nargs=0 VSSetPWD call VSSetPWD()

function! VSSetVonce()
  let l:fn = s:virk_settings_dir . "/" . g:virk_vonce_filename
  if filereadable(l:fn)
    exec "source " . l:fn
  endif
endfunction
command! -nargs=0 VSSetVonce call VSSetVonce()

function! VSSetVirkDir() abort
  let l:curDir = expand("%:p:h")
  let s:virk_settings_dir = s:findSettingsDir(l:curDir)
  if s:virk_settings_dir == "None"
    return
  endif
endfunction
command! -nargs=0 VSSetVirkDir call VSSetVirkDir()

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

function! VSLoadVirkSpace()
  call VSSetVirkDir() 
  if s:virk_settings_dir == "0"
    echom "[VirkSpaces] No virkspace found"
    return
  endif
  call VSSetPWD()
  call VSSetTags()
  if g:virk_source_session && argc() == 0
    call VSSetSession()
  endif
  if g:virk_coc_settings_enable != 0
    call VSCoCSettings()
  endif
  call VSSetVonce()
  call VSSetSettings()
  echom "[VirkSpaces] Virkspace found: " . s:virk_settings_dir
endfunction
command! -nargs=0 VSLoadVirkSpace call VSLoadVirkSpace()

"""""""" Management Functions

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
  cd `=l:projDir`
endfunction
command! -nargs=0 VSCreateVirkSpace call VSCreateVirkSpace()

function! VSMakeSession()
  exec "mksession! " . s:virk_settings_dir . "/" . g:virk_session_filename
endfunction
command! -nargs=0 VSMakeSession call VSMakeSession()

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
  echom l:vonce
  if a:odr
    call reverse(add(reverse(l:vonce), a:cmd))
  else
    call add(l:vonce, a:cmd)
  endif
  call writefile(l:vonce, l:fn)
endfunction
command! -nargs=1 VSVonceWrite call VSVonceWrite(<f-args>)

function! VSMakeSessionOnLeave()
  if s:virk_settings_dir == "0"
    return
  endif
  if bufwinnr("__vista__") != -1
    tabdo Vista!
    call VSVonceWrite("Vista!! | Vista!! | wincmd h", 1)
  endif
  if exists("t:NERDTreeBufName") && bufwinnr(t:NERDTreeBufName) != -1
    tabdo NERDTreeClose
    call VSVonceWrite("NERDTree | setlocal nobuflisted | wincmd l", 0)
  endif
  call VSMakeSession()
endfunction
command! -nargs=0 VSMakeSessionOnLeave call VSMakeSessionOnLeave()

"""""""" Helper functions

" https://vi.stackexchange.com/questions/9432/confirmmsg-choices-without-newline-on-msg
function! s:yesno(msg) abort
  echo a:msg . " [yn] "
  let l:ans = nr2char(getchar())
  if l:ans =~ "y"
    return 1
    return
  elseif l:ans =~ "n"
    return 0
  else
    echo "[yn]"
    return s:yesno(a:msg)
  endif
endfunction

function! s:booleanToString(bool)
  if a:bool
    return "Yes"
  endif
  return "No"
endfunction

function! VSVirkSpaceInfo()
  let l:tmpFile = tempname()
  if g:virk_enable
    call writefile([
          \   "Is VirkSpace enabled:  Yes",
          \   "VirkSpace directory:   " . s:virk_settings_dir,
          \   "Make session on leave: " . s:booleanToString(g:virk_make_session_on_leave),
          \   "Source CoC settings:   " . s:booleanToString(g:virk_coc_settings_enable)
          \ ], l:tmpFile)
  else
    call writefile(["Is VirkSpace enabled: No"], l:tmpFile)
  endif
	exec 'split ' . l:tmpFile
	setl buftype=nofile bufhidden=wipe nobuflisted
endfunction
command! -nargs=0 VSVirkSpaceInfo call VSVirkSpaceInfo()

"""""""" Automation augroup

augroup project-vim
  autocmd!
  autocmd VimEnter * nested if g:virk_enable
        \ |   call VSLoadVirkSpace()
        \ | endif
  autocmd BufEnter * if g:virk_enable
        \ |   call VSSetSettings()
        \ | endif
  autocmd VimLeave * if g:virk_make_session_on_leave
        \ |   call VSMakeSessionOnLeave()
        \ | endif
augroup END

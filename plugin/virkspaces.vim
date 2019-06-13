" " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " "
"                                                                                                             "
"                                      ,-.  .--.--.                                                           "
"          ,---.  ,--,             ,--/ /| /  /    '. ,-.----.                                                "
"         /__./|,--.'|    __  ,-.,--. :/ ||  :  /`. / \    /  \                                               "
"    ,---.;  ; ||  |,   ,' ,'/ /|:  : ' / ;  |  |--`  |   :    |                                 .--.--.      "
"   /___/ \  | |`--'_   '  | |' ||  '  /  |  :  ;_    |   | .\ :  ,--.--.     ,---.     ,---.   /  /    '     "
"   \   ;  \ ' |,' ,'|  |  |   ,''  |  :   \  \    `. .   : |: | /       \   /     \   /     \ |  :  /`./     "
"    \   \  \: |'  | |  '  :  /  |  |   \   `----.   \|   |  \ :.--.  .-. | /    / '  /    /\ ||  :  ;_       "
"     ;   \  ' .|  | :  |  | '   '  : |. \  __ \  \  ||   : .  | \__\/: . ..    ' /  .    ' /   \  \    `.    "
"      \   \   ''  : |__;  : |   |  | ' \ \/  /`--'  /:     |`-' ," .--.; |'   ; :__ '   ; - /|  `----.   \   "
"       \   `  ;|  | '.'|  , ;   '  : |--''--'.     / :   : :   /  /  ,.  |'   | '.'|'   |  / | /  /`--'  /   "
"        :   \ |;  :    ;---'    ;  |,'     `--'---'  |   | :  ;  :   .'   \   :    :|   :    |'--'.     /    "
"         '---" |  ,   /         '--'                 `---'.|  |  ,     .-./\   \  /  \   \  /   `--'---'     "
"                ---`-'                                 `---`   `--`---'     `----'    `----'                 "
"                                                                                                             "
" " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " " "
let s:virk_enable = get(g:, "virk_enable", 1)
let s:virk_dirname = get(g:, "virk_dirname", ".virkspace")

" https://vi.stackexchange.com/questions/9432/confirmmsg-choices-without-newline-on-msg
function! s:yesno(msg) abort
  echo a:msg . " [yn] "
  if nr2char(getchar())  ==? "y"
    return 1
  elseif l:answer ==? "n"
    return 0
  else
    echo "[yn]"
    return s:yesno(a:msg)
  endif
endfunction

function! s:findSettingsDir(dirname) abort
  if strpart(a:dirname, 0, stridx(a:dirname, "://")) != ""
    return
  endif
  let l:settingsDir = a:dirname . "/" . s:virk_dirname
  if isdirectory(l:settingsDir)
    return l:settingsDir
  endif
  let l:parentDir = strpart(a:dirname, 0, strridx(a:dirname, "/"))
  if isdirectory(l:parentDir)
    return s:findSettingsDir(l:parentDir)
  endif
endfunction

function! s:handleSettings(fn)
  if ! isreadable(a:fn)
    return
  endif
  exec "source " . a:fn
endfunction

function! s:handleSession(fn)
  if ! isreadable(a:fn)
    return
  endif
endfunction

function! s:handleCoc(fn)
  if ! isreadable(a:fn)
    return
  endif
endfunction

function! s:handleTags(fn)
  if ! isreadable(a:fn)
    return
  endif
endfunction

function! s:sourceSettings(fns)
  call s:handleSettings(fns["project"])
  call s:handleSession(fns["session"])
  call s:handleCoc(fns["coc"])
  call s:handleTags(fns["tags"])
endfunction

function! s:setSourceFiles(dir) abort
  return {
        \   "project" : a:dir . "/" . get(g:, "virk_settings_filename", "virkspace.vim"),
        \   "session" : a:dir . "/" . get(g:, "virk_session_filename", "Session.vim"),
        \   "coc"     : a:dir . "/" . get(g:, "virk_coc_filename", "coc-settings.json"),
        \   "tags"    : a:dir . "/" . get(g:, "virk_tags_filename", "tags")
        \ }
endfunction

function! VSSourceProjectSettings(fname) abort
  let l:curDir = fnamemodify(a:fname, ":p:h")
  let l:settingsDir = s:findSettingsDir(l:curDir)
  if !len(l:settingsDir) 
    echom "[ProjectVim] No settings directory found"
    return
  endif
  let l:settingsFiles = s:setSourceFiles(l:settings)
  call s:sourceSettings(l:settingsFiles)
endfunction

function! VSCreateProjectDir() abort
  let l:projDir = input("Dir: ", expand("%:p:h"))
  if ! isdirectory(l:projDir)
    if ! s:yesno("\"" . l:projDir . "\" is not a directory, make dirs?")
      return
    endif
  else
    if ! s:yesno("\"" . l:projDir . "/" . s:virk_dirname . "\" exists, overwrite?")
      return
    else
      if delete(fnameescape(l:projDir . "/" . s:virk_dirname))
        echom "[ProjectVim] \"" . l:projDir . "/" . s:virk_dirname . " could not be deleted, eciting..."
        return
      endif
    endif
  endif
  call mkdir(fnameescape(l:projDir . "/" . s:virk_dirname), "p")
  echom "[ProjectVim] Project directory created"
  if s:yesno("CD to project directory parent?")
    cd `=l:projDir`
  endif
endfunction
command! -nargs=0 VSCreateProjectDir call VSCreateProjectDir()

augroup project-vim
  autocmd!
  autocmd VimEnter,BufWinEnter,BufEnter * if s:virk_enable 
        \ |   call VSSourceProjectSettings(expand("%:p:h")) 
        \ | endif
augroup END

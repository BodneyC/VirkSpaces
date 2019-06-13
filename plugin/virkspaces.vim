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
let g:virk_enable = get(g:, "virk_enable", 1)
let g:virk_dirname = get(g:, "virk_dirname", ".virkspace")
let g:virk_settings_filename = get(g:, "virk_settings_filename", "virkspace.vim")
let g:virk_session_filename = get(g:, "virk_session_filename", "Session.vim")
let g:virk_tags_filename = get(g:, "virk_tags_filename", "tags")
let g:virk_coc_root_enable = get(g:, "virk_coc_root_enable", 1)
let s:virk_settings_dir = ''

" https://vi.stackexchange.com/questions/9432/confirmmsg-choices-without-newline-on-msg
function! s:yesno(msg) abort
  echo a:msg . " [yn] "
  if nr2char(getchar())  ==? "y"
    return 1
    return
  elseif l:answer ==? "n"
    return 0
  else
    echo "[yn]"
    return s:yesno(a:msg)
  endif
endfunction

function! s:findSettingsDir(dirname) abort
  if strpart(a:dirname, 0, stridx(a:dirname, "://")) != ""
    return 'None'
  endif
  let l:settingsDir = a:dirname . "/" . g:virk_dirname
  if isdirectory(l:settingsDir)
    cd `=a:dirname`
    return l:settingsDir
  endif
  let l:parentDir = strpart(a:dirname, 0, strridx(a:dirname, "/"))
  if isdirectory(l:parentDir)
    return s:findSettingsDir(l:parentDir)
  endif
endfunction

function! VSSourceSettings()
  if ! exists("b:virk_buf_sourced")
    let b:virk_buf_sourced = 0
  endif
  if b:virk_buf_sourced == 0
    let b:coc_root_patterns = g:virk_dirname
    let l:fn = s:virk_settings_dir . '/' . g:virk_settings_filename
    if filereadable(l:fn)
      exec "source " . l:fn
      let b:virk_buf_sourced = 1
    endif
  endif
endfunction

function! VSSourceSession()
  let l:fn = s:virk_settings_dir . '/' . g:virk_session_filename
  if filereadable(l:fn)
    exec "source " . l:fn
  endif
endfunction

function! VSSetTags()
  let l:fn = s:virk_settings_dir . '/' . g:virk_tags_filename
  if filereadable(l:fn)
    exec "set tags=" . l:fn
  endif
endfunction

function! VSMakeSession()
  exec "mksession " . s:virk_settings_dir . "/" g:virk_session_filename
endfunction

function! VSProjectSettings(fname) abort
  let l:curDir = fnamemodify(a:fname, ":p:h")
  let s:virk_settings_dir = s:findSettingsDir(l:curDir)
  if s:virk_settings_dir == 'None'
    echom "[VirkSpaces] No settings directory found"
    return
  endif
endfunction

function! VSCreateProjectDir() abort
  let l:projDir = input("Dir: ", expand("%:p:h"))
  if ! isdirectory(l:projDir)
    if ! s:yesno("\"" . l:projDir . "\" is not a directory, make dirs?")
      return
    endif
  else
    if ! s:yesno("\"" . l:projDir . "/" . g:virk_dirname . "\" exists, overwrite?")
      return
    else
      if delete(fnameescape(l:projDir . "/" . g:virk_dirname))
        echom "[ProjectVim] \"" . l:projDir . "/" . g:virk_dirname . " could not be deleted, eciting..."
        return
      endif
    endif
  endif
  call mkdir(fnameescape(l:projDir . "/" . g:virk_dirname), "p")
  echom "[ProjectVim] Project directory created"
  if s:yesno("CD to project directory parent?")
    return
    cd `=l:projDir`
  endif
endfunction
command! -nargs=0 VSCreateProjectDir call VSCreateProjectDir()

augroup project-vim
  autocmd!
  autocmd VimEnter * if g:virk_enable 
        \ |   call VSProjectSettings(expand("%:p:h")) 
        \ | endif
  autocmd VimEnter * if g:virk_enable
        \ |   call VSSourceSession()
        \ |   call VSSetTags()
        \ | endif
  autocmd VimEnter,BufWinEnter,BufEnter * if g:virk_enable
        \ |   call VSSourceSettings()
        \ | endif
augroup END


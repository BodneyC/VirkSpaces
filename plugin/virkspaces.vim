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
let g:virk_session_filename = get(g:, "virk_session_filename", "session.vim")
let g:virk_tags_filename = get(g:, "virk_tags_filename", "tags")
let g:virk_coc_root_enable = get(g:, "virk_coc_root_enable", 1)
let g:virk_source_session = get(g:, "virk_source_session", 1)
let g:virk_make_session_on_leave = get(g:, "virk_make_session_on_leave", 1)

set ssop+=resize,winpos,winsize,blank,folds

let s:virk_settings_dir = ''

function! s:findSettingsDir(dirname) abort
  if strpart(a:dirname, 0, stridx(a:dirname, "://")) != ""
    return 'None'
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
  let l:fn = s:virk_settings_dir . '/' . g:virk_settings_filename
  if filereadable(l:fn) && buflisted(bufnr('%'))
    exec "source " . l:fn
  endif
endfunction

function! VSSetSession()
  let l:fn = s:virk_settings_dir . '/' . g:virk_session_filename
  if ! filereadable(l:fn)
    return
  endif
  exec "source " . l:fn
  let l:fn = g:virk_dirname . '/' . g:virk_session_filename
  if bufnr(l:fn)
    " exec "bd " . l:fn
  endif
endfunction

function! VSSetTags()
  let l:fn = s:virk_settings_dir . '/' . g:virk_tags_filename
  if filereadable(l:fn)
    exec "set tags=" . l:fn
  endif
endfunction

function! VSSetPWD()
  cd `=s:virk_settings_dir . "/.."`
endfunction

function! VSSetVirkDir(fname) abort
  let l:curDir = fnamemodify(a:fname, ":p:h")
  let s:virk_settings_dir = s:findSettingsDir(l:curDir)
  if s:virk_settings_dir == 'None'
    echom "[VirkSpaces] No settings directory found"
    return
  endif
  echom "[VirkSpaces] Settings directory found: " . s:virk_settings_dir
endfunction

function! VSLoadVirkSpace()
  call VSSetVirkDir(expand("%:p:h")) 
  if s:virk_settings_dir != "0"
    call VSSetPWD()
    call VSSetTags()
    if g:virk_source_session
      call VSSetSession()
    endif
    call VSSetSettings()
  endif
endfunction

" Management Functions

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
        echom "[VirkSpaces] \"" . l:projDir . "/" . g:virk_dirname . " could not be deleted, exiting..."
        return
      endif
    endif
  endif
  call mkdir(fnameescape(l:projDir . "/" . g:virk_dirname), "p")
  echom "[VirkSpaces] Project directory created"
  if s:yesno("CD to project directory parent?")
    return
    cd `=l:projDir`
  endif
endfunction
command! -nargs=0 VSCreateProjectDir call VSCreateProjectDir()

function! VSMakeSession()
  echom s:virk_settings_dir . "/" . g:virk_session_filename
  exec "mksession! " . s:virk_settings_dir . "/" . g:virk_session_filename
endfunction

function! VSMakeSessionOnLeave()
  if exists('t:NERDTreeBufName') && bufwinnr(t:NERDTreeBufName) != -1
    tabdo NERDTreeClose
  endif
  if bufwinnr("__vista__") != -1
    tabdo Vista!
  endif
  call VSMakeSession()
endfunction

" Helpers

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

" Automation

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

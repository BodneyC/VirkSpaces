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
let s:default_ssop = "blank,buffers,curdir,folds,help,tabpages,winsize"

let g:virk_enabled               = get(g:, "virk_enabled", 1)
let g:virk_ignore_enable         = get(g:, "virk_ignore_enable", 1)
let g:virk_ignore_filename       = get(g:, "virk_ignore_filename", ".virkignore")
let g:virk_dirnames              = get(g:, "virk_dirnames", [".virkspace", '.git', '.vim'])
let g:virk_cd_on_create          = get(g:, "virk_cd_on_create", 1)
let g:virk_settings_filename     = get(g:, "virk_settings_filename", "virkspace.vim")
let g:virk_vonce_filename        = get(g:, "virk_vonce_filename", "virkvonce.vim")
let g:virk_session_filename      = get(g:, "virk_session_filename", "session.vim")
let g:virk_source_session        = get(g:, "virk_source_session", 1)
let g:virk_make_session_on_leave = get(g:, "virk_make_session_on_leave", 1)
let g:virk_update_on_leave       = get(g:, "virk_update_on_leave", 1)
let g:virk_ssop                  = get(g:, "virk_ssop", s:default_ssop)
let g:virk_close_regexes         = get(g:, "virk_close_regexes", ["^$", "FAR.*", "MERGE MSG"])
let g:virk_move_virk_space       = get(g:, "virk_move_virk_space", 0)
let g:virk_close_terminals       = get(g:, "virk_close_terminals", 0)
let g:virk_close_by_ft           = get(g:, "virk_close_by_ft", {})

let g:virk_project_dir           = ""

" ------------------ Commands ------------------

command! -nargs=0 VirkSourceVirkSettings call virkspaces#source_settings()
command! -nargs=0 VirkSourceSession      call virkspaces#source_session()
command! -nargs=0 VirkSourceVonce        call virkspaces#source_vonce()
command! -nargs=0 VirkFindVirkDir        call virkspaces#find_virk_dir()
command! -nargs=0 VirkChangePWD          call virkspaces#change_pwd()
command! -nargs=0 VirkCleanVirkSpace     call virkspaces#clean_virkspace()
command! -nargs=0 VirkCreateVirkSpace    call virkspaces#create_virkspace()
command! -nargs=0 VirkMakeVonceFile      call virkspaces#make_vonce_file()
command! -nargs=0 VirkMakeVirkFile       call virkspaces#make_virk_file()
command! -nargs=0 VirkMakeSession        call virkspaces#make_session()
command! -nargs=1 VirkVonceWrite         call virkspaces#vonce_write(<f-args>)
command! -nargs=0 VirkUpdateOnLeave      call virkspaces#update()
command! -nargs=0 VirkInfo               call virkspaces#info()
command! -nargs=0 VirkSourceAllSettings  call virkspaces#source_all()
command! -nargs=0 VirkLoadVirkSpace      call virkspaces#load()
command! -nargs=1 VirkCloseBuffers       call virkspaces#close_buffers(<f-args>)
command! -nargs=0 VirkResetCWD           call virkspaces#reset_cwd()
command! -nargs=0 VirkDisable            let g:virk_enabled = v:false

" ------------- Automation AuGroups -------------

augroup virk-spaces
  autocmd!
  autocmd VimEnter * nested call virkspaces#load()
  autocmd VimLeave *        call virkspaces#update()
  autocmd BufEnter *        call virkspaces#source_settings()
  autocmd BufEnter *        call virkspaces#close_known()
augroup END

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
let g:virk_tags_enable           = get(g:, "virk_tags_enable", 1)
let g:virk_tags_filename         = get(g:, "virk_tags_filename", "tags")
let g:virk_tags_bin              = get(g:, "virk_tags_bin", "ctags")
let g:virk_tags_flags            = get(g:, "virk_tags_flags", "-Rf")
let g:virk_tags_excludes         = get(g:, "virk_tags_excludes", g:virk_dirnames)
let g:virk_make_session_on_leave = get(g:, "virk_make_session_on_leave", 1)
let g:virk_update_on_leave       = get(g:, "virk_update_on_leave", 1)
let g:virk_ssop                  = get(g:, "virk_ssop", s:default_ssop)
let g:virk_close_regexes         = get(g:, "virk_close_regexes", ["^$", "FAR.*", "MERGE MSG"])
let g:virk_move_virk_space       = get(g:, "virk_move_virk_space", 0)
let g:virk_close_terminals       = get(g:, "virk_close_terminals", 0)

let g:virk_root_dir              = ""

" ------------------ Commands ------------------

command! -nargs=0 VirkSourceVirkSettings call virkspaces#source_virk_settings()
command! -nargs=0 VirkSourceSession      call virkspaces#source_session()
command! -nargs=0 VirkSourceVonce        call virkspaces#source_vonce()
command! -nargs=0 VirkFindVirkDir        call virkspaces#find_virk_dir()
command! -nargs=0 VirkChangePWD          call virkspaces#change_pwd()
command! -nargs=0 VirkCleanVirkSpace     call virkspaces#clean_virkspace()
command! -nargs=0 VirkCreateVirkSpace    call virkspaces#create_virkspace()
command! -nargs=0 VirkMakeTagsFile       call virkspaces#make_tags_file()
command! -nargs=0 VirkMakeVonceFile      call virkspaces#make_vonce_file()
command! -nargs=0 VirkMakeVirkFile       call virkspaces#make_virk_file()
command! -nargs=0 VirkMakeSession        call virkspaces#make_session()
command! -nargs=1 VirkVonceWrite         call virkspaces#vonce_write(<f-args>)
command! -nargs=0 VirkUpdateOnLeave      call virkspaces#update_on_leave()
command! -nargs=0 VirkInfo               call virkspaces#info()
command! -nargs=0 VirkSourceAllSettings  call virkspaces#source_all_settings()
command! -nargs=0 VirkLoadVirkSpace      call virkspaces#load_virkspace()
command! -nargs=0 VirkCocCreate          call virkspaces#coc_create()
command! -nargs=1 VirkCloseBuffers       call virkspaces#close_buffers(<f-args>)
command! -nargs=0 VirkResetCWD           call virkspaces#reset_cwd()
command! -nargs=0 VirkDisable            let g:virk_enabled = v:false


" ------------- Automation AuGroups -------------

augroup virk-spaces
  autocmd!
  autocmd VimEnter * nested call virkspaces#load_virkspace()
  autocmd VimLeave *        call virkspaces#update_on_leave()
  autocmd BufEnter *        call virkspaces#source_virk_settings()
  autocmd BufEnter *        call virkspaces#close_known_if_last()
augroup END

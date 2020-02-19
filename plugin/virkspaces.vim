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

let g:virk_enable                = get(g:, "virk_enable", 1)
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

let g:virk_root_dir              = ""

" ------------------ Commands ------------------

command! -nargs=0 VirkSourceVirkSettings call virkspaces#sourcevirksettings()
command! -nargs=0 VirkSourceSession      call virkspaces#sourcesession()
command! -nargs=0 VirkSourceVonce        call virkspaces#sourcevonce()
command! -nargs=0 VirkFindVirkDir        call virkspaces#findvirkdir()
command! -nargs=0 VirkChangePWD          call virkspaces#changepwd()
command! -nargs=0 VirkCleanVirkSpace     call virkspaces#cleanvirkspace()
command! -nargs=0 VirkCreateVirkSpace    call virkspaces#createvirkspace()
command! -nargs=0 VirkMakeTagsFile       call virkspaces#maketagsfile()
command! -nargs=0 VirkMakeVonceFile      call virkspaces#makevoncefile()
command! -nargs=0 VirkMakeVirkFile       call virkspaces#makevirkfile()
command! -nargs=0 VirkMakeSession        call virkspaces#makesession()
command! -nargs=1 VirkVonceWrite         call virkspaces#voncewrite(<f-args>)
command! -nargs=0 VirkUpdateOnLeave      call virkspaces#updateonleave()
command! -nargs=0 VirkInfo               call virkspaces#info()
command! -nargs=0 VirkSourceAllSettings  call virkspaces#sourceallsettings()
command! -nargs=0 VirkLoadVirkSpace      call virkspaces#loadvirkspace()
command! -nargs=0 VirkCocCreate          call virkspaces#coccreate()


" ------------- Automation AuGroups -------------

augroup virk-spaces
  autocmd!
  autocmd VimEnter * nested call virkspaces#loadvirkspace()
  autocmd BufEnter * call virkspaces#sourcevirksettings()
  autocmd VimLeave * call virkspaces#updateonleave()
augroup END

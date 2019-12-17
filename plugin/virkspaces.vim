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
let g:virk_coc_filename          = get(g:, "virk_coc_filename", "coc-settings.json")
let g:virk_coc_settings_enable   = get(g:, "virk_coc_settings_enable", 1)
let g:virk_source_session        = get(g:, "virk_source_session", 1)
let g:virk_tags_enable           = get(g:, "virk_tags_enable", 1)
let g:virk_tags_filename         = get(g:, "virk_tags_filename", "tags")
let g:virk_tags_bin              = get(g:, "virk_tags_bin", "ctags")
let g:virk_tags_flags            = get(g:, "virk_tags_flags", "-Rf")
let g:virk_tags_excludes         = get(g:, "virk_tags_excludes", [g:virk_dirname])
let g:virk_make_session_on_leave = get(g:, "virk_make_session_on_leave", 1)
let g:virk_update_on_leave       = get(g:, "virk_update_on_leave", 1)

let g:virk_root_dir              = ""

" ------------------ Commands ------------------

command! -nargs=0 VirkSourceVirkSettings call virkspaces#virksourcevirksettings()
command! -nargs=0 VirkSourceSession      call virkspaces#virksourcesession()
command! -nargs=0 VirkSourceVonce        call virkspaces#virksourcevonce()
command! -nargs=0 VirkCoCSettings        call virkspaces#virkcocsettings()
command! -nargs=0 VirkFindVirkDir        call virkspaces#virkfindvirkdir()
command! -nargs=0 VirkChangePWD          call virkspaces#virkchangepwd()
command! -nargs=0 VirkCleanVirkSpace     call virkspaces#virkcleanvirkspace()
command! -nargs=0 VirkCreateVirkSpace    call virkspaces#virkcreatevirkspace()
command! -nargs=0 VirkMakeTagsFile       call virkspaces#virkmaketagsfile()
command! -nargs=0 VirkMakeVonceFile      call virkspaces#virkmakevoncefile()
command! -nargs=0 VirkMakeVirkFile       call virkspaces#virkmakevirkfile()
command! -nargs=0 VirkMakeSession        call virkspaces#virkmakesession()
command! -nargs=1 VirkVonceWrite         call virkspaces#virkvoncewrite(<f-args>)
command! -nargs=0 VirkUpdateOnLeave      call virkspaces#virkupdateonleave()
command! -nargs=0 VirkInfo               call virkspaces#virkinfo()
command! -nargs=0 VirkSourceAllSettings  call virkspaces#virksourceallsettings()
command! -nargs=0 VirkLoadVirkSpace      call virkspaces#virkloadvirkspace()
command! -nargs=0 VirkCocCreate          call virkspaces#virkcoccreate()


" ------------- Automation AuGroups -------------

augroup virk-spaces
  autocmd!
  autocmd VimEnter * nested if g:virk_enable
        \ |   call virkspaces#vsloadvirkspace()
        \ | endif
  autocmd BufEnter * if g:virk_enable
        \ |   call virkspaces#vssourcevirksettings()
        \ | endif
  autocmd VimLeave * if g:virk_update_on_leave
        \ |   call virkspaces#vsupdateonleave()
        \ | endif
augroup END

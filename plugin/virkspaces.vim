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

command! -nargs=0 VSSourceVirkSettings call virkspaces#vssourcevirksettings()
command! -nargs=0 VSSourceSession      call virkspaces#vssourcesession()
command! -nargs=0 VSSourceVonce        call virkspaces#vssourcevonce()
command! -nargs=0 VSCoCSettings        call virkspaces#vscocsettings()
command! -nargs=0 VSFindVirkDir        call virkspaces#vsfindvirkdir()
command! -nargs=0 VSChangePWD          call virkspaces#vschangepwd()
command! -nargs=0 VSCleanVirkSpace     call virkspaces#vscleanvirkspace()
command! -nargs=0 VSCreateVirkSpace    call virkspaces#vscreatevirkspace()
command! -nargs=0 VSMakeTagsFile       call virkspaces#vsmaketagsfile()
command! -nargs=0 VSMakeVonceFile      call virkspaces#vsmakevoncefile()
command! -nargs=0 VSMakeVirkFile       call virkspaces#vsmakevirkfile()
command! -nargs=0 VSMakeSession        call virkspaces#vsmakesession()
command! -nargs=1 VSVonceWrite         call virkspaces#vsvoncewrite(<f-args>)
command! -nargs=0 VSUpdateOnLeave      call virkspaces#vsupdateonleave()
command! -nargs=0 VSInfo               call virkspaces#vsinfo()
command! -nargs=0 VSSourceAllSettings  call virkspaces#vssourceallsettings()
command! -nargs=0 VSLoadVirkSpace      call virkspaces#vsloadvirkspace()
command! -nargs=0 VirkCocCreate        call virkspaces#vscoccreate()


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

VirkSpaces
==========

Fairly minimal workspace setup for Vims of all kinds.

More can be read/seen about this plugin [here](https://benjc.me/blog/2019/06/20/virk-spaces.html).

### Installation

Either add to rtp:

    let &runtimepath.=",/path/to/virkspaces/root/dir/"

Or install with your favourite plugin manager:

    Plug 'BodneyC/VirkSpaces', { 'branch': 'stable' }

### Usage

VirkSpaces will only source project sessions if no argument is given to `*vim`, this is to prevent calling a non-virkspace file from a virkspace directory and being dumped into the wrong space.

Everything you need to know is documented in the help file (`./doc/virkspaces.txt`).

    :h virkspaces

Generally, at the moment, currently, there are vimrc-like settings (`g:virk_settings_filename`), vimrc-llike settings that should only be sourced once (as opposed to `BufEnter`) (`g:virk_vonce_filename`), [CoC](https://github.com/neoclide/coc.nvim) local settings (a bit of a dodgy setup but she works), tags settings (`g:virk_tags_filename`), and sessions (`g:virk_sessions_filename`).

But, as is written above, check the help file for the rest.

**NOTE**: It should be noted that the session file will only be sourced if `argc()` is of length, zero; this allows the user to source local settings but get straight to the file selected.

### Disclaimer

Much of this project is set around my existing `vimrc` (well, `init.vim`); so there may be some inconsistencies, they will either become apparent through usage or someone may make me aware. Apologies if this happens.

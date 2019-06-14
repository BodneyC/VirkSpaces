VirkSpaces
==========

Fairly minimal workspace setup for Vims of all kinds.

### Installation

Either add to rtp:

    let &runtimepath.=",/path/to/virkspaces/root/dir/"

Or install with your favourite plugin manager:

    Plug 'BodneyC/VirkSpaces', { 'branch': 'stable' }

### Usage

Everything you need to knoow is documented in the help file (`./doc/virkspaces.txt`).

    :h virkspaces

**NOTE**: It should be noted that the session file will only be sourced if `argc()` is of length, zero; this allows the user to source local setting but get straight to the file selected.

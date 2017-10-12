vimstuff
========

This repository contains [my][me] vimfiles, plugins, etc.
It can be cloned directly into a system's `~/.vim` folder.

> If that folder is non-empty, git will prevent you from
> cloning into it, so you'll have to do the
> init-new-repo-fetch-then-reset-hard shenanigans.

#### No Shenanigans

    $ mkdir -p ~/.vim
    $ cd ~/.vim
    $ git clone <this_repo> .

#### With Shenanigans

    $ mkdir -p ~/.vim
    $ cd ~/.vim
    $ git init
    $ git remote add origin <this_repo>
    $ git fetch
    $ git reset --hard origin/master
    // add or ignore the original files

Windows
-------

On windoze, the gvim installation typically expects a
folder `vimfiles` instead of `.vim`.  The `vimrc` in this
repo changes that location to `.vim` for you, but you must
still source that `vimrc` because the installation still
expects to use `~/.vimrc`. Add this line to the
top of that file:

    source ~/vimrc

where `~` needs to expand to the Windows user directory,
typically found at `%USERPROFILE%`




[me]: http://github.com/radford-nguyen


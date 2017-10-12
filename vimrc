" radford-nguyen's vimrc file.  Modified from:
"
" Maintainer:  Bram Moolenaar <Bram@vim.org>
" Last change:  2000 Mar 29
"
" To use it, copy it to
"     for Unix and OS/2:  ~/.vimrc
"        for Amiga:  s:.vimrc
"  for MS-DOS and Win32:  $VIM\_vimrc
"      for OpenVMS:  sys$login:.vimrc

" Use Vim settings, rather then Vi settings (much better!).
" This must be first, because it changes other options as a side effect.

if has('win32')
  " use `.vim` instead of `vimfiles`
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

set nocompatible

colorscheme slate

set nocindent
set bs=2    " allow backspacing over everything in insert mode
set showmatch " always set showmatch on
set tabstop=2
set viminfo='20,\"50  " read/write a .viminfo file, don't store more
                      " than 50 lines of registers
set history=50    " keep 50 lines of command line history
set ruler    " show the cursor position all the time

set backup " keep backups

" For Win32 GUI: remove 't' flag from 'guioptions': no tearoff menu entries
" let &guioptions = substitute(&guioptions, "t", "", "g")


" Make p in Visual mode replace the selected text with the "" register.
vnoremap p <Esc>:let current_reg = @"<CR>gvdi<C-R>=current_reg<CR><Esc>

" Switch syntax highlighting on, when the terminal has colors
" Also switch on highlighting the last used search pattern.
if &t_Co > 2 || has("gui_running")
  syntax on
  set hlsearch
endif


function MyTabs(width)
  let &ts = a:width
  let &sw = a:width
  set et nowrap
  return "vim:ts=" . a:width . ":sw=" . a:width . ":et"
endfunction

function MyClojure()
  call MyTabs(2)
	colorscheme slate
  setfiletype clojure
  map <F12> <ESC>0i;;<ESC>j
endfunction

function MyGroovy()
  call MyTabs(4)
	colorscheme slate
  map <F12> <ESC>0i//<ESC>j
endfunction

function MyGradle()
  setfiletype groovy
  call MyGroovy()
endfunction

function MyProtobuf()
  call MyTabs(4)
	colorscheme slate
  set ts=3 sw=3 et
  setfiletype cpp
endfunction

function MyDefault()
  call MyTabs(2)
  set hlsearch is backspace=indent,eol,start
	colorscheme slate
endfunction

function MyJava()
  call MyTabs(4)
  map <F12> <ESC>0i//<ESC>j
  map <F4> <ESC>O<ESC>i//-----------------------------------------------------------------------------<ESC>
  let java_allow_cpp_keywords=0
	colorscheme slate
endfunction

function MyJavascript()
  call MyTabs(2)
	colorscheme slate
  set syntax=javascript
  let java_allow_cpp_keywords=0
endfunction

function MyPython()
  call MyTabs(2)
  map <F12> <ESC>0i#<ESC>j
  map <F4> <ESC>O<ESC>i#==============================================================================<ESC>
	colorscheme slate
endfunction

function MyXML()
  call MyTabs(2)
	colorscheme slate
endfunction

function MyVimrc()
  call MyTabs(2)
endfunction

" Only do this part when compiled with support for autocommands.
if has("autocmd")

	" Autocommands
	"-----------------------------------------------
	"autocmd BufEnter *.* setlocal indentexpr= 
	autocmd BufNewFile,BufEnter .vimrc call MyVimrc()
	autocmd BufNewFile,BufEnter *.xml call MyXML()
	autocmd BufNewFile,BufEnter *.java call MyJava()
	autocmd BufNewFile,BufEnter *.js call MyJavascript()
	autocmd BufNewFile,BufEnter *.py call MyPython()
	autocmd BufNewFile,BufEnter *.groovy call MyGroovy()
	autocmd BufNewFile,BufEnter *.gradle call MyGradle()
	autocmd BufNewFile,BufEnter *.proto call MyProtobuf()

  " In text files, always limit the width of text to 78 characters
  autocmd BufRead *.* set tw=78
  
  augroup cprog
    " Remove all cprog autocommands
    au!
  
    " When starting to edit a file:
    "   For C and C++ files set formatting of comments and set C-indenting on.
    "   For other files switch it off.
    "   Don't change the order, it's important that the line with * comes first.
    autocmd FileType *      set formatoptions=tcql nocindent comments&
    autocmd FileType c,cpp  set formatoptions=croql nocindent comments=sr:/*,mb:*,el:*/,://
  augroup END
 
  augroup gzip
    " Remove all gzip autocommands
    au!
    
    " Enable editing of gzipped files
    " set binary mode before reading the file
    autocmd BufReadPre,FileReadPre  *.gz,*.bz2 set bin
    autocmd BufReadPost,FileReadPost  *.gz call GZIP_read("gunzip")
    autocmd BufReadPost,FileReadPost  *.bz2 call GZIP_read("bunzip2")
    autocmd BufWritePost,FileWritePost  *.gz call GZIP_write("gzip")
    autocmd BufWritePost,FileWritePost  *.bz2 call GZIP_write("bzip2")
    autocmd FileAppendPre      *.gz call GZIP_appre("gunzip")
    autocmd FileAppendPre      *.bz2 call GZIP_appre("bunzip2")
    autocmd FileAppendPost    *.gz call GZIP_write("gzip")
    autocmd FileAppendPost    *.bz2 call GZIP_write("bzip2")
    
    " After reading compressed file: Uncompress text in buffer with "cmd"
    fun! GZIP_read(cmd)
      " set 'cmdheight' to two, to avoid the hit-return prompt
      let ch_save = &ch
      set ch=3
      " when filtering the whole buffer, it will become empty
      let empty = line("'[") == 1 && line("']") == line("$")
      let tmp = tempname()
      let tmpe = tmp . "." . expand("<afile>:e")
      " write the just read lines to a temp file "'[,']w tmp.gz"
      execute "'[,']w " . tmpe
      " uncompress the temp file "!gunzip tmp.gz"
      execute "!" . a:cmd . " " . tmpe
      " delete the compressed lines
      '[,']d
      " read in the uncompressed lines "'[-1r tmp"
      set nobin
      execute "'[-1r " . tmp
      " if buffer became empty, delete trailing blank line
      if empty
        normal Gdd''
      endif
      " delete the temp file
      call delete(tmp)
      let &ch = ch_save
      " When uncompressed the whole buffer, do autocommands
      if empty
        execute ":doautocmd BufReadPost " . expand("%:r")
      endif
    endfun
    
    " After writing compressed file: Compress written file with "cmd"
    fun! GZIP_write(cmd)
      if rename(expand("<afile>"), expand("<afile>:r")) == 0
        execute "!" . a:cmd . " <afile>:r"
      endif
    endfun
    
    " Before appending to compressed file: Uncompress file with "cmd"
    fun! GZIP_appre(cmd)
      execute "!" . a:cmd . " <afile>"
      call rename(expand("<afile>:r"), expand("<afile>"))
    endfun
 
  augroup END
 
  " This is disabled, because it changes the jumplist.  Can't use CTRL-O to go
  " back to positions in previous files more than once.
  if 0
    " When editing a file, always jump to the last cursor position.
    " This must be after the uncompress commands.
    autocmd BufReadPost * if line("'\"") && line("'\"") <= line("$") | exe "normal `\"" | endif
  endif

endif " has("autocmd")

abbreviate #l //-----------------------------------------------------------------------------

function MyDiff()
  let opt = '-a --binary '
  if &diffopt =~ 'icase' | let opt = opt . '-i ' | endif
  if &diffopt =~ 'iwhite' | let opt = opt . '-b ' | endif
  let arg1 = v:fname_in
  if arg1 =~ ' ' | let arg1 = '"' . arg1 . '"' | endif
  let arg2 = v:fname_new
  if arg2 =~ ' ' | let arg2 = '"' . arg2 . '"' | endif
  let arg3 = v:fname_out
  if arg3 =~ ' ' | let arg3 = '"' . arg3 . '"' | endif
  if has('win32')
    if &sh =~ '\<cmd'
      silent execute '!""C:\Program Files\Vim\vim64\diff" ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3 . '"'
    else
      silent execute '!C:\Program" Files\Vim\vim64\diff" ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
    endif
  else
    silent execute '!diff ' . opt . arg1 . ' ' . arg2 . ' > ' . arg3
  endif
endfunction


call MyDefault()

"set formatoptions=croql "default
set formatoptions=ql "no auto start new line


inoremap jj <ESC>
let mapleader = ","

nnoremap / /\v
vnoremap / /\v
set incsearch

" Have the cursor briefly flash to a matching brace when one is inserted
set showmatch

" Switch on highlighting the last used search pattern.
set hlsearch

" clear highlighted matches
nnoremap <leader><space> :noh<cr>

nnoremap <tab> %
vnoremap <tab> %
set textwidth=78

" strip trailing whitespace in file
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>


"set formatoptions=croql "default
set formatoptions=ql "no auto start new line

execute pathogen#infect()

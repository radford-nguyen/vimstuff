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

if has('win32')
  " use `.vim` instead of `vimfiles`
  set runtimepath=$HOME/.vim,$VIM/vimfiles,$VIMRUNTIME,$VIM/vimfiles/after,$HOME/.vim/after
endif

" Technically since this is a user vimrc then this option
" is already set, but better safe than sorry
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
  setfiletype cpp
endfunction

function MyThrift()
  call MyTabs(2)
  colorscheme slate
  setfiletype thrift
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
  autocmd BufNewFile,BufEnter *.thrift call MyThrift()

  " In text files, always limit the width of text
  autocmd BufRead *.* set tw=100
  
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

" format json
nnoremap <leader>j :'<,'>!python -m json.tool<cr>
vnoremap <leader>j :'<,'>!python -m json.tool<cr>

nnoremap <tab> %
vnoremap <tab> %
set textwidth=100

" strip trailing whitespace in file
nnoremap <leader>W :%s/\s\+$//<cr>:let @/=''<CR>

nnoremap <leader>f :let @" = expand("%")<CR>

" word wrapping
nnoremap <leader>q ciw'<c-r>"'<esc>
nnoremap <leader>Q ciw"<c-r>""<esc>
nnoremap <leader>p ciw(<c-r>")<esc>

"set formatoptions=croql "default
set formatoptions=ql "no auto start new line

nnoremap <leader><b> :buffers<cr>

" ex command for toggling hex mode - define mapping if desired
command -bar Hexmode call ToggleHex()

" helper function to toggle hex mode
function ToggleHex()
  " hex mode should be considered a read-only operation
  " save values for modified and read-only for restoration later,
  " and clear the read-only flag for now
  let l:modified=&mod
  let l:oldreadonly=&readonly
  let &readonly=0
  let l:oldmodifiable=&modifiable
  let &modifiable=1
  if !exists("b:editHex") || !b:editHex
    " save old options
    let b:oldft=&ft
    let b:oldbin=&bin
    " set new options
    setlocal binary " make sure it overrides any textwidth, etc.
    silent :e " this will reload the file without trickeries 
              "(DOS line endings will be shown entirely )
    let &ft="xxd"
    " set status
    let b:editHex=1
    " switch to hex editor
    %!xxd
  else
    " restore old options
    let &ft=b:oldft
    if !b:oldbin
      setlocal nobinary
    endif
    " set status
    let b:editHex=0
    " return to normal editing
    %!xxd -r
  endif
  " restore values for modified and read only state
  let &mod=l:modified
  let &readonly=l:oldreadonly
  let &modifiable=l:oldmodifiable
endfunction


" set cursor types:
" 1 or 0 -> blinking block
" 2 -> solid block
" 3 -> blinking underscore
" 4 -> solid underscore
" Recent versions of xterm (282 or above) also support
" 5 -> blinking vertical bar
" 6 -> solid vertical bar
if &term =~ '^xterm'
  " use | in insert mode
  let &t_SI .= "\<Esc>[6 q"

  " block otherwise
  let &t_EI .= "\<Esc>[2 q"

  " reset cursor on exit
  " (codes same as above, e.g. 4 q -> 34 q)
  autocmd VimLeave * silent !echo -ne "\x1b[\x33 q"
endif

execute pathogen#infect()

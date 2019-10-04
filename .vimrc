"set rtp+=~/.vim/bundle/vundle/
"call vundle#rc()

" let Vundle manage Vundle
" Install Vundle first, using
"     git clone https://github.com/gmarik/vundle.git ~/.vim/bundle/vundle
"Bundle 'gmarik/vundle'

" Bundles I use
" Use command `:BundleInstall` to install these on a fresh installation.
"Bundle 'tpope/vim-sensible'
"Bundle 'scrooloose/nerdtree'
"Bundle 'tpope/vim-fugitive'
"Bundle 'nelstrom/vim-markdown-folding'


set tabstop=4
set ignorecase
syntax on

" Disabling line numbers; too painful when one has to copy stuff from terminal
" and paste it elsewhere.
"set number

set smarttab
set shiftwidth=4
set whichwrap+=h,l,<,>

set modeline
set modelines=5

" In normal mode, map `\s` to save file, iff it's changed since last save
nnoremap \s :update<cr>

" Enable recursive lookup for commands like :find and :tabfind
let &path = &path . ',**,'

" From [url_tab_pages]. Map Ctrl+{Left|Right}arrow to switch between
" consecutive tabs, and Alt+{Left|Right}arrow to move current tab around. And
" F8 to toggle tab-bar, loaded with all current buffers. Open tabs by default.
"
" [url_tab_pages] http://vim.wikia.com/wiki/Using_tab_pages#Switching_to_another_buffer
nnoremap <C-Left> :tabprevious<CR>
nnoremap <C-Right> :tabnext<CR>
nnoremap <silent> <A-Left> :execute 'silent! tabmove ' . (tabpagenr()-2)<CR>
nnoremap <silent> <A-Right> :execute 'silent! tabmove ' . tabpagenr()<CR>
let notabs = 1
nnoremap <silent> <F8> :let notabs=!notabs<Bar>:if notabs<Bar>:tabo<Bar>:else<Bar>:tab ball<Bar>:tabn<Bar>:endif<CR>
silent! tab ball


" Enable mouse (works even in console/non-GUI mode (specifically, it works in
" xterm). Double-clicks/selection-with-mouse will cause Vim's 'visual' selection
" feature to kick in. To use the terminal's selection mode (so that you can
" copy-paste the selection), press the 'shift' key when double-clicking or
" selecting text with mouse.
"
" Disabling mouse for now, since I don't use it much and it interferes with the
" terminal level selection and copy.
"set mouse=a

" Based on Wolph's response from [url_save_vim_session].
"
" And as Wolph acknowledges in the post, 'syntax on' is necessary here, to get
" syntax highlighting even if .vimrc has the same command.
"
" [url_save_vim_session] http://stackoverflow.com/questions/5142099/auto-save-vim-session-on-quit-and-auto-reload-session-on-start
fu! SaveSess()
    execute 'mksession! ' . getcwd() . '/.session.vim'
endfunction

fu! RestoreSess()
if filereadable(getcwd() . '/.session.vim')
    execute 'so ' . getcwd() . '/.session.vim'
    if bufexists(1)
        for l in range(1, bufnr('$'))
            if bufwinnr(l) == -1
                exec 'sbuffer ' . l
            endif
        endfor
    endif
endif
syntax on
endfunction

autocmd VimLeave * call SaveSess()

" Restore the previous session only if there are no files being opened
" explicitly.
:if empty(argv())
	autocmd VimEnter * call RestoreSess()
:endif

" The Netrw module creates a history-file, which I am not interested in.
au VimLeave * if filereadable($HOME . "/.vim/.netrwhist")|call delete($HOME . "/.vim/.netrwhist")|endif

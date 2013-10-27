runtime bundle/vim-pathogen/autoload/pathogen.vim
execute pathogen#infect()

set tabstop=4
set ignorecase
syntax on

set number

set smarttab
set shiftwidth=4
set whichwrap+=h,l,<,>

set modeline

" Map Ctrl-S to save the file in edit and normal modes. Note that you'll need
" to configure the shell to somehow pass the Ctrl-S seqience to Vim; usually
" the shells use Ctrl-S to turn off flow-control. In Bash, you can use the
" command 'stty stop ""' to achieve this.
inoremap <C-s> <esc>:w<cr>a
nnoremap <C-s> :w<cr>

" Enable recursive lookup for commands like :find and :tabfind
let &path = &path . ',**,'

" Enable mouse (works even in console/non-GUI mode (specifically, it works in
" xterm). Double-clicks/selection-with-mouse will cause Vim's 'visual' selection
" feature to kick in. To use the terminal's selection mode (so that you can
" copy-paste the selection), press the 'shift' key when double-clicking or
" selecting text with mouse.
set mouse=a

" Based on Wolph's response from [1]. But disable the 'autocmd's since the
" restore function currently doesn't work nicely. Use it only to save/restore
" sessions manually. Ideally, the auto-restore should abort if there are any
" files being opened from command-line.
"
" For some reason, after an auto-restore, the files are loaded into a split
" window. And as Wolph acknowledges in the post, 'syntax on' is necessary
" here, to get syntax highlighting even if .vimrc has the same command.
"
" [1] http://stackoverflow.com/questions/5142099/auto-save-vim-session-on-quit-and-auto-reload-session-on-start
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

"autocmd VimLeave * call SaveSess()
"autocmd VimEnter * call RestoreSess()

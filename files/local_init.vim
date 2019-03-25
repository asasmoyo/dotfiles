noremap <silent> k gk
noremap <silent> j gj
noremap <silent> 0 g0
noremap <silent> $ g$

" ctrlp
set wildignore+=*/tmp/*,*.so,*.swp,*.zip
let g:ctrlp_custom_ignore = '\v[\/]\.(git|hg|svn)$'
let g:ctrlp_show_hidden = 1
" https://gist.githubusercontent.com/grillermo/3e318d224b1ddcf1bafd/raw/e96f67525cd2df2568c07e472d207f95ccf981fa/.vimrc
set grepprg=ag\ --nogroup\ --nocolor
let g:ctrlp_user_command = 'ag %s --files-with-matches --hidden --nocolor --skip-vcs-ignores --ignore-dir ".git" --filename-pattern ""'
let g:ctrlp_use_caching = 0

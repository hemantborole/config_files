"all forms of tabs as 2 spaces
se ts=2
se st=2
se sw=2
se noexpandtab

"status info
se ruler
se ls=2

"Formatting
se ai
syntax on


se nonu
se wrap
au BufRead,BufNewFile *.hql set filetype=sql

set cursorline

" Tag file
set tags+=./tags;


let g:NERDTreeWinSize=40

map <leader>n NERDTreeToggle

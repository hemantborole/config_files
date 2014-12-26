se ls=2
se si "smart indent
se ic "ignore case when searching
se smartcase  "dont ignore case if there is upper case in pattern
se hls  "highlight search
se is "incremental search, search as you type
se scrolloff=5  "show atleast 5 lines below or above cursor when it reaches either end
se ts=2
se softtabstop=2
se shiftwidth=2
se expandtab
se background=dark
se wildmenu "Displays list of files when you hit a tab
se wildmode=list:longest "Displays the list only if more than one match, else selects the single match
se backupdir=/tmp "dir to store all the .swp files.
se gfn=Monospace\ 8
se hidden "Allow buffer switching without saving
filetype indent on
filetype plugin on "To make matchit work for rb,html,xml etc.
"catch trailing spaces, tabs
set listchars=tab:>-,trail:·,eol:$
nmap <silent> <leader>s :set nolist!<CR>

colorscheme elflord
syntax on

"Using .* instead of just * in Buf commands ensures that the command is not
"executed for empty buffers.

if has("autocmd")
  au BufReadPost .* if line("'\"") > 0 && line("'\"") <= line("$") | exe "normal! g'\"" | endif 
endif

"To store folds uncomment the lines below.
se viewoptions=folds
au BufWinLeave .* mkview
au BufWinEnter .* silent loadview

autocmd BufWritePost *.rb,*.erb,*.yaml,*.yml,*.java,*.cpp,*.h,*.c call UPDATE_TAGS()

"Taglist defaults
nnoremap <silent> <F8> :TlistToggle<CR>
let Tlist_Use_Right_Window=1
let Tlist_Exit_OnlyWindow = 1     " exit if taglist is last window open
let Tlist_Show_One_File = 1       " Only show tags for current buffer
let Tlist_Enable_Fold_Column = 0  " no fold column (only showing one file)
let tlist_sql_settings = 'sql;P:package;t:table'
let tlist_ant_settings = 'ant;p:Project;r:Property;t:Target'

"MiniBufExplorer Navigation
let g:miniBufExplMapWindowNavVim = 1
let g:miniBufExplMapWindowNavArrows = 1 

set tags=$HOME/projects/ds/tags\ $HOME/projects/ar/tags

let g:NeoComplCache_EnableAtStartup = 1   "To set auto completion on at startup
imap <F7> #:NERDTreeToggle

map <F7> #:NERDTreeToggle

imap <F5> #:tab drop %

map <F5> #:tab drop %


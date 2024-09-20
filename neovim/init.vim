" ==========
" Set leader
" ==========
:let mapleader = ","

" ====================
" General Vim settings
" ====================
":autocmd BufEnter * silent! normal! g`"zz      " centers on last known cursor position when entering buffer
:autocmd FileType *      set formatoptions=tcql nocindent comments&
:set autoindent
:set autoread
":set clipboard+=unnamedplus            " ALWAYS use system clipboard for ALL operations
:set clipboard=                         " NEVER use system clipboard; manually set below
:set confirm
:set encoding=utf8
:set expandtab
:set gdefault                           " always use global substitutions, no 'g' in sed
:set hlsearch
:set ignorecase                         " ignorecase in searches; also see smartcase
:set incsearch
:set infercase                          " supposedly better than ignorecase
:set mouse=a
:set nosol
if !exists('g:vscode')
  :set number                             " shows current line number
  :set numberwidth=4                      " set gutter to 4
  :set relativenumber                     " sets relative line numbers
endif
:set shiftround                         " rounds indents to multiple of shiftwidth
:set shiftwidth=2
:set showcmd                            " shows when Leader is pressed
:set smartcase                          " override ignorecase when search pattern has uppercase
:set splitbelow                         " always open h splits below
:set splitright                         " always open v splits on right
:set t_Co=256
:set t_ut=
:set tabstop=2
:set textwidth=120
:set whichwrap+=<,>,h,l,[,]
:set wildmenu                           " use TAB with :e to autosuggest & autocomplete
:set wildmode=full                      " use TAB with :e to autosuggest & autocomplete

" Wrap long lines with an indentation
:set breakindent
:set breakindentopt=shift:2
:set showbreak=\\\\\

" Set font
:set guifont=Meslo_LG_L_DZ_Bold_Nerd_Font_Complete_Mono:h12

" ----------------------------------
" Configure Vim-Polyglot before load
" ----------------------------------
:let g:polyglot_disabled = ['javascript']
:let g:polyglot_disabled = ['jsx']

" =============================
" Install plugins with Vim-Plug
" =============================
" Run :PlugInstall in neovim to install
" Or in background, run: nvim --headless +PlugInstall +qall
:call plug#begin('~/.local/share/nvim/plugged')
if exists('g:vscode')
  Plug 'godlygeek/tabular'              " :Tab cmds to align text (req for vim-markdown)
  Plug 'junegunn/vim-easy-align'        " aligns text with ga commands
  Plug 'Raimondi/delimitMate'           " auto closes quotes, parens, etc
  Plug 'tpope/vim-commentary'           " gc cmds to comment code
  Plug 'tpope/vim-surround'             " ys, cs, ds cmds to surround code
else
  Plug 'dbakker/vim-projectroot'        " guess project root directory
  Plug 'dracula/vim'                    " dracula theme
  Plug 'godlygeek/tabular'              " :Tab cmds to align text (req for vim-markdown)
  Plug 'junegunn/vim-easy-align'        " ga commands to align text
  Plug 'kshenoy/vim-signature'          " m commands for marks
  Plug 'mg979/vim-visual-multi'         " multiple cursors
  Plug 'neoclide/vim-jsx-improve'       " support React jsx
  Plug 'preservim/vim-markdown'         " Markdown support, z cmds for header folding
  Plug 'Raimondi/delimitMate'           " auto closes quotes, parens, etc
  Plug 'ryanoasis/vim-devicons'         " dependency for other plugins
  Plug 'sheerun/vim-polyglot'           " collection of language packs
  Plug 'tpope/vim-commentary'           " gc commands to comment code
  Plug 'tpope/vim-fugitive'             " :G(it) cmds in vim
  Plug 'tpope/vim-sensible'             " sensible defaults
  Plug 'tpope/vim-surround'             " ys, cs, ds cmds to surround code
  Plug 'vim-airline/vim-airline-themes' " themes for vim-airline
  Plug 'vim-airline/vim-airline'        " configurable status line for vim
endif

" ============
" Disabled Plugins
" ============
" Plug '/usr/local/opt/fzf'
" Plug 'dense-analysis/ale'           " linting
" Plug 'junegunn/fzf.vim'
" Plug 'lilydjwg/colorizer'
" Plug 'phanviet/vim-monokai-pro'
" Plug 'scrooloose/nerdtree' ", { 'on': 'NERDTreeToggle' }
" Plug 'terryma/vim-multiple-cursors'
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" Plug 'tmux-plugins/vim-tmux-focus-events'
" Plug 'Xuyuanp/nerdtree-git-plugin'
" markdown-preview is very large and requires node and yarn
" Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' }
" Plug 'iamcco/markdown-preview.nvim', { 'do': { -> mkdp#util#install() }, 'for': ['markdown', 'vim-plug']}
:call plug#end()

" =================
" Configure plugins
" =================

" -----------
" delimitMate
" -----------
:let g:delimitMate_balance_matchpairs = 1
:let g:delimitMate_expand_cr = 2
:let g:delimitMate_expand_inside_quotes = 1
:let g:delimitMate_expand_space = 1
:let g:delimitMate_jump_expansion = 1

" ---------
" EasyAlign
" ---------
" Start interactiveEasyAlign in visual and normal modes
:xmap ga <Plug>(EasyAlign)
:nmap ga <Plug>(EasyAlign)

if !exists('g:vscode')
  " ------------
  " Vim-Markdown
  " Markdown style guide: https://cirosantilli.com/markdown-style-guide
  " ------------
  :let g:vim_markdown_new_list_item_indent = 2            " default 4 (may prefer 0)
  :let g:vim_markdown_no_extensions_in_markdown = 1       " for links to (md) files
  ":let g:vim_markdown_folding_disabled = 1               " default enabled
  ":let g:vim_markdown_auto_insert_bullets = 0            " auto-insert bullets can lead to wrapping problems
  ":let g:vim_markdown_autowrite = 1                      " autowrite when following links from unsaved changes
  ":let g:vim_markdown_auto_extension_ext = 'txt'         " default 'md'
  ":let g:vim_markdown_edit_url_in = 'tab'                " default 'current' buffer. also 'vsplit', 'hsplit'

  " -----------
  " Vim Airline
  " -----------
  :let g:airline_detect_modified=1
  :let g:airline_inactive_alt_sep=1
  :let g:airline_inactive_collapse=1
  :let g:airline_section_c = '../%{expand("%:p:h:t")}/%t %m%r%h%w'
  :let g:airline_section_x = '%m%r%h%w'
  :let g:airline_section_y = '%t'
  :let g:airline#extensions#fugitiveline#enabled = 1
  :let g:airline#extensions#tabline#enabled = 1            " smarter tabline
  :let g:airline#extensions#tabline#formatter = 'default'  " unique_tail_improved
  :let g:airline#extensions#whitespace#enabled = 0
  "
  " Show vim-devicons in airline
  :let g:airline_powerline_fonts = 1                       " for vim-devicons
  :let g:webdevicons_enable_airline_statusline = 1
  :let g:webdevicons_enable_airline_tabline = 1
endif

" ============
" Code Folding
" ============
" Set open folding when files open using Vim folding options
:autocmd BufWinEnter * silent! :%foldopen!
":autocmd Syntax c,cpp,vim,xml,html,xhtml,javascript,jsx,json,markdown,lock,css,scss setlocal foldmethod=syntax
":autocmd Syntax c,cpp,vim,xml,html,xhtml,javascript,jsx,json,markdown,lock,css,scss,perl normal zR
"
" Enable folding in JavaScript files
:set foldmethod=syntax
:set foldcolumn=1
:let javaScript_fold=1
"
" Set neat fold text
" https://dhruvasagar.com/2013/03/28/vim-better-foldtext
:function! NeatFoldText()
  :let line = ' ' . substitute(getline(v:foldstart), '^\s*"\?\s*\|\s*"\?\s*{{' . '{\d*\s*', '', 'g') . ' '
  :let lines_count = v:foldend - v:foldstart + 1
  :let lines_count_text = '| ' . printf("%10s", lines_count . ' lines') . ' |'
  :let foldchar = '·'
  ":let foldchar = matchstr(&fillchars, 'fold:\zs.')   "not working
  :let foldtextstart = strpart('+' . repeat(foldchar, (v:foldlevel*2)-4) . line, 0, (winwidth(0)*2)/3)
  :let foldtextend = lines_count_text . repeat(foldchar, 8)
  :let foldtextlength = strlen(substitute(foldtextstart . foldtextend, '.', 'x', 'g')) + &foldcolumn
  :return foldtextstart . repeat(foldchar, winwidth(0)-foldtextlength) . foldtextend
:endfunction
:set foldtext=NeatFoldText()
"
" Disable all folding
:set nofoldenable

" ============
" Twiddle case
" ============
" Toggle with ~ through UPPER CASE, lower case, and Title Case
:function! TwiddleCase(str)
  :if a:str ==# toupper(a:str)
    :let result = tolower(a:str)
  :elseif a:str ==# tolower(a:str)
    :let result = substitute(a:str,'\(\<\w\+\>\)', '\u\1', 'g')
  :else
    :let result = toupper(a:str)
  :endif
  :return result
:endfunction
:vnoremap ~ y:call setreg('', TwiddleCase(@"), getregtype(''))<CR>gv""Pgv

" ============
" Cursor modes
" ============
" Required for neovim in iTerm2 (but not Tmux)
:let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1   " documentation says removed, but only thing that works
"
" THIS ACTUALLY WORKS!!! (requires re-sourcing AND detaching from tmux)
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"  "insert mode = bar
    let &t_EI = "\<Esc>Ptmux;\<Esc>\e[2 q\<Esc>\\"  "normal mode = steady block (1 for blinking)
    let &t_SR = "\<Esc>Ptmux;\<Esc>\e[4 q\<Esc>\\"  "replace mode = underline
endif

" =================
" Keyboard bindings
" =================
" -------------------------
" Buffers, tabs, and splits
" -------------------------
" This allows buffers to be hidden if you've modified a buffer.
" This is almost a must if you wish to use buffers in this way.
:set hidden
"
"move around splits with Ctrl-hjkl
:nmap <C-h> <C-w>h
:nmap <C-l> <C-w>l
":nmap <C-j> <C-w>j
":nmap <C-k> <C-w>k
"
if !exists('g:vscode')
  " To open a new empty buffer
  " This replaces :tabnew which I used to bind to this mapping
  :nmap <leader>T :enew<cr>
  "
  " Move to the next buffer
  ":nmap <leader>l :bnext<CR>
  :noremap <leader>l :<C-U>bnext<CR>
  :noremap <A-l> :<C-U>bnext<CR>
  :cnoremap <leader>l <C-C>:bnext<CR>
  :cnoremap <A-l> <C-C>:bnext<CR>
  ":inoremap <leader>l <C-\><C-N>:bnext<CR>
  "
  " Move to the previous buffer
  ":nmap <leader>h :bprevious<CR>
  :noremap <leader>h :<C-U>bprevious<CR>
  :noremap <A-h> :<C-U>bprevious<CR>
  :cnoremap <leader>h <C-C>:bprevious<CR>
  :cnoremap <A-h> <C-C>:bprevious<CR>
  ":inoremap <leader>h <C-\><C-N>:bprevious<CR>
  "
  " Move to numbered buffer
  :nnoremap <leader>1 :1b<cr>
  :nnoremap <leader>2 :2b<cr>
  :nnoremap <leader>3 :3b<cr>
  :nnoremap <leader>4 :4b<cr>
  :nnoremap <leader>5 :5b<cr>
  :nnoremap <leader>6 :6b<cr>
  :nnoremap <leader>7 :7b<cr>
  :nnoremap <leader>8 :8b<cr>
  :nnoremap <leader>9 :9b<cr>
  :nnoremap <leader>0 :10b<cr>
  "
  " Close the current buffer and move to the previous one
  " This replicates the idea of closing a tab
  nmap <leader>w :bp <BAR> bd #<CR>
  "
  " Show all open buffers and their status
  nmap <leader>b :ls<CR>
  "
  " open new vertical split and switch over to it
  :nnoremap <leader>v <C-w>v<C-w>l
  "
  " close current split
  :nnoremap <leader>q <C-w>q
endif

" ---------------------------------
" Fix cut/copy/paste with registers
" ---------------------------------
" Prevent single character deletes from overriding register
:nnoremap x "_x
:nnoremap X "_X
:nnoremap r "_r
:nnoremap s "_s
" Prevent all d deletes and c changes from overriding registers
:nnoremap d "_d
:xnoremap d "_d
:nnoremap c "_c
:xnoremap c "_c
" Visual selection x goes to system register (Cut)
:xnoremap x "*x
" Yanks sent to system register
:nnoremap y "*y
:nnoremap Y "*Y
:xnoremap y "*y
:xnoremap Y "*Y
" Normal Paste from system register
:nnoremap p "*p
:nnoremap P "*P
" Prevent p overriding register when pasting into a visual selection
:xnoremap p "_dP

" ----------------------------
" Useful single key remappings
" ----------------------------
" Modify return to unset last search pattern's highlighting AND disable descending to next line
:nnoremap <silent> <CR> :nohlsearch<CR>
"
" Prevent j and k from expanding code folding lines;
:nmap <expr> j v:count ? 'j' : 'gj'
:nmap <expr> k v:count ? 'k' : 'gk'
" also preserve ability to use numbers before j & k to jump by count lines;
" also saves all jumps higher than 5 lines to jumplist, allowing ctrl+o/ctrl+i jump backs
":nmap <expr> j v:count ? (v:count > 5 ? "m'" . v:count : '') . 'j' : 'gj'
":nmap <expr> k v:count ? (v:count > 5 ? "m'" . v:count : '') . 'k' : 'gk'
"
" Stop * (asterisk) searching for word under cursor
:nnoremap * <Nop>
:vnoremap * <Nop>
"
" Map > and < in visual mode to indent/outdent and keep selection
:vnoremap > >gv
:vnoremap < <gv
"
" Reselect content just pasted
:nnoremap <leader>p V`]
"
" Toggle line wrapping
:map <silent> <A-z> :set wrap!<CR>
"
" Move lines up/down with Alt-j Alt-k
:nnoremap <A-j> :m .+1<CR>==
:nnoremap <A-k> :m .-2<CR>==
:inoremap <A-j> <Esc>:m .+1<CR>==gi
:inoremap <A-k> <Esc>:m .-2<CR>==gi
:vnoremap <A-j> :m '>+1<CR>gv=gv
:vnoremap <A-k> :m '<-2<CR>gv=gv
"
" Substitute word under cursor, use gn for next, and dot repeat
:nnoremap <silent> <Leader>c :let @/='\<'.expand('<cword>').'\>'<CR>cgn
:xnoremap <silent> <Leader>c "sy:let @/=@s<CR>cgn
"
if !exists('g:vscode')
  " Backgrounds (Minimizes) nvim
  :nnoremap <leader>m <C-z>
  " 'm' alias in .zshrc to foreground again
  "
  " Output the syntax group under the cursor
  :nnoremap <leader>x :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
  \ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
  \ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<cr>
endif

" =============
" Color schemes
" =============
:syntax on
if !exists('g:vscode')
  :let g:airline_theme='dracula'
  :let g:monokai_fusion_italic = 1
  :colorscheme monokai-fusion
endif

" ==============
" Keep at bottom
" ==============
if exists('$FIRST_RUN_NEOVIM')
  :PlugInstall
endif
"
:set termguicolors " makes screen turn blue in terminal

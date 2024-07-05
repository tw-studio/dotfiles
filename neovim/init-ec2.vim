" Set leader
" ==========
:let mapleader = ","

" General Vim settings
" ====================
:autocmd FileType * set formatoptions=tcql nocindent comments&
:autocmd BufEnter * silent! normal! g`"zz
:set autoindent
:set autoread
":set clipboard+=unnamedplus            "ALWAYS use system clipboard for ALL operations
:set clipboard=                         "manually set clipboard registers below
:set confirm
:set encoding=utf8
:set expandtab
:set gdefault                           "always global substitution, no 'g' in sed
:set hlsearch
:set ignorecase                         "ignorecase in searches; also see smartcase
:set incsearch
:set infercase                          "supposedly better than ignorecase; applies to ins-completion
:set mouse=a
:set nosol
:set number                             "shows current line number
:set numberwidth=4                      "set gutter to 4
:set relativenumber                     "sets relative line numbers
:set shiftround                         "rounds indents to multiple of shiftwidth
:set shiftwidth=2
:set showcmd                            "shows when Leader is pressed
:set smartcase                          "override ignorecase when search pattern has uppercase
:set splitbelow                         "always open h splits below
:set splitright                         "always open v splits on right
:set t_Co=256
:set t_ut=
:set tabstop=2
:set textwidth=120
:set whichwrap+=<,>,h,l,[,]
:set wildmenu                           "use TAB with :e to autosuggest & autocomplete
:set wildmode=full                      "use TAB with :e to autosuggest & autocomplete

" Wrap long lines with an indentation
:set breakindent
:set breakindentopt=shift:2
:set showbreak=\\\\\

" Install plugins with Vim-Plug
" =============================
" Run :PlugInstall in neovim to install
" Or in background, run: nvim --headless +PlugInstall +qall
:call plug#begin('~/.local/share/nvim/plugged')
Plug 'dracula/vim'
Plug 'junegunn/vim-easy-align'              " aligns text with ga commands
Plug 'kshenoy/vim-signature'                " m commands for marks
Plug 'neoclide/vim-jsx-improve'             " support React jsx
Plug 'Raimondi/delimitMate'                 " auto closes quotes, parens, etc
Plug 'ryanoasis/vim-devicons'               " dependency for other plugins
Plug 'tmux-plugins/vim-tmux-focus-events'   " may no longer be needed
Plug 'tpope/vim-commentary'                 " gc cmds to comment code
Plug 'tpope/vim-sensible'                   " sensible defaults
Plug 'tpope/vim-surround'                   " ys, cs, ds cmds to surround code
Plug 'vim-airline/vim-airline-themes'
Plug 'vim-airline/vim-airline'
:call plug#end()

" Uninstalled plugins
" ===================
" Plug '/usr/local/opt/fzf'
" Plug 'ajh17/VimCompletesMe'
" Plug 'cakebaker/scss-syntax.vim'
" Plug 'crusoexia/vim-monokai'
" Plug 'dbakker/vim-projectroot'
" Plug 'dense-analysis/ale'
" Plug 'elzr/vim-json'
" Plug 'ErichDonGubler/vim-sublime-monokai'
" Plug 'godlygeek/tabular'              " goes with vim-markdown
" Plug 'jparise/vim-graphql'
" Plug 'JulesWang/css.vim'
" Plug 'junegunn/fzf.vim'
" Plug 'lilydjwg/colorizer'
" Plug 'MaxMEllon/vim-jsx-pretty'
" Plug 'mg979/vim-visual-multi'
" Plug 'pangloss/vim-javascript'
" Plug 'patstockwell/vim-monokai-tasty'
" Plug 'phanviet/vim-monokai-pro'
" Plug 'plasticboy/vim-markdown'        " goes with tabular
" Plug 'rstacruz/sparkup'  "fast HTML completions
" Plug 'scrooloose/nerdtree' ", { 'on': 'NERDTreeToggle' }
" Plug 'sheerun/vim-polyglot'
" Plug 'shmargum/vim-sass-colors'
" Plug 'styled-components/vim-styled-components'
" Plug 'terryma/vim-multiple-cursors'   " deprecated; use vim-visual-multi
" Plug 'tiagofumo/vim-nerdtree-syntax-highlight'
" Plug 'tmux-plugins/vim-tmux'
" Plug 'tomasr/molokai'
" Plug 'tpope/vim-fugitive'
" Plug 'Xuyuanp/nerdtree-git-plugin'
" markdown-preview is very large and requires node and yarn
" Plug 'iamcco/markdown-preview.nvim', { 'do': 'cd app & yarn install' }

" Configure plugins
" =================

" EasyAlign
" ---------
" Start interactiveEasyAlign in visual and normal modes
:xmap ga <Plug>(EasyAlign)
:nmap ga <Plug>(EasyAlign)

" Vim Airline
" -----------
:let g:airline#extensions#tabline#enabled = 1            "smarter tabline
:let g:airline#extensions#tabline#formatter = 'default'  "unique_tail_improved
:let g:airline_detect_modified=1
:let g:airline_inactive_collapse=1
:let g:airline_inactive_alt_sep=1
:let g:airline#extensions#fugitiveline#enabled = 1
:let g:airline#extensions#whitespace#enabled = 0
:let g:airline_section_c = '../%{expand("%:p:h:t")}/%t %m%r%h%w'
:let g:airline_section_x = '%m%r%h%w'
:let g:airline_section_y = '%t'
"
" Show vim-devicons in airline
:let g:airline_powerline_fonts = 1    "for vim-devicons
:let g:webdevicons_enable_airline_tabline = 1
:let g:webdevicons_enable_airline_statusline = 1
"

" delimitMate
" -----------
:let g:delimitMate_expand_cr = 2
:let g:delimitMate_expand_space = 1
:let g:delimitMate_expand_inside_quotes = 1
:let g:delimitMate_jump_expansion = 1
:let g:delimitMate_balance_matchpairs = 1

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


" Cursor modes
" ===========
" Required for neovim in iTerm2 (but not Tmux)
:let $NVIM_TUI_ENABLE_CURSOR_SHAPE = 1   "documentation says removed, but only thing that works
"
" THIS ACTUALLY WORKS!!! (requires re-sourcing AND detaching from tmux)
if exists('$TMUX')
    let &t_SI = "\<Esc>Ptmux;\<Esc>\e[5 q\<Esc>\\"  "insert mode = bar
    let &t_EI = "\<Esc>Ptmux;\<Esc>\e[1 q\<Esc>\\"  "normal mode = steady block (1 for blinking)
    let &t_SR = "\<Esc>Ptmux;\<Esc>\e[4 q\<Esc>\\"  "replace mode = underline
endif

" =================
" Keyboard bindings
" =================
" Backgrounds (Minimizes) nvim
:nnoremap <leader>m <C-z>
" 'm' alias in .zshrc to foreground again
"
" Move lines up/down with Alt-j Alt-k
:nnoremap <A-j> :m .+1<CR>==
:nnoremap <A-k> :m .-2<CR>==
:inoremap <A-j> <Esc>:m .+1<CR>==gi
:inoremap <A-k> <Esc>:m .-2<CR>==gi
:vnoremap <A-j> :m '>+1<CR>gv=gv
:vnoremap <A-k> :m '<-2<CR>gv=gv
"
" Output the syntax group under the cursor
nnoremap <leader>x :echo "hi<" . synIDattr(synID(line("."),col("."),1),"name") . '> trans<'
\ . synIDattr(synID(line("."),col("."),0),"name") . "> lo<"
\ . synIDattr(synIDtrans(synID(line("."),col("."),1)),"name") . ">"<cr>
"
"reselect content just pasted
:nnoremap <leader>p V`]
"
" Toggle line wrapping
:map <silent> <A-z> :set wrap!<CR>
"
" Substitute word under cursor, use gn for next, and dot repeat
:nnoremap <silent> <Leader>c :let @/='\<'.expand('<cword>').'\>'<CR>cgn
:xnoremap <silent> <Leader>c "sy:let @/=@s<CR>cgn
"

" -------------------------
" Buffers, tabs, and splits
" -------------------------
" This allows buffers to be hidden if you've modified a buffer.
" This is almost a must if you wish to use buffers in this way.
:set hidden
"
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
"
"move around splits with Ctrl-hjkl
:nnoremap <C-h> <C-w>h
:nnoremap <C-l> <C-w>l
":nnoremap <C-j> <C-w>j
":nnoremap <C-k> <C-w>k

" -------------
" Abbreviations
" -------------
" open help in vertical split on right (no longer use; :help is better config'd now)
:cnoreabbrev H vert bo h

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

" --------------------------
" Miscellaneous usefulnesses
" --------------------------
" Modify return to unset last search pattern's highlighting AND disable descending to next line
:nnoremap <silent> <CR> :nohlsearch<CR>

" =============
" Color schemes
" =============
:syntax on
:let g:airline_theme='dracula'
:let g:monokai_fusion_italic = 1
:colorscheme monokai-fusion
"

" ==============
" Keep at bottom
" ==============
if exists('$FIRST_RUN_NEOVIM')
  :PlugInstall
endif

:set termguicolors " keep at bottom

" ===========================================================
" Stuff that doesn't work in neovim and/or tmux and/or iterm2
" ===========================================================
" use an orange cursor in insert mode
" :let &t_SI .= "\<Esc>]12;orange\x7"
" " use a red cursor otherwise
" :let &t_EI .= "\<Esc>]12;red\x7"
" :silent !echo -ne "\033]12;red\007"
" " reset cursor when vim exits
" :autocmd VimLeave * silent !echo -ne "\033]112\007"
"
" insert mode - line
" :let &t_SI .= "\<Esc>[5 q"
"replace mode - underline
" :let &t_SR .= "\<Esc>[4 q"
"common - block
" :let &t_EI .= "\<Esc>[3 q"
"
" :let &t_SI.="\e[5 q" "SI = INSERT mode
" :let &t_SR.="\e[4 q" "SR = REPLACE mode
" :let &t_EI.="\e[1 q" "EI = NORMAL mode (ELSE)
"
" :highlight Cursor guifg=white guibg=black
" :highlight iCursor guifg=white guibg=steelblue
" :set guicursor=n-v-c:block-iCursor
" :set guicursor+=i:ver100-iCursor
" :set guicursor+=n-v-c:blinkon0
" :set guicursor+=i:blinkwait10
" ":set guicursor+=r-cr-o:hor100-iCursor
"
" Default guicursor settings, as reference:
" :set guicursor=n-v-c-sm:block
" :set guicursor+=i-ci-ve:ver1
" :set guicursor+=r-cr-o:hor1

" =======================================
" Airline section defaults (for reference)
" =======================================
":let g:airline_section_a = airline#section#create_left(['mode', 'crypt', 'paste', 'keymap', 'spell', 'capslock', 'xkblayout', 'iminsert'])
":let g:airline_section_b = airline#section#create(['hunks', 'branch'])
":let g:airline_section_c = airline#section#create(['%<', 'file', spc, 'readonly'])
":let g:airline_section_gutter = airline#section#create(['%='])
":let g:airline_section_x = airline#section#create_right(['bookmark', 'tagbar', 'vista', 'gutentags', 'grepper', 'filetype'])
" if !exists('g:airline_section_z')
"     if airline#util#winwidth() > 79
"       let g:airline_section_z = airline#section#create(['windowswap', 'obsession', '%3p%%'.spc, 'linenr', 'maxlinenr', spc.':%3v'])
"     else
"       let g:airline_section_z = airline#section#create(['%3p%%'.spc, 'linenr',  ':%3v'])
"     endif
"   endif
":let g:airline_section_error = airline#section#create(['ycm_error_count', 'syntastic-err', 'eclim', 'neomake_error_count', 'ale_error_count', 'languageclient_error_count', 'coc_error_count'])
":let g:airline_section_warning = airline#section#create(['ycm_warning_count',  'syntastic-warn', 'neomake_warning_count', 'ale_warning_count', 'languageclient_warning_count', 'whitespace', 'coc_warning_count'])
  
" let g:airline#extensions#default#section_truncate_width = {
"       \ 'b': 79,
"       \ 'x': 60,
"       \ 'y': 88,
"       \ 'z': 45,
"       \ 'warning': 80,
"       \ 'error': 80,
"       \ }

" let g:airline#extensions#default#layout = [
"       \ [ 'a', 'b', 'c' ],
"       \ [ 'x', 'y', 'z', 'error', 'warning' ]
"       \ ]

" ==============================
" Disabled plugins configuration
" ==============================

" Markdown-Preview
" ----------------
"
" Recently enabled
" ----------------
" Key bindings to start, stop, toggle
" :nmap zp :MarkdownPreview<cr>
" :nmap zP :MarkdownPreviewStop<cr>
" (def:0) set to 1, echo preview page url in command line when open preview page
" :let g:mkdp_echo_preview_url = 1
" (def:0) set to 1, preview server available to others in your network
" by default, the server listens on localhost (127.0.0.1)
" :let g:mkdp_open_to_the_world = 1
" use a custom port to start server or random for empty
" :let g:mkdp_port = '7000'
"
" Previously disabled
" -------------------
"":nnoremap zp <Plug>MarkdownPreviewToggle
" (def:0) set to 1, nvim will open the preview window after entering the markdown buffer
":let g:mkdp_auto_start = 0
" (def:1) set to 1, the nvim will auto close current preview window when change
" from markdown buffer to another buffer
":let g:mkdp_auto_close = 1
" (def:0) set to 1, the vim will refresh markdown when save the buffer or
" leave from insert mode, default 0 is auto refresh markdown as you edit or
" move the cursor
":let g:mkdp_refresh_slow = 0
" (def:0) set to 1, the MarkdownPreview command can be use for all files,
" by default it can be use in markdown file
":let g:mkdp_command_for_global = 0
" (def:empty) use custom IP to open preview page
" useful when you work in remote vim and preview on local browser
" more detail see: https://github.com/iamcco/markdown-preview.nvim/pull/9
":let g:mkdp_open_ip = ''
" (def:'') specify browser to open preview page
":let g:mkdp_browser = ''
" (def:empty) a custom vim function name to open preview page
" this function will receive url as param
":let g:mkdp_browserfunc = ''
" options for markdown render
" mkit: markdown-it options for render
" katex: katex options for math
" uml: markdown-it-plantuml options
" maid: mermaid options
" disable_sync_scroll: if disable sync scroll, default 0
" sync_scroll_type: 'middle', 'top' or 'relative', default value is 'middle'
"   middle: mean the cursor position alway show at the middle of the preview page
"   top: mean the vim top viewport alway show at the top of the preview page
"   relative: mean the cursor position alway show at the relative positon of the preview page
" hide_yaml_meta: if hide yaml metadata, default is 1
" sequence_diagrams: js-sequence-diagrams options
":let g:mkdp_preview_options = {
"     \ 'mkit': {},
"     \ 'katex': {},
"     \ 'uml': {},
"     \ 'maid': {},
"     \ 'disable_sync_scroll': 0,
"     \ 'sync_scroll_type': 'middle',
"     \ 'hide_yaml_meta': 1,
"     \ 'sequence_diagrams': {}
"     \ }
" use a custom markdown style must be absolute path
":let g:mkdp_markdown_css = ''
" use a custom highlight style must absolute path
":let g:mkdp_highlight_css = ''
" preview page title
" ${name} will be replace with the file name
":let g:mkdp_page_title = '「${name}」'

" FZF.vim
" -------
" :nnoremap <C-p> :FZF ~<Cr>
" :let g:fzf_layout = { 'down': '~20%' }
" :let g:fzf_action = {
"   \ 'ctrl-t': 'tab split',
"   \ 'ctrl-x': 'split',
"   \ 'ctrl-v': 'vsplit' }   "should open splits on right thanks to set splitright

" Vim-Polyglot
" ------------
" :let g:polyglot_disabled = ['javascript']
" :let g:polyglot_disabled = ['jsx']

" Vim-Markdown
" Markdown style guide: https://cirosantilli.com/markdown-style-guide
" ------------
" Recently enabled
" ----------------
" :let g:vim_markdown_new_list_item_indent = 2            " default 4 (may prefer 0)
" :let g:vim_markdown_no_extensions_in_markdown = 1       " for links to (md) files
"
" Previously disabled
" -------------------
":let g:vim_markdown_folding_disabled = 1               " default enabled
":let g:vim_markdown_auto_insert_bullets = 0            " auto-insert bullets can lead to wrapping problems
":let g:vim_markdown_autowrite = 1                      " autowrite when following links from unsaved changes
":let g:vim_markdown_auto_extension_ext = 'txt'         " default 'md'
":let g:vim_markdown_edit_url_in = 'tab'                " default 'current' buffer. also 'vsplit', 'hsplit'
" ---

" Configure ALE and ESLint
" ========================
" Recently enabled
" ----------------
" Set global ALE fixers. (*) applies to all filetypes.
" :let g:ale_fixers = {
" \   '*': ['remove_trailing_lines', 'trim_whitespace'],
" \   'javascript': ['prettier', 'eslint'],
" \}
"
" Integrate with Airline
" :let g:airline#extensions#ale#enabled = 1
"
" Show 5 lines of errors (default: 10)
" let g:ale_list_window_size = 5
"
" Do not lint or fix minified files.
" let g:ale_pattern_options = {
" \ '\.min\.js$': {'ale_linters': [], 'ale_fixers': []},
" \ '\.min\.css$': {'ale_linters': [], 'ale_fixers': []},
" \}
" If you configure g:ale_pattern_options outside of vimrc, you need this.
" let g:ale_pattern_options_enabled = 1
"
" Ctrl-k and Ctrl-j to walk up/down warnings & errors
" :nnoremap <silent> <C-k> <Plug>(ale_previous_wrap)
" :nnoremap <silent> <C-j> <Plug>(ale_next_wrap)
"
" <leader>f to fix error or warning
" :nnoremap <leader>f :ALEFix<cr>
"
" -------------------
" Previously disabled
" -------------------
" Change ALE indicators
":let g:ale_sign_error = '❌'
":let g:ale_sign_warning = '⚠️'
"
" Set to 1 to fix files when you save them.
":let g:ale_fix_on_save = 1
"
" Default automatically lints on save, but can be disabled
":let g:ale_lint_on_save = 1
" Disable all other lint triggers
":let g:ale_lint_on_text_changed = 'never'
":let g:ale_lint_on_insert_leave = 0
":let g:ale_lint_on_enter = 0
"
" Customize ALE signs
":let g:ale_sign_error = '>>'
":let g:ale_sign_warning = '--'
"
" Customize ALE bgcolors for errors & warnings
":highlight clear ALEErrorSign
":highlight clear ALEWarningSign
"
" Customize ALE highlight colors
" See :help ale-highlights
":highlight ALEWarning ctermbg=DarkMagenta
"
" ALE highlights to SpellBad, SpellCap, error, and todo groups by default.
" Set to 0 to disable all highlighting
":let g:ale_set_highlights = 0

" NERDTree
" --------
" Always open NERDTree with nvim
"":autocmd VimEnter * NERDTree
"
" Integration with vim-projectroot
" Always open NERDTree at root of project
"":autocmd UIEnter * :silent! :ProjectRootExe NERDTreeFind<cr>
"
" Shift focus to main file window after NERDTree opens
"":autocmd VimEnter * call timer_start(1, { tid -> execute('wincmd w')})
"
" Open NERDTree when nvim opens on a directory
"":autocmd StdinReadPre * let s:std_in=1
"":autocmd VimEnter * if argc() == 1 && isdirectory(argv()[0]) && !exists("s:std_in") | exe 'NERDTree' argv()[0] | wincmd p | ene | exe 'cd '.argv()[0] | endif
"
" Set NERDTree defaults
"":let g:NERDTreeWinSize=20
"
" Toggle NERDTree
"":let NERDTreeShowHidden=1
"":nnoremap <leader>n :NERDTreeToggle<cr>
"
" Show current file in NERDTree
"":nnoremap <silent> <leader>g :NERDTreeFind<cr>
"
" Close nvim when NERDTree is the only window
"":autocmd bufenter * if (winnr("$") == 1 && exists("b:NERDTree") && b:NERDTree.isTabTree()) | q | endif
"
" Show vim-devicons in NERDTree
"":let g:webdevicons_enable_nerdtree = 1
"
" Hide vim-devicons brackets around NERDTree flags
"":let g:webdevicons_conceal_nerdtree_brackets = 1
"
" Disabled NERDTree settings
" --------------------------
" Visual settings
"":let NERDTreeMinimalUI = 1
"":let NERDTreeDirArrows = 1
"
" Change current working directory to project root whenever opening a buffer
"":autocmd BufEnter * call <SID>AutoProjectRootCD()
"
" Open NERDTree when nvim opens with no arguments (*not working*)
"":autocmd StdinReadPre * let s:std_in=1
"":autocmd VimEnter * if argc() == 0 && !exists(“s:std_in”) | NERDTree | endif
"
" Highlight current file in NERDTree automatically
" ------------------------------------------------
" " Check if NERDTree is open or active
" :function! rc:isNERDTreeOpen()        
"   :return exists("t:NERDTreeBufName") && (bufwinnr(t:NERDTreeBufName) != -1)
" :endfunction
" " Call NERDTreeFind iff NERDTree is active, current window contains a modifiable
" " file, and we're not in vimdiff
" :function! rc:syncTree()
"   :if &modifiable && rc:isNERDTreeOpen() && strlen(expand('%')) > 0 && !&diff
"     :NERDTreeFind
"     :wincmd p
"   :endif
" :endfunction
" " Highlight currently open buffer in NERDTree
" :autocmd BufEnter * call rc:syncTree()


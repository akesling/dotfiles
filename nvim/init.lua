--------------------------------------------------------------
--------- HEADER ---------------------------------------------
-- Change the mapleader from \ to , #Note that this needs to be before everything
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

--------------------------------------------------------------

require("config.lazy")


--------------------------------------------------------------
--------- Change Basic Behavior ------------------------------

vim.opt.ignorecase = true       -- Search is now case-insensitive by default, but
vim.opt.smartcase = true        -- case-sensitive if it contains an upper-case
                                -- symbol.

vim.opt.wildmenu = true         -- Use the wildmenu when doing "open" completions
-- set wildignore=*.swp,*.bak,*.pyc,*.class
vim.opt.wildmode="list:longest,full"  -- Default search to both show the completion
                                      -- list and auto-complete to longest
                                      -- simultaneously.

--------------------------------------------------------------



--------------------------------------------------------------
--------- Change Visual Behavior -----------------------------

vim.opt.showmatch = true -- Set show matching parentheses.

vim.opt.scrolloff = 1    -- Show at least one line above/below cursor.

vim.opt.showcmd = true -- e.g. when using c, r, etc., indicate those are in an
                       -- active state while executing.

vim.opt.list = true

vim.opt.listchars = "tab:»·,trail:·,extends:#,nbsp:·"  -- Show me tabs and trailing
                                                       -- whitespace

vim.opt.ruler = true       -- show the cursor position all the time

-- set relativenumber       " Show relative line-number offset from current line
vim.opt.relativenumber = true
-- set numberwidth=2        " Reduce gutter size as much as is reasonable
vim.opt.numberwidth = 2
--
-- set textwidth=80         " Default to 80 character text width
vim.opt.textwidth = 80

-- Shade the buffer in vertical bands relative to textwidth so the writing
-- area sits in a darker channel with a soft step out across the wrap line.
-- Color stops (solarized base03 = #002b36):
--   inside  cols 1..tw      -> #002630  (darker,            via ColorColumn)
--   edge    col  tw+1       -> #002934  (intermediate dark, via decoration)
--   step    col  tw+2       -> #002e39  (slightly lighter,  via decoration)
--   beyond  cols tw+3..end  -> #002b36  (Normal bg)
--
-- tw+1 and tw+2 use a decoration provider so they render on every line
-- including past EOL (matchadd's \%Nv only matches actual characters).
local function apply_wrap_shading()
    local tw = vim.bo.textwidth
    if tw == nil or tw <= 0 then
        vim.wo.colorcolumn = ""
        return
    end
    local cols = {}
    for i = 1, tw do
        cols[i] = tostring(i)
    end
    vim.wo.colorcolumn = table.concat(cols, ",")
end

local function apply_wrap_highlights()
    vim.api.nvim_set_hl(0, "ColorColumn",    { bg = "#002630" })
    vim.api.nvim_set_hl(0, "WrapWidthEdge",  { bg = "#002934" })
    vim.api.nvim_set_hl(0, "WrapWidthEdge2", { bg = "#002d38" })
end

local edge_ns = vim.api.nvim_create_namespace("WrapWidthEdge")

local function paint_column(bufnr, winid, row, line, line_vwidth, vcol, hl)
    if line_vwidth >= vcol then
        local byte_col = vim.fn.virtcol2col(winid, row + 1, vcol)
        if byte_col <= 0 then return end
        local b = byte_col - 1  -- 0-indexed start byte
        -- Find end byte of the (possibly multibyte) char at b.
        local end_b = b + 1
        while end_b <= #line and line:byte(end_b + 1) and
              line:byte(end_b + 1) >= 0x80 and line:byte(end_b + 1) < 0xc0 do
            end_b = end_b + 1
        end
        pcall(vim.api.nvim_buf_set_extmark, bufnr, edge_ns, row, b, {
            end_col = end_b,
            hl_group = hl,
            ephemeral = true,
            priority = 110,
        })
    else
        pcall(vim.api.nvim_buf_set_extmark, bufnr, edge_ns, row, 0, {
            virt_text = { { " ", hl } },
            virt_text_win_col = vcol - 1,
            ephemeral = true,
            priority = 110,
        })
    end
end

vim.api.nvim_set_decoration_provider(edge_ns, {
    on_win = function(_, _, bufnr)
        local tw = vim.bo[bufnr].textwidth
        return tw ~= nil and tw > 0
    end,
    on_line = function(_, winid, bufnr, row)
        local tw = vim.bo[bufnr].textwidth
        if tw == nil or tw <= 0 then return end
        local line = vim.api.nvim_buf_get_lines(bufnr, row, row + 1, false)[1] or ""
        local line_vwidth = vim.fn.strdisplaywidth(line)
        paint_column(bufnr, winid, row, line, line_vwidth, tw + 1, "WrapWidthEdge")
        paint_column(bufnr, winid, row, line, line_vwidth, tw + 2, "WrapWidthEdge2")
    end,
})

local wrap_shade_group = vim.api.nvim_create_augroup("WrapWidthShading", { clear = true })
vim.api.nvim_create_autocmd({ "BufWinEnter", "WinNew" }, {
    group = wrap_shade_group,
    callback = apply_wrap_shading,
})
vim.api.nvim_create_autocmd("OptionSet", {
    group = wrap_shade_group,
    pattern = "textwidth",
    callback = apply_wrap_shading,
})
vim.api.nvim_create_autocmd("ColorScheme", {
    group = wrap_shade_group,
    callback = apply_wrap_highlights,
})
-- Apply once at startup (the ColorScheme autocmd won't fire for the
-- colorscheme that's already active when this file loads).
apply_wrap_highlights()
apply_wrap_shading()
--
-- " Don't wake up system with blinking cursor:
-- " http://www.linuxpowertop.org/known.php
-- set guicursor += ",a:blinkon0"
--
-- colorscheme solarized
-- let g:solarized_termtrans=1 " Solarized otherwise doesn't respect transparency
--
-- let g:airline#extensions#tabline#enabled=1 " Enable Airline control of tabline
-- let g:airline#extensions#tabline#formatter='jsformatter'
--
-- set background=dark  " Dark like cave.

--------------------------------------------------------------

--------------------------------------------------------------
--------- Core Remappings ------------------------------------

-- Give an alternative for having to stretch for ESC. Suggestion by Val Markovic.
-- inoremap jk <Esc>
vim.api.nvim_set_keymap('i', 'jk', '<Esc>', { noremap = true, silent = true })

-- Thank you Val Markovic for pointing out I wasn't doing this in visual mode
-- In normal mode, we use : much more often than ; so lets swap them.
-- WARNING: this will cause any "ordinary" map command without the "nore" prefix
-- that uses ":" to fail. For instance, "map <f2> :w" would fail, since vim will
-- read ":w" as ";w" because of the below remappings. Use "noremap"s in such
-- situations and you'll be fine.
-- nnoremap ; :
vim.api.nvim_set_keymap('n', ';', ':', { noremap = true, silent = true })
-- "nnoremap : ;
-- vim.api.nvim_set_keymap('n', ':', ';', { noremap = true, silent = true })
-- vnoremap ; :
vim.api.nvim_set_keymap('v', ';', ':', { noremap = true, silent = true })
-- vnoremap : ;
vim.api.nvim_set_keymap('v', ':', ';', { noremap = true, silent = true })

-- Easy window navigation
vim.api.nvim_set_keymap('n', '<C-h>', '<C-w>h', { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<C-j>', '<C-w>j', { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<C-k>', '<C-w>k', { noremap = false, silent = true })
vim.api.nvim_set_keymap('n', '<C-l>', '<C-w>l', { noremap = false, silent = true })

-- Easy tab navigation by number
vim.api.nvim_set_keymap('n', '<leader>1', '1gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>2', '2gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>3', '3gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>4', '4gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>5', '5gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>6', '6gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>7', '7gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>8', '8gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>9', '9gt', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<leader>0', ':tablast<cr>', { noremap = true, silent = true })

-- nmap <silent> <leader>/ :nohlsearch<CR>
vim.api.nvim_set_keymap('n', '<leader>/', ':nohlsearch<CR>', { noremap = false, silent = true })
--------------------------------------------------------------

--------------------------------------------------------------
--------- Tabs -----------------------------------------------

-- nmap <silent> <leader>n :tabnew<CR>
vim.api.nvim_set_keymap('n', '<leader>n', ':tabnew<CR>', { noremap = false, silent = true })

--------------------------------------------------------------

--------------------------------------------------------------
--------- Indentation ----------------------------------------

vim.opt.expandtab = true
vim.opt.tabstop = 4     -- a tab is 4 spaces
vim.opt.softtabstop = 4 -- so deletion at an initial tab will remove 4 spaces
vim.opt.shiftwidth = 4  -- number of spaces to use for autoindenting
vim.opt.shiftround = true    -- use multiple of shiftwidth when indenting with '<' and '>'
vim.opt.autoindent = true    -- always set autoindenting on
--set copyindent    -- copy the previous indentation on autoindenting
vim.opt.smartindent = true

--------------------------------------------------------------

--------------------------------------------------------------
--------- Completions ----------------------------------------

vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess = vim.opt.shortmess + { c = true}
vim.api.nvim_set_option('updatetime', 300)

--------------------------------------------------------------

--------------------------------------------------------------
--------- Mundo ----------------------------------------------

-- nnoremap <silent> <leader>g :MundoToggle<CR>
vim.api.nvim_set_keymap('n', '<leader>g', ':MundoToggle<CR>', { noremap = true, silent = true })
-- nnoremap <F5> :MundoToggle<CR>
vim.api.nvim_set_keymap('n', '<F5>', ':MundoToggle<CR>', { noremap = true, silent = false })

-- let g:mundo_right = 1
vim.g.mundo_right = 1

--------------------------------------------------------------

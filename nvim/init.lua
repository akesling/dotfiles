--------------------------------------------------------------
--------- Header ---------------------------------------------
-- Mapleader must be set before any mapping references it.
vim.g.mapleader = ","
vim.g.maplocalleader = "\\"

--------------------------------------------------------------
--------- Plugins (lazy.nvim) --------------------------------
-- Loads the colorscheme too (priority=1000, lazy=false).
require("config.lazy")

--------------------------------------------------------------
--------- Shared base ----------------------------------------
-- Resolve the dotfiles repo via the init.lua symlink and source the
-- portable vim/shared/common.vim that vim and nvim share.
local init_path = debug.getinfo(1, "S").source:sub(2)
local resolved = vim.fn.resolve(init_path)
local dotfiles_src = vim.fn.fnamemodify(resolved, ":h:h")
vim.cmd("source " .. dotfiles_src .. "/vim/shared/common.vim")

--------------------------------------------------------------
--------- Wrap-width shading (nvim-only decoration provider) -

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
        local b = byte_col - 1
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

--------------------------------------------------------------
--------- Completion (nvim-cmp) ------------------------------

vim.opt.completeopt = {'menuone', 'noselect', 'noinsert'}
vim.opt.shortmess = vim.opt.shortmess + { c = true }
vim.opt.updatetime = 300

--------------------------------------------------------------
--------- Mundo ----------------------------------------------

vim.api.nvim_set_keymap('n', '<leader>g', ':MundoToggle<CR>', { noremap = true, silent = true })
vim.api.nvim_set_keymap('n', '<F5>',     ':MundoToggle<CR>', { noremap = true, silent = false })
vim.g.mundo_right = 1

--------------------------------------------------------------
--------- Per-machine overrides ------------------------------

local husk = vim.fn.expand('~/.local/dotfiles/init.lua')
if vim.fn.filereadable(husk) == 1 then
    dofile(husk)
end

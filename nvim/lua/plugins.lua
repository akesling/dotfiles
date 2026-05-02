return {
    -- Apparently requires Lua 5.1 and we have 5.4?
    -- "nvim-neorocks/rocks.nvim",

    -- Reuse the canonical Ethan Schoonover solarized colorscheme that vim
    -- already uses (~/.vim/bundle/vim-colors-solarized via Vundle). Treesitter
    -- groups inherit from the legacy syntax groups, which keeps the palette
    -- tight (no surprise pink/purple/teal accents).
    {
        'altercation/vim-colors-solarized',
        lazy = false,
        priority = 1000,
        config = function()
            -- 16-color terminal palette mode honors the terminal's solarized
            -- palette directly (no truecolor reinterpretation by nvim).
            vim.o.termguicolors = false
            vim.o.background = 'dark'
            vim.g.solarized_termtrans = 1
            vim.cmd.colorscheme 'solarized'
        end,
    },

    "mfussenegger/nvim-dap",

    "simnalamburt/vim-mundo",
}

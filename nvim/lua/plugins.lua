return {
    -- Apparently requires Lua 5.1 and we have 5.4?
    -- "nvim-neorocks/rocks.nvim",
    {
        'maxmx03/solarized.nvim',
        lazy = false,
        priority = 1000,
        ---@type solarized.config
        opts = {},
        config = function(_, opts)
            vim.o.termguicolors = true
            vim.o.background = 'dark'
            require('solarized').setup(opts)
            vim.cmd.colorscheme 'solarized'
        end,
    },

    "mfussenegger/nvim-dap",

    "simnalamburt/vim-mundo",
    "altercation/vim-colors-solarized",
}

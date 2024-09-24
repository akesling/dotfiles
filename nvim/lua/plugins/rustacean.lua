return {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false, -- This plugin is already lazy
    config = function()
        vim.api.nvim_set_keymap('n', '<leader>e', ':RustLsp renderDiagnostic<cr>', { noremap = true, silent = true })

        -- local bufnr = vim.api.nvim_get_current_buf();
        vim.keymap.set(
            "n",
            "<leader>a",
            function()
                vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
                -- or vim.lsp.buf.codeAction() if you don't want grouping.
            end,
            {
                noremap = true,
                silent = true,
                -- buffer = bufnr,
            })
    end,
}

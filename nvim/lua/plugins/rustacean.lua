return {
    'mrcjkb/rustaceanvim',
    version = '^5', -- Recommended
    lazy = false, -- This plugin is already lazy
    config = function()
        -- vim.g.rustaceanvim.server.ra_multiplex.enable = false
        vim.g.rustaceanvim = {
            default_settings = {
                ['rust-analyzer'] = {
                    cachePriming = {
                        enable = false
                    },
                },
            },
            -- server = {
            --     ra_multiplex = {
            --         enable = false,
            --     }
            -- },
        }
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
        -- vim.keymap.set(
        --     "n",
        --     "<leader>f",
        --     function()
        --         local file_path = vim.fn.expand('%:p')
        --         if file_path ~= '' then
        --             print('Formatting buffer: ' .. vim.fn.fnameescape(file_path))
        --             vim.cmd('rustfmt --edition 2021 ' .. vim.fn.fnameescape(file_path))
        --         else
        --             print('Current buffer is not associated with a file.')
        --         end
        --         vim.cmd.RustLsp('codeAction') -- supports rust-analyzer's grouping
        --         -- or vim.lsp.buf.codeAction() if you don't want grouping.
        --     end,
        --     {
        --         noremap = true,
        --         silent = true,
        --         -- buffer = bufnr,
        --     })
    end,
}

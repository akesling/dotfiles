return {
  "dnlhc/glance.nvim",
  config = function()
    local glance = require('glance')
    local actions = glance.actions
    glance.setup({
      -- your configuration
    })

    vim.api.nvim_set_keymap('n', '<leader>t', ':Glance type_definitions<cr>', { noremap = true, silent = true })
    vim.api.nvim_set_keymap('n', '<leader>d', ':Glance definitions<cr>', { noremap = true, silent = true })
  end,
}

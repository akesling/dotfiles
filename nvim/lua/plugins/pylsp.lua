return {
  "neovim/nvim-lspconfig",
  lazy = true,  -- Enable lazy loading for the plugin
  ft = "python",  -- Only load when editing Python files
  config = function()
    local lspconfig = require('lspconfig')

    -- Configure the Python Language Server (pylsp)
    lspconfig.pylsp.setup {
      settings = {
        pylsp = {
          plugins = {
            pyflakes = { enabled = false },
            pylint = { enabled = true },
            jedi_completion = { enabled = true },
          }
        }
      }
    }
  end
}

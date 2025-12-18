return {
    'dlants/magenta.nvim',
    lazy = false, -- you could also bind to <leader>mt
    build = "npm install --frozen-lockfile",
    config = function()
        return require("magenta").setup({
            profiles = {
                {
                    name = "claude-max",
                    provider = "anthropic",
                    model = "claude-sonnet-4-5-20250929",
                    fastModel = "claude-haiku-4-5-20251001",
                    authType = "max" -- Use Anthropic OAuth instead of API key
                    -- No apiKeyEnvVar needed for max auth
                },
            },
    --             -- open chat sidebar on left or right side
    --             sidebarPosition = "left",
    --             -- can be changed to "telescope" or "snacks"
            picker = "telescope",
    --             -- enable default keymaps shown below
    --             defaultKeymaps = true,
    --             -- maximum number of sub-agents that can run concurrently (default: 3)
    --             maxConcurrentSubagents = 3,
    --             -- volume for notification chimes (range: 0.0 to 1.0, default: 0.3)
    --             -- set to 0.0 to disable chimes entirely
    --             chimeVolume = 0.3,
    --             -- glob patterns for files that should be auto-approved for getFile tool
    --             -- (bypasses user approval for hidden/gitignored files matching these patterns)
    --             getFileAutoAllowGlobs = { "node_modules/*" }, -- default includes node_modules
    --             -- keymaps for the sidebar input buffer
    --             sidebarKeymaps = {
    --                 normal = {
    --                     ["<CR>"] = ":Magenta send<CR>",
    --                 }
    --             },
    --             -- keymaps for the inline edit input buffer
    --             -- if keymap is set to function, it accepts a target_bufnr param
    --             inlineKeymaps =  {
    --                 normal = {
    --                 ["<CR>"] = function(target_bufnr)
    --                     vim.cmd("Magenta submit-inline-edit " .. target_bufnr)
    --                 end,
    --                 },
    --             },
    --             -- configure edit prediction options
    --             -- editPrediction = {
    --             --     -- Use a dedicated profile for predictions (optional)
    --             --     -- If not specified, uses the current active profile's model
    --             --     profile = {
    --             --         provider = "anthropic",
    --             --         model = "claude-4-5-haiku-latest",
    --             --         apiKeyEnvVar = "ANTHROPIC_API_KEY"
    --             --     },
    --             --     -- Maximum number of changes to track for context (default: 10)
    --             --     changeTrackerMaxChanges = 20,
    --             --     -- Token budget for including recent changes (default: 1000)
    --             --     recentChangeTokenBudget = 1500,
    --             --     -- Customize the system prompt (optional)
    --             --     -- systemPrompt = "Your custom prediction system prompt here...",
    --             --     -- Add instructions to the default system prompt (optional)
    --             --     systemPromptAppend = "Focus on completing function calls and variable declarations."
    --             -- },
    --             -- configure MCP servers for external tool integrations
    --             -- mcpServers = {
    --             --     fetch = {
    --             --         command = "uvx",
    --             --         args = { "mcp-server-fetch" }
    --             --     },
    --             --     playwright = {
    --             --     command = "pnpm run",
    --             --     args = {
    --             --         "@playwright/mcp@latest"
    --             --     }
    --             --     },
    --             --     -- HTTP-based MCP server example
    --             --     httpServer = {
    --             --     url = "http://localhost:8000/mcp",
    --             --     requestInit = {
    --             --         headers = {
    --             --         Authorization = "Bearer your-token-here",
    --             --         },
    --             --     },
    --             --     }
    --             -- }
        })
    end,
}

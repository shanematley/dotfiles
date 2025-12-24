-- Prepend and append to runtimepath
vim.opt.runtimepath:prepend(vim.fn.expand("~/.vim"))
vim.opt.runtimepath:append(vim.fn.expand("~/.vim/after"))

-- Make packpath follow runtimepath
vim.opt.packpath = vim.opt.runtimepath:get()

-- Source your existing ~/.vimrc
vim.cmd("source ~/.vimrc")

-- disable netrw at the very start of your init.lua
vim.g.loaded_netrw = 1
vim.g.loaded_netrwPlugin = 1

-- optionally enable 24-bit colour
vim.opt.termguicolors = true

vim.keymap.set('n', 'K', vim.lsp.buf.hover, { desc = 'LSP Hover' })

--vim.cmd('source ~/.config/nvim/plug_settings.vim')

require("mason").setup({
    ui = {
        icons = {
            package_installed = "✓",
            package_pending = "➜",
            package_uninstalled = "✗"
        }
    }
})

require("aerial").setup({
  -- optionally use on_attach to set keymaps when aerial has attached to a buffer
  on_attach = function(bufnr)
    -- Jump forwards/backwards with '{' and '}'
    vim.keymap.set("n", "{", "<cmd>AerialPrev<CR>", { buffer = bufnr })
    vim.keymap.set("n", "}", "<cmd>AerialNext<CR>", { buffer = bufnr })
  end,
})
-- You probably also want to set a keymap to toggle aerial
vim.keymap.set("n", "<leader>a", "<cmd>AerialToggle!<CR>")

-- empty setup using defaults
require("nvim-tree").setup()

require("mason-lspconfig").setup()

vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format with LSP' })


local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set('n', '<leader>b', builtin.buffers, { desc = 'Telescope buffers' })
vim.keymap.set('n', '<leader>fh', builtin.help_tags, { desc = 'Telescope help tags' })
vim.keymap.set('n', '<leader>t', builtin.git_files, { desc = 'Telescope git files' })
vim.keymap.set('n', '<leader>hh', builtin.oldfiles, { desc = 'Telescope previously opened files' })
vim.keymap.set('n', '<leader>h/', builtin.search_history, { desc = 'Telescope recent searches' })
vim.keymap.set('n', '<leader>h;', builtin.command_history, { desc = 'Telescope recent commands' })
vim.keymap.set('n', '<leader>gb', builtin.git_branches, { desc = 'Telescope git branches' })
vim.keymap.set('n', '<leader>gs', builtin.git_status, { desc = 'Telescope git status' })
vim.keymap.set('n', '<leader>gt', builtin.git_stash, { desc = 'Telescope git stash' })
vim.keymap.set('n', '<leader>gc', builtin.git_commits, { desc = 'Telescope git commits' })
vim.keymap.set('n', '<leader>gh', builtin.git_bcommits, { desc = 'Telescope buffer git commits' })


vim.keymap.set('n', 'gd', builtin.lsp_definitions, { desc = 'Telescope LSP definitions' })
vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'Telescope LSP implemention' })
vim.keymap.set('n', 'gy', builtin.lsp_type_definitions, { desc = 'Telescope LSP type definitions' })
vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = 'Telescope LSP references' })
vim.keymap.set('n', 'gs', builtin.lsp_document_symbols, { desc = 'Telescope document symbols' })

local function clangd_switch_source_header()
  local bufnr = vim.api.nvim_get_current_buf()
  local clients = vim.lsp.get_clients({ name = "clangd", bufnr = bufnr })
  if #clients == 0 then
    vim.notify("clangd not attached to this buffer", vim.log.levels.WARN)
    return
  end

  local uri = vim.uri_from_bufnr(bufnr)

  clients[1].request("workspace/executeCommand", {
    command = "clangd.switchSourceHeader",
    arguments = { uri },
  }, function(err, result)
    if err then
      vim.notify(("clangd switchSourceHeader error: %s"):format(err.message), vim.log.levels.ERROR)
      return
    end
    if not result or result == "" then
      vim.notify("No corresponding source/header found", vim.log.levels.INFO)
      return
    end

    local fname = vim.uri_to_fname(result)
    vim.cmd.edit(fname)
  end, bufnr)
end

vim.keymap.set("n", "<leader>s", clangd_switch_source_header, { desc = "clangd: Switch source/header" })
-- Equivalent of "gra"
vim.keymap.set("n", "<leader>.", vim.lsp.buf.code_action, { desc = "LSP code action" })

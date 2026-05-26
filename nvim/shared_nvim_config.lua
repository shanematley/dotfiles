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
vim.keymap.set("n", "<leader>d", function()
    vim.diagnostic.setloclist()
    vim.cmd("lopen")
end, { desc = "Show diagnostics for current file" })

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

local function detect_jdtls_java_home()
    if vim.g.jdtls_java_home and vim.g.jdtls_java_home ~= "" then return vim.g.jdtls_java_home end
    local from_jdtls_env = os.getenv("JDTLS_JAVA_HOME")
    if from_jdtls_env and from_jdtls_env ~= "" then return from_jdtls_env end
    local from_java_home = os.getenv("JAVA_HOME")
    if from_java_home and from_java_home ~= "" then return from_java_home end
    local java_path = vim.fn.exepath("java")
    if java_path ~= "" then return vim.fn.fnamemodify(java_path, ":h:h") end
    return nil
end
local jdtls_java_home = detect_jdtls_java_home()
if jdtls_java_home then
  local jdtls_settings = {
    java = {
      autobuild = { enabled = false },
      import = {
        gradle = { enabled = false },
        maven = { enabled = false },
      },
      jdt = {
        ls = { java = { home = jdtls_java_home } },
      },
    },
  }

  vim.lsp.config('jdtls', {
    cmd = function(dispatchers, config)
      local data_dir = vim.fn.expand("~/.cache/jdtls/workspace")
      if config.root_dir then
        data_dir = data_dir .. '/' .. vim.fn.fnamemodify(config.root_dir, ':p:h:t')
      end
      return vim.lsp.rpc.start({
        'jdtls',
        '--java-executable', jdtls_java_home .. '/bin/java',
        '-data', data_dir,
        '--jvm-arg=-XX:+UseParallelGC',
        '--jvm-arg=-Xmx16G',
        '--jvm-arg=-Xms2G',
      }, dispatchers, {
        cwd = config.cmd_cwd,
        env = config.cmd_env,
        detached = config.detached,
      })
    end,
    root_markers = { 'WORKSPACE', 'MODULE.bazel', 'pom.xml', '.git' },
    on_init = function(client)
      -- jdtls registers definitionProvider dynamically; force it for Telescope compatibility
      client.server_capabilities.definitionProvider = true
    end,
    init_options = { settings = jdtls_settings },
    settings = jdtls_settings,
  })
  vim.lsp.enable('jdtls')
else
  vim.notify(
    "jdtls disabled: set vim.g.jdtls_java_home, JDTLS_JAVA_HOME, JAVA_HOME, or put java on PATH.",
    vim.log.levels.WARN
  )
end

local function detect_clangd_path()
    if vim.g.clangd_path and vim.g.clangd_path ~= "" then return vim.g.clangd_path end
    local from_env = os.getenv("CLANGD_PATH")
    if from_env and from_env ~= "" then return from_env end
    local on_path = vim.fn.exepath("clangd")
    if on_path ~= "" then return on_path end
    return nil
end
local clangd_path = detect_clangd_path()
if clangd_path then
  vim.lsp.config('clangd', {
    cmd = { clangd_path, '--background-index' },
    root_markers = { 'compile_commands.json', '.clangd', 'WORKSPACE', '.git' },
  })
  vim.lsp.enable('clangd')
else
  vim.notify(
    "clangd disabled: set vim.g.clangd_path, CLANGD_PATH, or put clangd on PATH.",
    vim.log.levels.WARN
  )
end

local function detect_pyright_path()
    if vim.g.pyright_path and vim.g.pyright_path ~= "" then return vim.g.pyright_path end
    local from_env = os.getenv("PYRIGHT_PATH")
    if from_env and from_env ~= "" then return from_env end
    local on_path = vim.fn.exepath("pyright-langserver")
    if on_path ~= "" then return on_path end
    return nil
end
local pyright_path = detect_pyright_path()
if pyright_path then
  vim.lsp.config('pyright', {
    cmd = { pyright_path, '--stdio' },
    root_markers = { 'pyproject.toml', 'setup.py', 'setup.cfg', 'requirements.txt', 'Pipfile', 'pyrightconfig.json', '.git' },
    settings = {
      python = {
        analysis = {
          autoSearchPaths = true,
          useLibraryCodeForTypes = true,
          diagnosticMode = 'openFilesOnly',
        },
      },
    },
  })
  vim.lsp.enable('pyright')
else
  vim.notify(
    "pyright disabled: set vim.g.pyright_path, PYRIGHT_PATH, or put pyright-langserver on PATH.",
    vim.log.levels.WARN
  )
end

local function detect_ruff_path()
    if vim.g.ruff_path and vim.g.ruff_path ~= "" then return vim.g.ruff_path end
    local from_env = os.getenv("RUFF_PATH")
    if from_env and from_env ~= "" then return from_env end
    local on_path = vim.fn.exepath("ruff")
    if on_path ~= "" then return on_path end
    return nil
end
local ruff_path = detect_ruff_path()
if ruff_path then
  vim.lsp.config('ruff', {
    cmd = { ruff_path, 'server' },
    root_markers = { 'pyproject.toml', 'ruff.toml', '.ruff.toml', '.git' },
    -- Defer hover to pyright when both are attached
    on_attach = function(client)
      client.server_capabilities.hoverProvider = false
    end,
  })
  vim.lsp.enable('ruff')
else
  vim.notify(
    "ruff disabled: set vim.g.ruff_path, RUFF_PATH, or put ruff on PATH.",
    vim.log.levels.WARN
  )
end

require("mason-lspconfig").setup()

vim.keymap.set('n', '<leader>f', function()
  vim.lsp.buf.format({ async = true })
end, { desc = 'Format with LSP' })


-- Handle jdt:// URIs so gd can jump into dependency sources/decompiled classes
vim.api.nvim_create_autocmd('BufReadCmd', {
  pattern = 'jdt://*',
  callback = function(ev)
    local uri = ev.match
    local clients = vim.lsp.get_clients({ name = 'jdtls' })
    if #clients == 0 then return end
    local content = clients[1].request_sync(
      'java/classFileContents', { uri = uri }, 5000
    )
    if content and content.result then
      local lines = vim.split(content.result, '\n')
      vim.api.nvim_buf_set_lines(ev.buf, 0, -1, false, lines)
      vim.bo[ev.buf].filetype = 'java'
      vim.bo[ev.buf].modifiable = false
      vim.bo[ev.buf].buftype = 'nofile'
    end
  end,
})

local utils = require("telescope.utils")
require('telescope').setup({
    defaults = {
        path_display = { "smart" },
        symbol_width = 60,
    },
    pickers = {
        git_files = {
            -- path_display = { "smart" },
            path_display = function(_, path)
                local tail = utils.path_tail(path)
                local parent = utils.path_smart(path:match("(.*/)") or "")
                if parent == "" then
                    return tail
                end
                return string.format("%s    %s", tail, parent)
            end,
        },
    },
})
local builtin = require('telescope.builtin')
vim.keymap.set('n', '<leader>ff', builtin.find_files, { desc = 'Telescope find files' })
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
-- vim.keymap.set('n', '<leader>fg', builtin.live_grep, { desc = 'Telescope live grep' })
vim.keymap.set("n", "<leader>fg", function()
    require("telescope.builtin").live_grep({
        mappings = {
            i = {
                ["<C-Space>"] = require("telescope.actions").to_fuzzy_refine,
            },
        },
    })
end, { desc = "Live grep then fuzzy refine" })

vim.keymap.set("n", "<leader>q", function()
    require("telescope.builtin").live_grep({
        default_text = vim.fn.expand("<cword>"),
        mappings = {
            i = {
                ["<C-Space>"] = require("telescope.actions").to_fuzzy_refine,
            },
        },
    })
end, { desc = "Live grep word under cursor" })


vim.keymap.set('n', 'gd', function()
    builtin.lsp_definitions({ jump_type = "never" })
end, { desc = 'Telescope LSP definitions' })
vim.keymap.set('n', 'gi', builtin.lsp_implementations, { desc = 'Telescope LSP implemention' })
vim.keymap.set('n', 'gy', builtin.lsp_type_definitions, { desc = 'Telescope LSP type definitions' })
vim.keymap.set('n', 'gr', builtin.lsp_references, { desc = 'Telescope LSP references' })
vim.keymap.set('n', 'gs', builtin.lsp_document_symbols, { desc = 'Telescope document symbols' })
vim.keymap.set('n', '<leader>ci', builtin.lsp_incoming_calls, { desc = 'Telescope LSP incoming calls' })
vim.keymap.set('n', '<leader>co', builtin.lsp_outgoing_calls, { desc = 'Telescope LSP outgoing calls' })
vim.keymap.set('n', '<leader>qq', builtin.quickfix,        { desc = 'Telescope quickfix entries' })
vim.keymap.set('n', '<leader>qs', builtin.quickfixhistory, { desc = 'Telescope quickfix stack' })

vim.api.nvim_create_autocmd({ "LspProgress", "LspAttach", "LspDetach" }, {
    callback = function()
        if vim.fn.exists("*lightline#update") == 1 then
            vim.fn["lightline#update"]()
        end
    end,
})

vim.api.nvim_set_hl(0, "LspReferenceText",  { bg = "#ffff00", fg = "#000000", bold = true, underline = true })
vim.api.nvim_set_hl(0, "LspReferenceRead",  { bg = "#ffff00", fg = "#000000", underline = true })
vim.api.nvim_set_hl(0, "LspReferenceWrite", { bg = "#ffff00", fg = "#000000", underline = true })

vim.api.nvim_create_autocmd("LspAttach", {
    callback = function(args)
        local client = vim.lsp.get_client_by_id(args.data.client_id)
        if not client or not client.server_capabilities.documentHighlightProvider then
            return
        end
        local group = vim.api.nvim_create_augroup("lsp_document_highlight", { clear = false })
        vim.api.nvim_create_autocmd({ "CursorHold", "CursorHoldI" }, {
            buffer = args.buf,
            group = group,
            callback = vim.lsp.buf.document_highlight,
        })
        vim.api.nvim_create_autocmd({ "CursorMoved", "CursorMovedI" }, {
            buffer = args.buf,
            group = group,
            callback = vim.lsp.buf.clear_references,
        })
    end,
})

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

set runtimepath^=~/.vim runtimepath+=~/.vim/after
let &packpath=&runtimepath
source ~/.vimrc

"lua << EOF
"local bazel = require("bazel")
"-- local my_bazel = require("config.bazel")
"local map = vim.keymap.set
"vim.api.nvim_create_autocmd("FileType", { pattern = "bzl", callback = function() map("n", "gd", vim.fn.GoToBazelDefinition, { buffer = true, desc = "Goto Definition" }) end, })
"-- vim.api.nvim_create_autocmd("FileType", { pattern = "bzl", callback = function() map("n", "<Leader>y", my_bazel.YankLabel, { desc = "Bazel Yank Label" }) end, })
"map("n", "gbt", vim.fn.GoToBazelTarget, { desc = "Goto Bazel Build File" })
"map("n", "<Leader>bl", bazel.run_last, { desc = "Bazel Last" })
"-- map("n", "<Leader>bdt", my_bazel.DebugTest, { desc = "Bazel Debug Test" })
"-- map("n", "<Leader>bdr", my_bazel.DebugRun, { desc = "Bazel Debug Run" })
"map("n", "<Leader>bt", function() bazel.run_here("test", vim.g.bazel_config) end, { desc = "Bazel Test" })
"map("n", "<Leader>bb", function() bazel.run_here("build", vim.g.bazel_config) end, { desc = "Bazel Build" })
"map("n", "<Leader>br", function() bazel.run_here("run", vim.g.bazel_config) end, { desc = "Bazel Run" })
"map("n", "<Leader>bdb", function() bazel.run_here("build", vim.g.bazel_config .. " --compilation_mode dbg --copt=-O0") end, { desc = "Bazel Debug Build" })
"-- map("n", "<Leader>bda", my_bazel.set_debug_args_from_input, { desc = "Set Bazel Debug Arguments" })
"EOF

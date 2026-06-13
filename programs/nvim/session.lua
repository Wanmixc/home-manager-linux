-- auto-session
vim.o.sessionoptions = vim.o.sessionoptions .. ",localoptions"

require("auto-session").setup({
  log_level = "info",
  auto_session_suppress_dirs = { "~/", "~/projects" },
})

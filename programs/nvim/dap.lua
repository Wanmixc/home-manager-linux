-- dap
vim.keymap.set("n", "<F5>", ":lua require'dap'.continue() <CR>")
vim.keymap.set("n", "<F3>", ":lua require'dap'.step_over() <CR>")
vim.keymap.set("n", "<F2>", ":lua require'dap'.step_into() <CR>")
vim.keymap.set("n", "<F4>", ":lua require'dap'.step_out() <CR>")
vim.keymap.set("n", "<leader>b", ":lua require'dap'.toggle_breakpoint() <CR>")
vim.keymap.set("n", "<leader>B", ":lua require'dap'.set_breakpoint(vim.fn.input('Breakpoint condition: ')) <CR>")
vim.keymap.set(
  "n",
  "<leader>dm",
  ":lua require'dap'.set_breakpoint(nil, nil, vim.fn.input('Log point message: ')) <CR>"
)
vim.keymap.set("n", "<leader>dr", ":lua require'dap'.repl.open() <CR>")
vim.keymap.set("n", "<leader>do", ":lua require'dapui'.toggle() <CR>")

require("nvim-dap-virtual-text").setup()
require("dap-go").setup()
require("dapui").setup()

local dap = require("dap")

dap.configurations.rust = {
  {
    type = "codelldb",
    request = "launch",
    program = function()
      return vim.fn.input("Path to executable: ", vim.fn.getcwd() .. "/", "file")
    end,
    cwd = "${workspaceFolder}",
    terminal = "integrated",
    sourceLanguages = { "rust" },
  },
}

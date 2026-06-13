-- indent-blankline
vim.opt.termguicolors = true

local highlight = {
  "RainbowRed",
  "RainbowYellow",
  "RainbowBlue",
  "RainbowGreen",
  "RainbowViolet",
  "RainbowCyan",
}

require("ibl").setup({
  exclude = {
    filetypes = { "help", "terminal", "dashboard", "lazy" },
  },
  scope = { enabled = false },
  indent = { highlight = highlight },
})

-- treesitter
vim.g.skip_ts_context_commentstring_module = true

require("ts_context_commentstring").setup({
  enable_autocmd = false,
})

vim.filetype.add({ extension = { wgsl = "wgsl" } })
vim.filetype.add({ extension = { astro = "astro" } })

require("nvim-treesitter.configs").setup({
  autotag = {
    enable = true,
  },
  indent = {
    enable = true,
  },
  highlight = {
    enable = true,
  },
  incremental_selection = {
    enable = true,
  },
  textobjects = {
    enable = true,
  },
  context_commentstring = {
    enable = false,
    enable_autocmd = false,
  },
  playground = {
    enable = true,
    disable = {},
    updatetime = 25,
    persist_queries = false,
  },
})

local rainbow_delimiters = require("rainbow-delimiters")

vim.g.rainbow_delimiters = {
  strategy = {
    [""] = rainbow_delimiters.strategy["global"],
    vim = rainbow_delimiters.strategy["local"],
  },
  query = {
    [""] = "rainbow-delimiters",
    lua = "rainbow-blocks",
  },
  highlight = {
    "RainbowRed",
    "RainbowYellow",
    "RainbowBlue",
    "RainbowGreen",
    "RainbowViolet",
    "RainbowCyan",
  },
}

-- Neovim 0.12 Minimal Config — built-in only, VSCode-like
-- =====================================================================

-- [[ Colorscheme — built-in dark theme ]] --
vim.cmd.colorscheme("quiet")

-- [[ Treesitter — built-in syntax highlighting & folding ]] --
vim.opt.foldmethod = "expr"
vim.opt.foldexpr = "v:lua.vim.treesitter.foldexpr()"
vim.opt.foldlevel = 99

-- auto-install parsers on first open, then enable treesitter
local ensured_parsers = { "lua", "python", "javascript", "typescript", "json", "html", "css", "markdown", "yaml", "bash" }
local function ensure_parsers()
  for _, lang in ipairs(ensured_parsers) do
    pcall(vim.treesitter.language.add, lang)
  end
  pcall(vim.treesitter.start)
end

-- attempt parsers immediately, but don't crash if unavailable
local ok = pcall(ensure_parsers)
if not ok then
  -- parsers not available yet; try again on first file open
  vim.api.nvim_create_autocmd("BufReadPost", {
    once = true,
    callback = function()
      pcall(ensure_parsers)
    end,
  })
end

-- [[ Basic options ]]
vim.opt.number = true
vim.opt.relativenumber = true
vim.opt.cursorline = true
vim.opt.wrap = false
vim.opt.scrolloff = 10
vim.opt.sidescrolloff = 8

vim.opt.tabstop = 2
vim.opt.shiftwidth = 2
vim.opt.softtabstop = 2
vim.opt.expandtab = true
vim.opt.smartindent = true

vim.opt.ignorecase = true
vim.opt.smartcase = true
vim.opt.hlsearch = false
vim.opt.incsearch = true

vim.opt.termguicolors = true
vim.opt.signcolumn = "yes"
vim.opt.colorcolumn = "100"
vim.opt.showmode = false
vim.opt.completeopt = "menuone,noinsert,noselect"

vim.opt.backup = false
vim.opt.swapfile = false
vim.opt.undofile = true
vim.opt.undodir = vim.fn.expand("~/.vim/undodir")
vim.opt.updatetime = 300
vim.opt.hidden = true
vim.opt.mouse = "a"
vim.opt.clipboard:append("unnamedplus")
vim.opt.splitbelow = true
vim.opt.splitright = true
vim.opt.path:append("**")

-- [[ Fuzzy file finder — built-in, zero deps ]] --
local function fuzzy_find_files()
  local root = vim.fn.getcwd()
  local results = vim.fs.find(function(name)
    return name:match("%.[a-zA-Z0-9]+$")
      and not name:match("node_modules")
      and not name:match("%.git/")
  end, { path = root, type = "file", depth = 10 })

  if #results == 0 then
    print("no files found")
    return
  end

  local items = {}
  for _, p in ipairs(results) do
    items[p] = p
  end

  vim.ui.select(results, {
    prompt = "find file: ",
    format_item = function(item)
      return vim.fn.fnamemodify(item, ":.")
    end,
  }, function(choice)
    if choice then
      vim.cmd("edit " .. vim.fn.fnameescape(choice))
    end
  end)
end

vim.keymap.set("n", "<leader>ff", fuzzy_find_files, { desc = "find file (fuzzy)" })

-- [[ Live grep — built-in :grep with quickfix ]] --
vim.keymap.set("n", "<leader>sg", function()
  vim.ui.input({ prompt = "grep: " }, function(query)
    if query and query ~= "" then
      vim.cmd("grep -r " .. vim.fn.shellescape(query) .. " .")
      vim.cmd("cwindow")
    end
  end)
end, { desc = "live grep" })

-- [[ File explorer (netrw) ]] --
vim.g.netrw_banner = 0
vim.g.netrw_liststyle = 3
vim.g.netrw_browse_split = 4
vim.g.netrw_winsize = 25
vim.keymap.set("n", "<leader>e", ":Explore<CR>", { desc = "file explorer" })

-- [[ LSP ]] --
local function find_root(patterns)
  local path = vim.fn.expand("%:p:h")
  local root = vim.fs.find(patterns, { path = path, upward = true })[1]
  return root and vim.fn.fnamemodify(root, ":h") or path
end

-- auto-start LSP per filetype
local lsp_attach = function(client, bufnr)
  local opts = { buffer = bufnr }
  vim.keymap.set("n", "gD", vim.lsp.buf.definition, opts)
  vim.keymap.set("n", "gr", vim.lsp.buf.references, opts)
  vim.keymap.set("n", "K", vim.lsp.buf.hover, opts)
  vim.keymap.set("n", "<leader>ca", vim.lsp.buf.code_action, opts)
  vim.keymap.set("n", "<leader>rn", vim.lsp.buf.rename, opts)
  vim.keymap.set("n", "<leader>nd", vim.diagnostic.goto_next, opts)
  vim.keymap.set("n", "<leader>pd", vim.diagnostic.goto_prev, opts)
end

vim.api.nvim_create_autocmd("FileType", {
  pattern = "sh,bash,zsh",
  callback = function()
    vim.lsp.start({
      name = "bashls",
      cmd = { "bash-language-server", "start" },
      filetypes = { "sh", "bash", "zsh" },
      root_dir = find_root({ ".git" }),
    })
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  pattern = "python",
  callback = function()
    vim.lsp.start({
      name = "pylsp",
      cmd = { "pylsp" },
      filetypes = { "python" },
      root_dir = find_root({ "pyproject.toml", "setup.py", ".git" }),
    })
  end,
})

vim.api.nvim_create_autocmd("LspAttach", {
  callback = function(args)
    local client = vim.lsp.get_client_by_id(args.data.client_id)
    if client then
      lsp_attach(client, args.buf)
    end
  end,
})

vim.diagnostic.config({
  virtual_text = { prefix = "●" },
  signs = true,
  underline = true,
  severity_sort = true,
})

-- [[ Keymaps ]] --
vim.g.mapleader = " "
vim.keymap.set("i", "jj", "<Esc>")

-- clear search
vim.keymap.set("n", "<leader>c", ":nohlsearch<CR>", { desc = "clear search" })

-- center on jumps
vim.keymap.set("n", "n", "nzzzv")
vim.keymap.set("n", "N", "Nzzzv")
vim.keymap.set("n", "<C-d>", "<C-d>zz")
vim.keymap.set("n", "<C-u>", "<C-u>zz")

-- delete without yanking
vim.keymap.set({ "n", "v" }, "<leader>d", '"_d', { desc = "delete without yank" })

-- buffer nav
vim.keymap.set("n", "<leader>bn", ":bnext<CR>", { desc = "next buffer" })
vim.keymap.set("n", "<leader>bp", ":bprevious<CR>", { desc = "prev buffer" })

-- window nav
vim.keymap.set("n", "<C-h>", "<C-w>h")
vim.keymap.set("n", "<C-j>", "<C-w>j")
vim.keymap.set("n", "<C-k>", "<C-w>k")
vim.keymap.set("n", "<C-l>", "<C-w>l")

-- splits
vim.keymap.set("n", "<leader>sv", ":vsplit<CR>", { desc = "vsplit" })
vim.keymap.set("n", "<leader>sh", ":split<CR>", { desc = "split" })
vim.keymap.set("n", "<C-Up>", ":resize +2<CR>")
vim.keymap.set("n", "<C-Down>", ":resize -2<CR>")
vim.keymap.set("n", "<C-Left>", ":vertical resize -2<CR>")
vim.keymap.set("n", "<C-Right>", ":vertical resize +2<CR>")

-- move lines
vim.keymap.set("n", "<A-j>", ":m .+1<CR>==")
vim.keymap.set("n", "<A-k>", ":m .-2<CR>==")
vim.keymap.set("v", "<A-j>", ":m '>+1<CR>gv=gv")
vim.keymap.set("v", "<A-k>", ":m '<-2<CR>gv=gv")

-- indent reselect
vim.keymap.set("v", "<", "<gv")
vim.keymap.set("v", ">", ">gv")

-- save & quit
vim.keymap.set("n", "<leader>w", ":write<CR>")
vim.keymap.set("n", "<leader>q", ":quit<CR>")
vim.keymap.set("n", "<leader>x", ":qa<CR>")

-- floating terminal (toggle)
local function floating_term()
  local buf = vim.api.nvim_create_buf(false, true)
  local width = math.floor(vim.o.columns * 0.8)
  local height = math.floor(vim.o.lines * 0.8)
  local row = math.floor((vim.o.lines - height) / 2)
  local col = math.floor((vim.o.columns - width) / 2)

  local win = vim.api.nvim_open_win(buf, true, {
    relative = "editor",
    width = width,
    height = height,
    row = row,
    col = col,
    style = "minimal",
    border = "rounded",
  })
  vim.fn.termopen("fish")
  vim.cmd("startinsert")

  vim.api.nvim_create_autocmd("BufLeave", {
    buffer = buf,
    once = true,
    callback = function()
      pcall(vim.api.nvim_win_close, win, false)
    end,
  })
end
vim.keymap.set("n", "<leader>t", floating_term, { desc = "floating terminal" })

-- [[ Autocommands ]] --
local augroup = vim.api.nvim_create_augroup("UserConfig", {})

vim.api.nvim_create_autocmd("TextYankPost", {
  group = augroup,
  callback = function()
    vim.highlight.on_yank()
  end,
})

vim.api.nvim_create_autocmd("BufReadPost", {
  group = augroup,
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- indent per filetype
vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "lua", "python" },
  callback = function()
    vim.opt_local.tabstop = 4
    vim.opt_local.shiftwidth = 4
  end,
})

vim.api.nvim_create_autocmd("FileType", {
  group = augroup,
  pattern = { "javascript", "typescript", "json", "html", "css" },
  callback = function()
    vim.opt_local.tabstop = 2
    vim.opt_local.shiftwidth = 2
  end,
})

-- auto close terminal on exit
vim.api.nvim_create_autocmd("TermClose", {
  group = augroup,
  callback = function()
    if vim.v.event.status == 0 then
      pcall(vim.api.nvim_buf_delete, 0, {})
    end
  end,
})

vim.api.nvim_create_autocmd("VimResized", {
  group = augroup,
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- create dir on save
vim.api.nvim_create_autocmd("BufWritePre", {
  group = augroup,
  callback = function()
    local dir = vim.fn.expand("<afile>:p:h")
    if vim.fn.isdirectory(dir) == 0 then
      vim.fn.mkdir(dir, "p")
    end
  end,
})

-- [[ Statusline ]] --
local function mode_icon()
  local map = { n = "NORMAL", i = "INSERT", v = "VISUAL", V = "V-LINE", [""] = "V-BLOCK", c = "COMMAND", t = "TERMINAL" }
  return map[vim.fn.mode()] or vim.fn.mode():upper()
end

local function git_branch()
  local branch = vim.fn.system("git branch --show-current 2>/dev/null | tr -d '\n'")
  return branch ~= "" and "  " .. branch .. " " or ""
end

_G.mode_icon = mode_icon
_G.git_branch = git_branch

vim.api.nvim_create_autocmd({ "WinEnter", "BufEnter" }, {
  callback = function()
    vim.opt_local.statusline = table.concat {
      "  ", "%#StatusLineBold#", "%{v:lua.mode_icon()}",
      "%#StatusLine#", " │ ", "%f %h%m%r",
      "%{v:lua.git_branch()}",
      "%=", "%l:%c  %P ",
    }
  end,
})

vim.api.nvim_create_autocmd({ "WinLeave", "BufLeave" }, {
  callback = function()
    vim.opt_local.statusline = "  %f %h%m%r │ %=  %l:%c %P "
  end,
})

vim.api.nvim_set_hl(0, "StatusLineBold", { bold = true })

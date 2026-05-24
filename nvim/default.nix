{
  config,
  pkgs,
  lib,
  ...
}:
let
  pluginGit = owner: repo: rev: hash:
    pkgs.vimUtils.buildVimPlugin {
      pname = repo;
      version = rev;
      src = pkgs.fetchFromGitHub {
        inherit owner repo rev hash;
      };
    };

  keymapConfig = pkgs.vimUtils.buildVimPlugin {
    name = "keymap-config";
    src = ./keymapconfig;
  };

  neovimConfig = pkgs.vimUtils.buildVimPlugin {
    name = "neovim-config";
    src = ./config;
  };

  inherit (pkgs.vimPlugins)
    dracula-vim
    nvim-lspconfig
    cmp-nvim-lsp
    cmp-buffer
    nvim-cmp
    luasnip
    lspkind-nvim
    null-ls-nvim
    markdown-preview-nvim
    nvim-jdtls
    dressing-nvim
    rustaceanvim
    nvim-notify
    neoconf-nvim
    nvim-tree-lua
    nvim-web-devicons
    bufferline-nvim
    toggleterm-nvim
    indent-blankline-nvim
    rainbow-delimiters-nvim
    promise-async
    nvim-ufo
    lualine-nvim
    nvim-colorizer-lua
    octo-nvim
    vim-fugitive
    gitsigns-nvim
    trouble-nvim
    vim-dadbod
    vim-dadbod-ui
    vim-dadbod-completion
    otter-nvim
    cmp-tabnine
    nvim-autopairs
    comment-nvim
    nvim-ts-context-commentstring
    nvim-ts-autotag
    vim-move
    vim-visual-multi
    vim-surround
    telescope-nvim
    auto-save-nvim
    refactoring-nvim
    nvim-spectre
    auto-session
    nvim-dap
    nvim-dap-ui
    nvim-dap-virtual-text
    telescope-dap-nvim
    nvim-dap-go
    popup-nvim
    plenary-nvim
    registers-nvim
    vim-suda
    nui-nvim
    harpoon
    vim-sneak
    nvim-config-local
    playground
    nvim-treesitter
    nvim-treesitter-parsers
    # vim-wakatime removed (no API key configured)
  ;

in
{
  programs.neovim = {
    enable = true;
    viAlias = true;
    vimAlias = true;

    plugins = [
      {
        plugin = neovimConfig;
        type = "lua";
        config = builtins.readFile ./config.lua;
      }
      # theme
      {
        plugin = dracula-vim;
        type = "lua";
        config = builtins.readFile ./color.lua;
      }
      # keymap
      {
        plugin = keymapConfig;
        type = "lua";
        config = builtins.readFile ./keymap.lua;
      }
      # lsp
      {
        plugin = nvim-lspconfig;
        type = "lua";
        config = builtins.readFile ./lsp.lua;
      }
      cmp-nvim-lsp
      cmp-buffer
      nvim-cmp
      luasnip
      lspkind-nvim
      null-ls-nvim
      markdown-preview-nvim
      nvim-jdtls

      # language specific (GitHub-fetched plugins removed — fix hashes to re-enable)
      # rainbow_csv
      # jupynium.nvim
      dressing-nvim
      rustaceanvim
      nvim-notify
      # vim-android removed (placeholder hash)
      neoconf-nvim

      # file tree
      {
        plugin = nvim-tree-lua;
        type = "lua";
        config = builtins.readFile ./filetree.lua;
      }
      nvim-web-devicons

      # buffer
      {
        plugin = bufferline-nvim;
        type = "lua";
        config = builtins.readFile ./bufferline.lua;
      }
      {
        plugin = toggleterm-nvim;
        type = "lua";
        config = builtins.readFile ./toggleterm.lua;
      }

      # cosmetic
      {
        plugin = indent-blankline-nvim;
        type = "lua";
        config = builtins.readFile ./indentline.lua;
      }
      rainbow-delimiters-nvim
      promise-async
      {
        plugin = nvim-ufo;
        type = "lua";
        config = builtins.readFile ./fold.lua;
      }
      {
        plugin = lualine-nvim;
        type = "lua";
        config = builtins.readFile ./lualine.lua;
      }
      {
        plugin = nvim-colorizer-lua;
        type = "lua";
        config = ''
          require("colorizer").setup()
        '';
      }

      # git
      octo-nvim
      vim-fugitive
      # blamer.nvim removed (fix hash to re-enable)
      {
        plugin = gitsigns-nvim;
        type = "lua";
        config = builtins.readFile ./gitsigns.lua;
      }
      {
        plugin = trouble-nvim;
        type = "lua";
        config = "require('trouble').setup()";
      }

      # database
      vim-dadbod
      vim-dadbod-ui
      vim-dadbod-completion
      otter-nvim

      # completion
      cmp-tabnine

      # auto
      {
        plugin = nvim-autopairs;
        type = "lua";
        config = builtins.readFile ./autopairs.lua;
      }

      # quality of life
      {
        plugin = comment-nvim;
        type = "lua";
        config = builtins.readFile ./comment.lua;
      }
      nvim-ts-context-commentstring
      nvim-ts-autotag
      vim-move
      vim-visual-multi
      vim-surround
      {
        plugin = telescope-nvim;
        type = "lua";
        config = builtins.readFile ./telescope.lua;
      }
      {
        plugin = auto-save-nvim;
        type = "lua";
        config = builtins.readFile ./autosave.lua;
      }
      {
        plugin = refactoring-nvim;
        type = "lua";
        config = builtins.readFile ./refactoring.lua;
      }
      {
        plugin = nvim-spectre;
        type = "lua";
        config = builtins.readFile ./spectre.lua;
      }

      # session
      {
        plugin = auto-session;
        type = "lua";
        config = builtins.readFile ./session.lua;
      }

      # debugger
      {
        plugin = nvim-dap;
        type = "lua";
        config = builtins.readFile ./dap.lua;
      }
      nvim-dap-ui
      nvim-dap-virtual-text
      telescope-dap-nvim
      nvim-dap-go
      # vim-maximizer removed (outdated hash)

      # misc
      popup-nvim
      plenary-nvim
      registers-nvim
      vim-suda
      nui-nvim
      {
        plugin = harpoon;
        type = "lua";
        config = builtins.readFile ./harpoon.lua;
      }
      vim-sneak
      {
        plugin = nvim-config-local;
        type = "lua";
        config = builtins.readFile ./local.lua;
      }

      # fine-cmdline.nvim removed (fix hash to re-enable)
      # twoslash-queries.nvim removed (fix hash to re-enable)
      # mdx.nvim removed (fix hash to re-enable)

      playground
      {
        plugin = (
          nvim-treesitter.withPlugins (
            _:
            nvim-treesitter.allGrammars
            ++ [
              nvim-treesitter-parsers.wgsl
              nvim-treesitter-parsers.astro
            ]
          )
        );
        type = "lua";
        config = builtins.readFile ./treesitter.lua;
      }
      # vim-wakatime removed (no API key configured)
    ];
  };
}

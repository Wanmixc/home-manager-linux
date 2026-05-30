{ config, pkgs, lib, ... }:
let
  secrets = builtins.fromJSON (builtins.readFile ./secrets.json);
  deepseek-tui-src = pkgs.fetchFromGitHub {
    owner = "Hmbown";
    repo = "CodeWhale";
    rev = "v0.8.44";
    hash = "sha256-gdwDAs1xmSII4Ps2DFYNR4XB64lhUjMYldFEoMENl8w=";
  };

  deepseek-cli = pkgs.rustPlatform.buildRustPackage {
    pname = "deepseek-tui-cli";
    version = "0.8.44";
    src = deepseek-tui-src;
    cargoLock.lockFile = "${deepseek-tui-src}/Cargo.lock";
    cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.dbus ];
    buildAndTestSubdir = "crates/cli";
    doCheck = false;
  };

  deepseek-tui = pkgs.rustPlatform.buildRustPackage {
    pname = "deepseek-tui";
    version = "0.8.44";
    src = deepseek-tui-src;
    cargoLock.lockFile = "${deepseek-tui-src}/Cargo.lock";
    cargoHash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
    nativeBuildInputs = [ pkgs.pkg-config ];
    buildInputs = [ pkgs.dbus ];
    buildAndTestSubdir = "crates/tui";
    doCheck = false;
  };

  deepseek-tui-combined = pkgs.symlinkJoin {
    name = "deepseek-tui-combined-0.8.44";
    paths = [
     deepseek-cli
     deepseek-tui
   ];
  };

  hermes-wheel = pkgs.fetchurl {
    url = "https://github.com/NousResearch/hermes-agent/releases/download/v2026.5.29.2/hermes_agent-0.15.2-py3-none-any.whl";
    hash = "sha256-FISwv2bSacjZAzZQm0GpwQQfx+YSTxON9xwkipVc3Ds=";
  };

  hermes-agent = pkgs.writeShellScriptBin "hermes" ''
    HERMES_VENV="$HOME/.local/share/hermes-agent"
    WHEEL="${hermes-wheel}"

    if [ ! -x "$HERMES_VENV/bin/hermes" ]; then
      echo "⚡ Bootstrapping Hermes Agent..."
      rm -rf "$HERMES_VENV"
      TMP_WHEEL="/tmp/hermes_agent-0.15.2-py3-none-any.whl"
      cp "$WHEEL" "$TMP_WHEEL"
      ${pkgs.uv}/bin/uv venv "$HERMES_VENV" --python 3.11
      ${pkgs.uv}/bin/uv pip install --python "$HERMES_VENV/bin/python" "$TMP_WHEEL"
      # Patch: skip pgvector extension (not needed with LanceDB)
      sed -i "s/CREATE EXTENSION IF NOT EXISTS vector/-- CREATE EXTENSION IF NOT EXISTS vector/" "$HONCHO_DIR/src/db.py"
      rm -f "$TMP_WHEEL"
      echo "✓ Hermes Agent ready."
    fi

    exec "$HERMES_VENV/bin/hermes" "$@"
  '';

  honcho-repo = pkgs.fetchFromGitHub {
    owner = "plastic-labs";
    repo = "honcho";
    rev = "v3.0.7";
    hash = "sha256-1izjh0wqz4fh61ig033sdgwzc31z4h0vl41035i36fw25a0rkyw3=";
  };

  honcho-data = "$HOME/.local/share/honcho";
  honcho-venv = "$HOME/.local/share/honcho-venv";
  pgdata = "$HOME/.local/share/honcho-pgdata";

  honcho-server = pkgs.writeShellScriptBin "honcho-server" ''
    set -e
    HONCHO_DIR="${honcho-data}"
    HONCHO_VENV="${honcho-venv}"
    PGDATA="${pgdata}"
    PGHOST="$PGDATA"
    PGLOG="$PGDATA/postgres.log"
    HONCHO_ENV="$HONCHO_DIR/.env"

    # ── Bootstrap: source + venv ─────────────────────────────────
    if [ ! -d "$HONCHO_DIR/src" ]; then
      echo "⚡ Setting up Honcho..."
      rm -rf "$HONCHO_DIR" "$HONCHO_VENV" "$PGDATA"
      cp -r "${honcho-repo}" "$HONCHO_DIR"
      chmod -R u+w "$HONCHO_DIR"
      ${pkgs.uv}/bin/uv venv "$HONCHO_VENV" --python 3.11
      ${pkgs.uv}/bin/uv pip install --python "$HONCHO_VENV/bin/python" \
        "$HONCHO_DIR" "uvicorn[standard]"
      # Patch: skip pgvector extension (not needed with LanceDB)
      sed -i "s/CREATE EXTENSION IF NOT EXISTS vector/-- CREATE EXTENSION IF NOT EXISTS vector/" "$HONCHO_DIR/src/db.py"

      # Init PostgreSQL data dir
      ${pkgs.postgresql}/bin/initdb -D "$PGDATA" --username=postgres --auth=trust --no-locale
      echo "unix_socket_directories = '''$PGDATA'''" >> "$PGDATA/postgresql.conf"
      echo "listen_addresses = ''''" >> "$PGDATA/postgresql.conf"
      echo "✓ Honcho ready."
    fi

    # ── Start PostgreSQL ─────────────────────────────────────────
    if ! ${pkgs.postgresql}/bin/pg_isready -h "$PGDATA" -q 2>/dev/null; then
      ${pkgs.postgresql}/bin/pg_ctl -D "$PGDATA" -l "$PGLOG" start -w -t 10
      # Create DB + enable pgvector on first start
      ${pkgs.postgresql}/bin/createdb -h "$PGDATA" -U postgres honcho 2>/dev/null || true
    fi

    # Resolve LLM API key
    LLM_KEY=$(python3 -c "import json; print(json.load(open('$HOME/.config/home-manager/secrets.json')).get('honcho_llm_api_key', ''))")

    # Write .env
    cat > "$HONCHO_ENV" << ENVEOF
LOG_LEVEL=INFO
DB_CONNECTION_URI=postgresql+psycopg://postgres:postgres@/honcho?host=$PGDATA
AUTH_USE_AUTH=false
VECTOR_STORE_TYPE=lancedb
VECTOR_STORE_LANCEDB_PATH=$HONCHO_DIR/lancedb_data
CACHE_ENABLED=false
LLM_OPENAI_API_KEY=$LLM_KEY
ENVEOF

    cd "$HONCHO_DIR"
    export HONCHO_VERSION=3.0.7

    # Run migrations
    "$HONCHO_VENV/bin/python" scripts/provision_db.py 2>&1 | grep -v "^INFO"

    exec "$HONCHO_VENV/bin/fastapi" run --host 127.0.0.1 --port 8000 src/main.py
  '';

in
{
  imports = [
    ./tmux/tmux.nix
    (import ./nvim/default.nix)
    (import ./programs/fish.nix)
    (import ./programs/git.nix)
    (import ./programs/yazi.nix)
    (import ./programs/misc.nix)
    (import ./services/mpd.nix)
  ];

  nixpkgs.config.allowUnfree = true;

  home.username = "wanmixc";
  home.homeDirectory = "/home/wanmixc";
  home.stateVersion = "25.11";

  home.packages = with pkgs; [
    bash-language-server
    bat
    bun
    eza
    fastfetch
    gitui
    ripgrep
    shfmt
    sxiv
    tmux
    unzip
    fzf
    deepseek-tui-combined
    hermes-agent
    uv
    btop
    fish
    speedtest-cli
    nodejs
    nmap
    tailscale
    postgresql
  ];

  home.sessionPath = [
    "$HOME/.nix-profile/bin"
    "/nix/var/nix/profiles/default/bin"
  ];

  home.sessionVariables = {
    EDITOR = "nvim";
    DEEPSEEK_TUI_BIN = "${deepseek-tui}/bin/deepseek-tui";
  };

  xdg.userDirs = {
    enable = true;
    createDirectories = true;
  };

  xdg.configFile = {
    "fastfetch/config.jsonc".source = ./fastfetch/config.jsonc;
    "fastfetch/logo.txt".source = ./fastfetch/logo.txt;
    "rmpc/themes/theme.ron".source = ./rmpc/theme.ron;
    "starship.toml".source = ./starship/starship.toml;
  };

  home.file = {
    ".deepseek/skills/commit-message-id/SKILL.md".source = ./deepseek/skills/commit-message-id/SKILL.md;
    ".deepseek/skills/skill-creator/SKILL.md".source = ./deepseek/skills/skill-creator/SKILL.md;
    ".hermes/honcho.json" = {
      text = builtins.toJSON {
        baseUrl = "http://localhost:8000";
        hosts = {
          hermes = {
            enabled = true;
            aiPeer = "hermes";
            peerName = "WanMixc";
            workspace = "hermes";
          };
        };
      };
    };
  };

  systemd.user.services.honcho = {
    Unit = {
      Description = "Honcho memory server (native PostgreSQL + LanceDB)";
      After = [ "network-online.target" ];
    };
    Service = {
      Type = "simple";
      ExecStart = "${honcho-server}/bin/honcho-server";
      Restart = "on-failure";
      RestartSec = "5";
      TimeoutStopSec = "30";
      ExecStop = "${pkgs.postgresql}/bin/pg_ctl -D ${pgdata} stop";
    };
    Install = {
      WantedBy = [ "default.target" ];
    };
  };

  programs.home-manager.enable = true;
}

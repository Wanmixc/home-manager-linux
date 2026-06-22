#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

script="$tmpdir/ensure-supermemory-config.sh"
config_file="$tmpdir/config.toml"

awk '
  /# BEGIN ensure-supermemory-config/ { capture = 1; next }
  /# END ensure-supermemory-config/ { capture = 0; exit }
  capture {
    sub(/^    /, "")
    gsub(/'\'''\''\$\{/, "${")
    gsub(/\$\{pkgs\.coreutils\}\/bin\/mktemp/, "/usr/bin/mktemp")
    gsub(/\$\{pkgs\.coreutils\}\/bin\/rm/, "/usr/bin/rm")
    gsub(/\$\{pkgs\.coreutils\}\/bin\/mv/, "/usr/bin/mv")
    gsub(/\$\{pkgs\.gawk\}\/bin\/awk/, "/usr/bin/awk")
    print
  }
' "$repo_root/programs/codex.nix" > "$script"

cat > "$config_file" <<'EOF'
model = "gpt-5.4"

[notice]
hide_rate_limit_model_nudge = true

[features]
experimental_resume = true

[plugins."supermemory@wanmixc-local"]
enabled = false

[other]
hooks = false
EOF

run_assertions() {
  local features_hooks
  features_hooks="$(awk '
    /^\[features\]$/ { in_features = 1; next }
    /^\[/ { in_features = 0 }
    in_features && /^hooks = true$/ { count++ }
    END { print count + 0 }
  ' "$config_file")"

  if [ "$features_hooks" -ne 1 ]; then
    echo "expected exactly one hooks = true entry in [features], got $features_hooks" >&2
    exit 1
  fi

  if ! awk '
    /^\[features\]$/ { in_features = 1; next }
    /^\[/ { in_features = 0 }
    in_features && /^hooks = true$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$config_file"; then
    echo "expected hooks = true inside [features]" >&2
    exit 1
  fi

  if ! grep -Fq '[plugins."supermemory@wanmixc-local"]' "$config_file"; then
    echo "expected supermemory plugin header" >&2
    exit 1
  fi

  if ! awk '
    /^\[plugins\."supermemory@wanmixc-local"\]$/ { in_plugin = 1; next }
    /^\[/ { in_plugin = 0 }
    in_plugin && /^enabled = true$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$config_file"; then
    echo "expected enabled = true in supermemory plugin block" >&2
    exit 1
  fi

  if ! awk '
    /^\[other\]$/ { in_other = 1; next }
    /^\[/ { in_other = 0 }
    in_other && /^hooks = false$/ { found = 1 }
    END { exit(found ? 0 : 1) }
  ' "$config_file"; then
    echo "expected non-features hooks entry to stay untouched" >&2
    exit 1
  fi
}

bash "$script" "$config_file"
run_assertions

PATH="" /bin/bash "$script" "$config_file"
run_assertions

echo "ok"

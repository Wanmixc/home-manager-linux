#!/usr/bin/env bash

set -euo pipefail

repo_root="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
git_config_file="$repo_root/programs/git.nix"
env_file="$repo_root/programs/env.nix"

if ! grep -Fq 'credential.helper' "$git_config_file"; then
  echo "expected programs/git.nix to configure credential.helper" >&2
  exit 1
fi

tmpdir="$(mktemp -d)"
trap 'rm -rf "$tmpdir"' EXIT

helper_script="$tmpdir/github-credential-helper"
secrets_file="$tmpdir/secrets.json"

awk '
  /# BEGIN github-credential-helper/ { capture = 1; next }
  /# END github-credential-helper/ { capture = 0; exit }
  capture {
    gsub(/\$\{pkgs\.coreutils\}\/bin\/cat/, "cat")
    gsub(/\$\{pkgs\.python3\}\/bin\/python3/, "python3")
    print
  }
' "$env_file" > "$helper_script"

perl -0pi -e 's/'\'''\''\$\{/\$\{/g' "$helper_script"

if [ ! -s "$helper_script" ]; then
  echo "expected github credential helper script in programs/env.nix" >&2
  exit 1
fi

chmod +x "$helper_script"

cat > "$secrets_file" <<'EOF'
{"github_token":"test-token"}
EOF

output="$(
  printf 'protocol=https\nhost=github.com\n\n' |
    GITHUB_SECRETS_PATH="$secrets_file" "$helper_script"
)"

if ! grep -Fxq 'username=oauth2' <<<"$output"; then
  echo "expected helper to emit username=oauth2" >&2
  exit 1
fi

if ! grep -Fxq 'password=test-token' <<<"$output"; then
  echo "expected helper to emit password from secrets.json" >&2
  exit 1
fi

empty_output="$(
  printf 'protocol=https\nhost=example.com\n\n' |
    GITHUB_SECRETS_PATH="$secrets_file" "$helper_script"
)"

if [ -n "$empty_output" ]; then
  echo "expected helper to ignore non-GitHub hosts" >&2
  exit 1
fi

echo "ok"

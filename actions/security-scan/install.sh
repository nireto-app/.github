#!/usr/bin/env bash
set -euo pipefail

tool_dir="${RUNNER_TEMP:?}/nireto-security"
mkdir -p "$tool_dir/bin"
case "${1:-}" in
    gitleaks)
        [[ "$(uname -s)/$(uname -m)" == Linux/x86_64 ]] || {
            echo 'gitleaks installer requires Linux x86_64' >&2
            exit 64
        }
        version=8.30.1
        checksum=551f6fc83ea457d62a0d98237cbad105af8d557003051f41f3e7ca7b3f2470eb
        curl -fsSL --retry 3 "https://github.com/gitleaks/gitleaks/releases/download/v${version}/gitleaks_${version}_linux_x64.tar.gz" -o "$tool_dir/gitleaks.tar.gz"
        printf '%s  %s\n' "$checksum" "$tool_dir/gitleaks.tar.gz" | sha256sum -c -
        tar -xzf "$tool_dir/gitleaks.tar.gz" -C "$tool_dir/bin" gitleaks
        ;;
    semgrep)
        python3 -m venv "$tool_dir/venv"
        "$tool_dir/venv/bin/python" -m pip install --quiet --disable-pip-version-check 'semgrep==1.184.0'
        ln -sf "$tool_dir/venv/bin/semgrep" "$tool_dir/bin/semgrep"
        ;;
    *) echo 'scanner must be gitleaks or semgrep' >&2; exit 64 ;;
esac

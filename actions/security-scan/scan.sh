#!/usr/bin/env bash
set -euo pipefail

case "${1:-}" in
    gitleaks)
        # Missing configuration or scanner errors must fail the job.
        exec gitleaks detect --source . --no-banner --redact --config .gitleaks.toml
        ;;
    semgrep)
        baseline="${2:-}"
        args=(scan --config=p/security-audit --config=p/secrets --metrics=off --error)
        if [[ -n "$baseline" && "$baseline" != 0000000000000000000000000000000000000000 ]]; then
            [[ "$baseline" =~ ^[0-9a-f]{40}$ ]] || {
                echo 'baseline must be a full lowercase commit SHA' >&2
                exit 64
            }
            # Preserve full-scan fallback when history is unavailable, never skip the gate.
            if git cat-file -e "$baseline^{commit}" 2>/dev/null; then
                args+=(--baseline-commit "$baseline")
            else
                echo 'Baseline unavailable; scanning the full tree'
            fi
        fi
        exec semgrep "${args[@]}"
        ;;
    *) echo 'scanner must be gitleaks or semgrep' >&2; exit 64 ;;
esac

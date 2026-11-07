#!/usr/bin/env bash
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
cd "$tmp"
git init -q
git config user.name Fixture
git config user.email fixture@example.invalid
case "${1:-}" in
    gitleaks)
        printf '[extend]\nuseDefault = true\n' > .gitleaks.toml
        git add .gitleaks.toml
        git -c commit.gpgsign=false commit -qm clean
        bash "$root/actions/security-scan/scan.sh" gitleaks
        # Deliberately synthetic token shape; no account or service owns this value.
        python3 -c 'import secrets,string; print("github_token = \"ghp_" + "".join(secrets.choice(string.ascii_letters + string.digits) for _ in range(36)) + "\"")' > fixture.txt
        git add fixture.txt
        git -c commit.gpgsign=false commit -qm seeded
        rc=0
        bash "$root/actions/security-scan/scan.sh" gitleaks || rc=$?
        [[ "$rc" == 1 ]] || { echo "Expected a finding (1), got $rc" >&2; exit 1; }
        ;;
    semgrep)
        cat > rules.yml <<'YAML'
rules:
  - id: fixture-eval
    message: Synthetic eval fixture
    severity: ERROR
    languages: [python]
    pattern: eval($X)
YAML
        printf 'print("clean")\n' > fixture.py
        semgrep scan --config=rules.yml --metrics=off --error fixture.py
        printf 'eval(input())\n' > fixture.py
        rc=0
        semgrep scan --config=rules.yml --metrics=off --error fixture.py || rc=$?
        [[ "$rc" == 1 ]] || { echo "Expected a finding (1), got $rc" >&2; exit 1; }
        ;;
    *) exit 64 ;;
esac
echo "PASS: $1 accepts clean code and rejects its seeded defect"

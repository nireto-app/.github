#!/usr/bin/env bash
# Exercise gate failures and baseline boundaries without installing scanners.
set -euo pipefail
root="$(cd "$(dirname "$0")/.." && pwd)"
tmp="$(mktemp -d)"
trap 'rm -rf "$tmp"' EXIT
mkdir -p "$tmp/bin" "$tmp/repo"
git -C "$tmp/repo" init -q
git -C "$tmp/repo" -c user.name=Fixture -c user.email=fixture@example.invalid -c commit.gpgsign=false commit --allow-empty -qm fixture
sha="$(git -C "$tmp/repo" rev-parse HEAD)"
cat >"$tmp/bin/gitleaks" <<'SH'
#!/usr/bin/env bash
printf '%s\n' "$@" >"${CALL_LOG:?}"
exit "${SCANNER_EXIT:-0}"
SH
cp "$tmp/bin/gitleaks" "$tmp/bin/semgrep"
chmod +x "$tmp/bin/"*
export CALL_LOG="$tmp/args" PATH="$tmp/bin:$PATH"
cd "$tmp/repo"
expect_exit() {
    local expected="$1" rc=0
    shift
    bash "$root/actions/security-scan/scan.sh" "$@" >"$tmp/output" 2>&1 || rc=$?
    [[ "$rc" == "$expected" ]] || { cat "$tmp/output"; echo "expected $expected, got $rc" >&2; exit 1; }
}
expect_exit 0 gitleaks
grep -qx -- '--redact' "$CALL_LOG"
grep -qx -- '.gitleaks.toml' "$CALL_LOG"
for scanner in gitleaks semgrep; do
    for rc in 1 2 7; do
        SCANNER_EXIT="$rc" expect_exit "$rc" "$scanner"
    done
done
expect_exit 0 semgrep "$sha"
grep -qx -- '--baseline-commit' "$CALL_LOG"
grep -qx -- "$sha" "$CALL_LOG"
grep -qx -- '--error' "$CALL_LOG"
grep -qx -- '--metrics=off' "$CALL_LOG"
for baseline in '' 0000000000000000000000000000000000000000 1111111111111111111111111111111111111111; do
    expect_exit 0 semgrep "$baseline"
    if grep -qx -- '--baseline-commit' "$CALL_LOG"; then
        echo 'Unavailable baseline must scan the full tree' >&2
        exit 1
    fi
done
rm "$CALL_LOG"
expect_exit 64 semgrep 'main;touch injected'
[[ ! -e injected && ! -e "$CALL_LOG" ]]
expect_exit 64 unknown
[[ ! -e "$CALL_LOG" ]]
echo 'PASS: scan errors propagate; only a valid available commit narrows the scan'

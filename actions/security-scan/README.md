# Shared security gate

Keep each repository's existing job name, triggers, runner, timeout and checkout.
Replace only its installation and scan step with this composite action, pinned to
a reviewed full commit SHA:

```yaml
- uses: nireto-app/.github/actions/security-scan@<reviewed-full-commit-sha>
  with:
    scanner: semgrep
    baseline: ${{ github.event.pull_request.base.sha || github.event.before }}
```

Use `scanner: gitleaks` for the other job; it reads the consumer's `.gitleaks.toml`
and scans its checked-out history. Both jobs need `actions/checkout` with
`fetch-depth: 0`. Semgrep compares the exact base commit, and scans everything if
that commit is absent. Invalid baseline syntax fails closed. An all-zero push
base means a full scan. No token or write permission is required.

The supported runner is Linux x86_64 with Python 3.10+ and venv. Gitleaks 8.30.1
has a fixed archive checksum; Semgrep is pinned to 1.184.0 in an isolated venv.
Semgrep transitive dependencies and the public registry rules remain upstream
resolved, as in the existing gates; this is not a claim of fully reproducible
rules. There is no scanner-version or checksum override input. Update this action
in a PR, run its tests, then update consumer commit pins through their own PRs.

Job names remain owned by the consumers, so required-check names do not change.
Sharing this implementation does not by itself reduce the number of scan jobs or
prove a reduction in billed minutes. Roll back by restoring the previous action
commit pin or the consumer's preceding workflow revision.

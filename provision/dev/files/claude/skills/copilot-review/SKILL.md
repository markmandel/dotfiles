---
name: copilot-review
description: Push the current branch, request a GitHub Copilot review on its PR, then loop - watch for the review, fix comments that make sense, push, re-request - until Copilot approves or only comments I disagree with remain.
disable-model-invocation: true
argument-hint: "[PR number or URL] (defaults to the PR for the current branch)"
allowed-tools: Read, Edit, Bash, Grep, Glob, Monitor
---

## Find the PR

1. If `$ARGUMENTS` names a PR, use it. Otherwise: `gh pr view --json number,url,headRefName,baseRepository`.
2. Note `OWNER/REPO` of the base repo (for forks this is upstream, e.g. `agones-dev/agones`, not `markmandel/agones`).
3. If there's no PR, stop and ask - don't create one.

## Push

1. Commit nothing new here; only push what's committed. If the tree is dirty, ask.
2. `git push` (SSH). If it fails with `Permission denied (publickey)`, check `ssh-add -l`. "The agent has no identities" means the key needs loading: tell the user to run `ssh-add` (it needs a tty, so you can't run it). Don't silently switch to HTTPS.

## Request the review

The GitHub MCP `request_copilot_review` tool 403s with our token - use `gh`:

```bash
gh pr edit <N> --repo OWNER/REPO --add-reviewer @copilot
```

Confirm it took, and record the request time (Copilot does not stay in `requested_reviewers` while reviewing):

```bash
gh api repos/OWNER/REPO/issues/<N>/timeline --jq '[.[] | select(.event=="review_requested" and .requested_reviewer.login=="Copilot")] | last | .created_at'
```

## Wait for the review

Use Monitor (timeout 1800000, re-arm on expiry) - don't sleep or poll in the foreground:

```bash
since=<request time>
while true; do
  r=$(gh api repos/OWNER/REPO/pulls/<N>/reviews --jq "[.[] | select(.user.login | test(\"copilot\";\"i\")) | select(.submitted_at > \"$since\")] | last | select(.) | \"\(.id) \(.state) \(.submitted_at)\"" 2>&1) || r=""
  if [ -n "$r" ]; then echo "copilot review: $r"; exit 0; fi
  sleep 30
done
```

## Handle the review

1. Read the review body and its comments:
   ```bash
   gh api repos/OWNER/REPO/pulls/<N>/reviews/<review id> --jq .body
   gh api repos/OWNER/REPO/pulls/<N>/reviews/<review id>/comments --jq '.[] | "\(.id) \(.path):\(.line // .original_line)\n\(.body)\n---"'
   ```
2. For each comment, read the code it points at and decide: **fix** (it's a real problem or a clear improvement) or **disagree** (wrong, out of scope, or stylistic churn). Don't accept a suggestion just because Copilot made it.
3. Fixes:
   - Follow the repo's own rules (AGENTS.md / CONTRIBUTING.md, memory) for validation - e.g. in Agones run `make -C build lint` and the relevant tests, not raw host `go` tools.
   - Commit as a new commit (`git commit -s`, no co-author trailer in Agones) so the reviewer sees the delta; don't rewrite history unless the user asks.
   - `git push`.
4. Reply on each comment thread so the outcome is visible:
   - Fixed: `gh api repos/OWNER/REPO/pulls/<N>/comments/<comment id>/replies -f body="Fixed in <short sha>: <what changed>."`
   - Disagree: reply with a short, specific reason.

## Loop or stop

- **Stop** when Copilot's review is `APPROVED`, or has no comments (Copilot usually only leaves `COMMENTED`; a review saying it generated no new comments counts as clean), or every remaining comment is one you disagree with and have replied to.
- **Otherwise**, if you pushed fixes, re-request (`gh pr edit ... --add-reviewer @copilot`), take the new request time, and go back to "Wait for the review".
- Stop and ask the user if Copilot keeps raising the same point after you've replied, or after 5 rounds.

## Report

Summarise per round: what Copilot raised, what was fixed (with commit SHAs), what you disagreed with and why, and the final state of the PR.

# Tools Reference

CLI tools available on Terrance's machines. Use these for agentic tasks.

## gh

GitHub CLI for repositories, issues, pull requests, CI, and releases.

Usage:

```bash
gh help
```

When someone shares a GitHub URL, use `gh` to read it when possible:

```bash
gh issue view <url> --comments
gh pr view <url> --comments --files
gh pr diff <url>
gh run list
gh run view <run-id>
```

Notes:

- Prefer `gh pr view/diff` for PR context over web search.
- Use `gh run list/view` for GitHub Actions CI.
- Do not publish, comment, merge, push, or change remote state unless the user asks.

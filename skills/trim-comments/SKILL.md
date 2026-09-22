---
name: trim-comments
description: "Trim verbose code comments, agent comment bloat, comment cleanup pass."
---

# Trim Comments

Cut **narration**: comments that say what the code already shows. Code is the source of truth for _what_; a comment earns its line only when it carries a _why_ the code cannot show.

## Steps

1. **Set scope.**
   - User names files or a range: use that.
   - Else: files touched in the current work — `git diff` (uncommitted) plus commits on the branch since merge-base with the default branch.
   - Every comment in a scoped file is in scope. Treat all comments as agent-written.
   - Done when: every file in scope is listed.

2. **Classify every comment in scope** with one test: _delete it — does a reader lose a fact the code cannot give them?_
   - No → **cut**.
   - Yes → **keep**, shortened to the fewest words that hold the fact. One line is the target.
   - Done when: every comment in scope is cut, kept, or shortened. No comment skipped.

3. **Edit comments only.** Code, names, and formatting outside comments stay exact. Remove blank lines left by a cut block when they break local spacing.

4. **Verify.** Read `git diff` for the touched files: only comment lines removed or shortened. Run the repo's formatter or linter when it is cheap.
   - Done when: diff has zero non-comment changes.

5. **Report**: per file, count cut and shortened. List kept comments only when a keep is non-obvious.

## Reference

**Cut** — narration and its kin:
- Restates the next line, a name, a type, or a signature.
- Section banners and step labels over short code (`// Step 1: validate input`).
- Docstrings that repeat the parameter list with no added contract.
- Change history: "added", "now uses", "fixed per review", "updated to". Git holds history.
- Reader-talk: "Note that…", "Here we…", "This function…".
- Commented-out code.
- Same fact already stated at another site. Keep it once, at the owning site.

**Keep** — the _why_:
- Constraint, invariant, or gotcha a careful reader would miss.
- Workaround for a bug or quirk, with link or issue ID when present.
- Reason for a non-obvious choice: magic number, odd order, deliberate omission.
- Meaning of a dense regex, bit trick, or formula.
- TODO/FIXME with owner or issue link.
- Directives and tooling comments: shebang, license headers, `eslint-disable`, `@ts-expect-error`, `# type: ignore`, `//go:build`, `# noqa`, pragmas.
- Public API docs a doc tool consumes (exported library JSDoc/docstrings for generated doc sites). Cut them to the contract: what the signature cannot say.

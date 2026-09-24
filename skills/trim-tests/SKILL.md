---
name: trim-tests
description: "Trim unnecessary unit tests, agent test bloat, test suite cleanup pass."
---

# Trim Tests

Keep only tests of **complex** behaviour. Agents write **simple** code correctly on the first pass, so a test of simple code is pure maintenance cost: it breaks on refactor and almost never on a bug.

- **Simple**: straight-line code, one branch, a pass-through, a happy path a reader checks at a glance.
- **Complex**: interacting branches, state over time, boundaries, parsing, math, concurrency, a business rule with several cases — logic a careful reader can get wrong.

## Steps

1. **Set scope.**
   - User names files, a directory, or a range: use that.
   - Else: tests added or changed in the current work — `git diff` (uncommitted) plus commits on the branch since merge-base with the default branch. Tests older than the branch stay out of scope.
   - Run the scoped tests once. Record the baseline: pass/fail per file.
   - Done when: every test file in scope is listed and the baseline is recorded.

2. **Classify every test case in scope** with two gates, in order:
   - Does it test **complex** behaviour? No → **cut**.
   - Delete it — can a bug in that complex behaviour ship with every remaining test still green? No → **cut**. Yes → **keep**.
   - Several kept cases hit the same branch with different literals → **merge** into one parameterized case (`it.each`, `pytest.mark.parametrize`, table-driven Go, etc.) when the file already uses that idiom or the framework supports it; else keep the one strongest case and cut the rest.
   - Done when: every test case in scope is cut, kept, or merged. No case skipped.

3. **Edit test files only.** Code under test stays exact, even when a test exposes a bug — report the bug instead. After cuts, delete fixtures, mocks, helpers, and imports that no remaining test uses. Delete a test file that is left empty.

4. **Verify.**
   - Re-run the scoped tests: every file that passed at baseline still passes.
   - Read `git diff`: only test files, fixtures, and test helpers changed.
   - Coverage tool cheap to run: compare against baseline. A **complex** branch that lost its last test means a keep was cut — restore that case. Simple branches with no test are the goal.
   - Done when: suite green versus baseline and diff has zero non-test changes.

5. **Report**: per file, count cut, merged, kept. List bugs found in step 3. List keeps only when non-obvious.

## Reference

**Cut** — dead weight and its kin:
- **Change-detector**: asserts _how_, not _what_ — call counts or argument order on internal collaborators, private methods, exact log strings, internal state. Breaks on refactor; catches no bug.
- **Tests the mock**: stubs a return value, then asserts that value comes back.
- **Tests the language, framework, or type checker**: getter returns what setter set, constructor assigns fields, enum lists its members, wrong-typed input the compiler already rejects.
- **Mirror**: expected value computed with the same logic as the code under test.
- **Existence check**: "is defined", "exports X", "renders without crashing" when another test already renders it.
- **Simple case**: happy path of straight-line code, single-branch logic, pass-through, re-export, constant, one-line delegate.
- **Duplicate**: same behaviour and branch as another case, at the same or another test level. Keep it once, at the level closest to the caller.
- Snapshot of large output no reviewer reads; replace with assertions on the fields that matter only if those fields carry behaviour.

**Keep** — complex behaviour, asserted through the public interface:
- Boundary and error paths with real risk: empty, null, off-by-one, overflow, timezone, encoding, concurrency, partial failure.
- Contract at a system seam: API schema, serialization format, persisted data shape, migration, CLI output another tool parses.
- A non-obvious rule the code implements (pricing, permissions, state transitions) — one case per rule branch.
- Tests marked skip/xfail with an issue link: leave as is.

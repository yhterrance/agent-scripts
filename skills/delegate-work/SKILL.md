---
name: delegate-work
description: "Coordinate parallel Codex subagents while keeping the main thread responsive. Use for substantive tasks with separable exploration, implementation, review, or verification work that benefits from delegation."
---

# Delegate work

Keep the main thread available for user communication, decisions, integration, and approvals.

## Delegate

1. Split only independent, substantive work. Keep trivial, tightly coupled, or approval-sensitive work in the main thread.
2. Give every agent one bounded outcome and exclusive ownership. Avoid overlapping files, questions, or investigation areas.
3. Launch independent agents concurrently when slots permit. Continue useful main-thread reasoning or integration while they run.
4. Tell every leaf worker: `Do not delegate.`

### Model selection

Use the model that matches the delegated-agent runtime, not the task type.

- Use `Luna` when dispatching a Codex subagent.
- Use `Sonnet` when dispatching a Claude Code subagent.
- Apply the same model choice across scouts, implementation workers, reviewers, and validators.
- When the dispatch interface exposes a model field, set it explicitly; use the provider’s equivalent model identifier if names differ.

### Read-only scouts

Use scouts early for codebase exploration, evidence gathering, risk discovery, or validation.

- Set `reasoning_effort: "low"` and `fork_turns: "none"`.
- State that the task is read-only: no edits, writes, messages, or approvals.
- Supply all necessary paths, questions, constraints, and expected return format in the prompt.
- Ask for concise findings with evidence such as file paths, line numbers, commands, or source links.

### Implementation workers

- Use `reasoning_effort: "medium"` for routine implementation.
- Use `reasoning_effort: "high"` for hard debugging, architectural changes, migrations, or subtle correctness work.
- Because an explicit effort requires isolated context, use `fork_turns: "none"` and include all task-local context.
- Assign non-overlapping files or components. Main thread owns integration across boundaries.
- Require targeted verification and a short summary of changes, checks, and blockers.

## Coordinate

- Tell the user what was delegated and keep commentary updates flowing while work runs.
- Inspect returned evidence and diffs; do not accept summaries uncritically.
- Resolve conflicts and synthesize one coherent result in the main thread.
- Keep permission and product decisions with the user. Workers must report approval needs instead of escalating or assuming consent; request approval from the main thread when required.
- Stop, redirect, or follow up with a worker when its scope changes. Do not duplicate its assignment with another worker.
- Wait for outstanding required results before declaring completion.

Do not delegate merely to appear parallel. Delegate when the split improves speed, context isolation, or independent scrutiny.

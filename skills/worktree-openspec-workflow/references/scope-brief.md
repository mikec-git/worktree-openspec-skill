# Scope Brief

Use this brief before creating the worktree. Keep it concise, but make it concrete enough that another worker can write OpenSpec artifacts without guessing.

## Discovery Question Generation

Ask only the questions that are not already answered by the user's prompt or existing project context.

Generate a 10-question Yes/No/Chat flow from the requested feature/spec, then ask those questions one at a time. If a structured interactive input tool is available, use it for the next unanswered question only. If not, present one numbered Yes/No/Chat prompt and wait for the user's answer before asking the next question or creating anything.

Do not replace the discovery flow with broad open-ended questions unless the user explicitly asks for that format.

Each generated question must offer exactly these three choices:

- Yes: accept the question's default assumption.
- No: use the listed fallback assumption.
- Chat: provide a free-form answer or nuance.

Before asking, draft exactly 10 task-specific questions that cover the following decision areas when relevant:

1. Primary user outcome.
2. In-scope workflow or behavior.
3. Out-of-scope workflow or behavior.
4. Product surface or command/API/UI boundary.
5. Data, persistence, config, protocol, or integration boundary.
6. OpenSpec capability boundary: new capability, existing capability, or both.
7. Compatibility and migration expectations.
8. Error handling, edge cases, or fallback behavior.
9. Verification level and concrete checks.
10. Agent owner, task slug, worktree path, and handoff shape.

Adapt the wording to the actual feature/spec. Do not ask generic questions when a concrete question can be inferred. For example, if the user asks for cursor integration, ask about cursor-specific launch, resume, config, or handoff behavior instead of asking "Which surfaces are in scope?".

Generated question quality rules:

- Phrase each question so `Yes` is the most likely default assumption.
- Phrase `No` as the simplest useful fallback.
- Keep `Chat` as the only free-form option.
- Keep choices short enough that the user can answer without thinking through implementation details.
- Do not expose internal uncertainty as a broad open-ended question; turn it into a concrete assumption.
- Regenerate or skip questions as the conversation answers earlier questions.

Example format:

```markdown
Please choose one option:

1. Should cursor-launched sessions reuse the same resume detection path as existing ccmux sessions?
   A. Yes - share the existing resume detection path.
   B. No - add a cursor-specific resume path.
   C. Chat - I will describe different resume behavior.
```

## Scope Summary Format

```markdown
## Scope

Problem:

Outcome:

In scope:

Non-goals:

Affected surfaces:

OpenSpec capabilities:

Acceptance criteria:

Verification:

Assumptions:
```

## Rules

- Do not create the worktree until the scope is specific enough to write `proposal.md`.
- If the user wants to move fast, make reasonable assumptions and list them in the scope summary.
- Stop and ask a follow-up if a missing answer would change the task slug, worktree ownership, capability names, or acceptance criteria.
- Preserve the final scope summary in the handoff.

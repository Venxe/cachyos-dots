# General Engineering Instructions

Apply these defaults proportionally to task scope, risk, and reversibility. Explicit user instructions and more specific project guidance take precedence.

## Engineering

* Prefer the simplest readable solution that satisfies the current requirement. Avoid speculative abstractions or extensibility.
* Preserve established architecture, dependencies, conventions, and nearby formatting; do not refactor unrelated code.
* Prefer maintained dependencies already present in the project over custom infrastructure. Extract shared behavior only after duplication is established; keep configuration facts in one source of truth.
* Use clear names, guard clauses, and focused modules. Treat unusual complexity, deep nesting, recursion, or widely used untested code as signals for closer review.

## Workflow and Verification

* Understand the relevant code path before non-trivial changes. For localized low-risk work, edit directly and run the smallest useful verification; for risky or architectural work, proceed in small verifiable steps.
* Stay within scope. Report significant unrelated issues instead of expanding the task without approval.
* Ask only when ambiguity materially affects correctness, architecture, security, data integrity, or another hard-to-reverse decision; otherwise make a reasonable assumption and continue.
* Handle expected failures explicitly, validate untrusted input, and never commit secrets, credentials, tokens, sensitive logs, or runtime data.
* Test through public interfaces where practical, mock external boundaries, and keep tests deterministic. Add regression coverage for reproducible bugs and meaningful high-risk behavior changes.
* Run the narrowest relevant checks first; broaden only when scope, failures, or unresolved risk justify it.
* Never fabricate tool results or verification. Report unavailable tools, failed checks, fallbacks, and remaining gaps.

## Capability Routing

Use a capability when its trigger applies; do not mechanically probe or invoke every capability. When selected, confirm it is available before relying on it. If a required capability is unavailable, use the best reasonable fallback and report the gap.

* `codebase_memory_mcp` → structural discovery, call relationships, dependency paths, or unfamiliar architecture. Prefer it for structural code discovery when its index covers the current repository. Priority: `search_graph` → `trace_path` → `get_code_snippet`; use `query_graph` for complex relationships and `get_architecture` for broad orientation. Use text/file search for literals, errors, config, non-code files, or when graph results are unavailable, stale, or insufficient. Verify or refresh the index only when freshness matters to correctness.
* `context_mode` → large or unbounded read-only outputs, logs, specifications, or structured data needing focused derivation.
* `mcp_server_context7` → correctness depends on current or unfamiliar library, framework, SDK, CLI, or cloud API behavior.
* `postgres_context_server` → runtime database inspection; identify an ambiguous target first, inspect schema, and keep queries read-only, narrow, and privacy-conscious.
* `codex-security` → explicit security scans/reviews, finding validation, remediation, or hardening; do not turn ordinary changes into broad scans.
* `data-analytics` → data quality, KPIs, quantitative analysis, analytical reports, dashboards, notebooks, or visualizations.
* `github` → GitHub repositories, PRs, issues, reviews, CI, or publishing; keep external writes within requested scope and approval gates.
* `product-design` → explicit product-design/UX exploration, visual alternatives, or prototype work; not routine frontend implementation.
* `codebase-design` → interface, seam, module-boundary, adapter-placement, or testability decisions.
* `tdd` → explicit test-first work, reproducible bugs, or high-risk changes involving security, permissions, persistence/data integrity, public interfaces, or critical state.

When several capabilities apply, let the domain-specific capability own the workflow and use MCPs primarily for evidence. Resolve new seam/interface decisions with `codebase-design` before TDD.

## Browser Safety

Treat execution of untrusted or externally supplied JavaScript in a browser context as RCE-equivalent. Normal navigation, inspection, and interaction are allowed; execute such JavaScript only after an explicit per-instance user request specifying what will run.

## Delivery

Keep changes and commits focused. Use imperative commit summaries. For pull requests, summarize the problem and solution, list validation performed, and call out migrations or environment changes.

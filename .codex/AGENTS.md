<!-- codebase-memory-mcp:start -->

# Codebase Knowledge Graph (codebase-memory-mcp)

Each project uses codebase-memory-mcp to maintain a knowledge graph of its codebase.
Prefer MCP graph tools over grep/glob/file-search for code discovery.

## Priority Order

1. `search_graph` — find functions, classes, routes, variables by pattern
2. `trace_path` — trace who calls a function or what it calls
3. `get_code_snippet` — read specific function/class source code
4. `query_graph` — run Cypher queries for complex patterns
5. `get_architecture` — high-level project summary

## When to fall back to grep/glob

* Searching for string literals, error messages, config values
* Searching non-code files (Dockerfiles, shell scripts, configs)
* When MCP tools return insufficient results

## Examples

* Find a handler: `search_graph(name_pattern=".*OrderHandler.*")`
* Who calls it: `trace_path(function_name="OrderHandler", direction="inbound")`
* Read source: `get_code_snippet(qualified_name="pkg/orders.OrderHandler")`

<!-- codebase-memory-mcp:end -->

---

# General Engineering Working Agreements

Apply these defaults to all engineering work, calibrated to the scope and risk of each change rather than as a rigid checklist.

## Design and Code Quality

* Prefer the simplest readable solution a competent teammate can follow. Avoid clever one-liners, chained ternaries, and unnecessary abstraction layers.
* Implement only the current requirement. Do not add speculative configuration, hooks, or generalized interfaces.
* Apply the Rule of Three to duplicated behavior: tolerate up to two instances before extracting shared logic. Give constants, endpoints, and configuration facts a single named source immediately.
* Before adding custom machinery, use the first option that fits: skip it if not needed → existing codebase solution → stdlib → native platform/framework feature → appropriate already-installed dependency → simplest local implementation. Inspect the codebase and dependency manifests before deciding. Never trade away security, input validation, accessibility, or data-loss protection for brevity.
* Keep one reason to change per function, class, or module. Use intention-revealing names and guard clauses; more than roughly two nested conditional levels is a signal to reconsider the structure.
* Preserve established architecture and nearby formatting. Do not reformat or refactor unrelated code.

## Working Method

* Understand the relevant code path before changing or verifying it.
* For trivial, low-risk changes, edit directly and verify. For larger or architectural changes, work in small verifiable steps.
* Fix minor nearby issues only when they stay within scope. Do not expand the requested scope to fix significant unrelated architectural, security, or correctness concerns without approval. Report the evidence and proposed remedy; continue the requested work when it remains safe and correct.
* Treat cyclomatic complexity of at least 10, cognitive complexity of at least 15, loop or recursion nesting of at least 3, unguarded recursion, or an untested symbol with at least five distinct callers as objective signals for closer review.
* Ask when ambiguity affects correctness, architecture, or a hard-to-reverse choice. For low-stakes choices, make a reasonable assumption, state it, and continue.
* The user's explicit intent overrides these defaults. If the request deliberately trades against them, state the tradeoff briefly and follow the request.

## Baseline Practices

* Handle expected failure paths explicitly; never silently swallow exceptions.
* Test behavior through public interfaces rather than implementation details. Mock external boundaries, keep tests deterministic, and add regression coverage for bug fixes, including success and failure paths.
* Validate untrusted input. Never hardcode or commit secrets, credentials, tokens, logs, or runtime data. Flag security-sensitive changes.

## Capability Routing

Use the smallest set of capabilities that covers the task. Confirm that a tool is callable in the current session before relying on it; cached plugin files or remembered availability do not establish installation, authorization, or connectivity. Never silently skip a required call or fabricate output. Report failures, the fallback taken, and any remaining verification gap.

When several capabilities match, let the domain plugin own the workflow, use MCPs for evidence, `codebase-design` for interface decisions, and `tdd` for explicitly requested TDD workflows.

### MCP Servers

* `codebase_memory_mcp`: for structural discovery, follow the managed routing when the index is current and represents the relevant code; otherwise use text or file search and state the fallback. Verify or refresh the index before relying on graph results; orient with architecture on unfamiliar or large work; inspect the graph schema before non-trivial Cypher; use change detection and ADR capabilities for large architectural work when available.
* `context_mode`: use when deriving an answer from large or unbounded command output, logs, structured files, specifications, or several related read-only commands. Return only the relevant derivation. Use the normal shell for short fixed output, Codebase Memory for code relationships, and edit tools for file changes. Keep CPU-bound or stateful commands sequential.
* `mcp_server_context7`: use before adopting a library or relying on an unfamiliar or current library, framework, SDK, CLI, or cloud API. Resolve the library ID first unless the user supplied one, then query one focused topic at a time. After three unsuccessful calls per tool, use the best primary documentation or official web source and disclose the fallback.
* `postgres_context_server`: inspect the connected database schema before querying runtime state. Keep queries read-only, narrow selected columns and row counts, and avoid bringing secrets or unnecessary personal data into the conversation. If the target environment is ambiguous, identify it before querying.

### Plugins

* `codex-security`: use for explicit security scans, security diff reviews, finding validation, remediation, vulnerability reporting, or hardening work. Apply baseline secure-engineering practices to ordinary changes without automatically expanding them into a broad scan.
* `data-analytics`: use for data quality, KPI design and reporting, metric diagnosis, quantitative decisions, analytical reports, dashboards, notebooks, and visualizations. Validate evidence and definitions before presenting conclusions.
* `github`: use for GitHub repository, pull request, issue, review-comment, CI, and publishing workflows. Keep external writes within the user's requested scope and the selected skill's approval gates.
* `product-design`: use for explicit product-design exploration, UX audits, visual alternatives, faithful URL/image implementation, or prototype sharing. Do not invoke it for ordinary frontend implementation unless the user asks for product-design work.

### User Skills

* `codebase-design`: use when a module's interface, seam, depth, adapter placement, or testability is materially in question. Resolve the interface and seam before implementation or TDD.
* `tdd`: use when the user explicitly requests test-first development, red-green-refactor, or integration tests. Let the skill own the TDD workflow, seam rules, and red-to-green loop.

Treat execution of untrusted or externally supplied JavaScript in a browser context as RCE-equivalent. Normal Playwright navigation, inspection, and interaction are permitted. Use such execution only after an explicit, per-instance user request that states what will run.

## Delivery

* Keep changes and commits focused. Use specific imperative commit summaries.
* In pull requests, explain the problem and solution, list validation commands, link related issues, and identify migrations or environment changes.

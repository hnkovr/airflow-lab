# Airflow 3.1 — Agentic Data Engineering Guardrails Lab

> Status: proposed lab; no implementation claimed. Target repository: `hnkovr/airflow-lab`.

## Master prompt for coding agent

Act as a senior Apache Airflow 3.1 platform engineer, security engineer, and technical educator. Build an **incremental, reproducible, locally runnable lab** teaching how to safely use AI coding agents to create and operate data pipelines. Do not claim tests pass unless executed. Preserve existing repository files and prefer small, reviewable commits. Do not push without explicit permission.

### Goals
- Demonstrate separation of *coding agent* (creates DAGs) from *runtime AI agent* (runs in controlled DAGs).
- Enforce DAG/task guardrails using Airflow cluster policies (`dag_policy`, `task_policy`) in `airflow_local_settings.py`.
- Use `AGENTS.md` plus optional Claude Code hooks, CI, runtime permissions, and database RBAC as distinct layers, explaining which are advisory and which are enforceable.
- Add data quality and semantic tests for a small e-commerce orders mart.
- Demonstrate Airflow 3.1 Human-in-the-Loop for high-risk backfills, with safe default and timeouts.
- Optionally integrate a version-compatible Common AI Provider for read-only SQL analysis; pin and verify dependencies instead of assuming APIs.

### Suggested architecture
`AI coding agent → AGENTS.md/hooks → git/CI → Airflow DAG processor + cluster policies → DAG execution → quality/semantic checks → optional HITL → dbt → ClickHouse → read-only AI analyst`.

### Stack
Airflow **3.1.x** (pin a verified patch release and matching constraints), Docker Compose, PostgreSQL metadata database, Python Task SDK, pytest, Ruff, dbt Core/dbt-clickhouse, ClickHouse. Optional Redis/CeleryExecutor, SQLFluff, OpenTelemetry, Prometheus/Grafana, Pydantic AI, Common AI Provider. Start with the smallest local deployment that works on Apple Silicon; do not require optional components for MVP.

### Phases and deliverables
- [ ] **0. Repository inventory and design (30–45 min).** Inspect git status, existing files, Python/Compose versions, Airflow 3.1 compatibility. Write `docs/architecture.md` and `docs/threat-model.md`; avoid overwrites.
- [ ] **1. Minimal local Airflow (60–90 min).** Add pinned dependencies, Docker Compose, startup instructions, health check, sample DAG, `make up/down/test` or equivalent. Confirm DAG loads in UI.
- [ ] **2. Cluster policies (90 min).** Enforce DAG tags, catchup policy, max_active_runs; enforce task owner, execution_timeout, retry limit, optionally assign safe pool. Place policy entrypoints in `config/airflow_local_settings.py`; prove DAG processor loads them. Explain reject vs mutate behavior.
- [ ] **3. Adversarial DAG suite (60 min).** Create intentionally invalid fixtures (missing owner, catchup, retries=100, no timeout, excess concurrency) and positive cases. Unit + integration tests should show rejected/accepted DAGs. Avoid relying solely on static text inspection.
- [ ] **4. Coding-agent guardrails (60–90 min).** Add `AGENTS.md`, optional `.claude/settings.json` hooks, scoped filesystem permissions, protected policy files, and CI checks. Explain `AGENTS.md` is guidance, not a security boundary. Test attempted changes to policy code.
- [ ] **5. Data contracts and semantic quality (90–120 min).** Load synthetic orders into ClickHouse, dbt staging and daily revenue mart, schema/model contracts where supported, dbt tests and explicit semantic tests (refunds, VAT, net vs gross revenue). Include intentionally wrong SQL and demonstrate failure.
- [ ] **6. Human-in-the-Loop (60–90 min).** Implement a risky backfill approval workflow with Airflow 3.1-compatible HITL API; test approval, rejection, timeout, and safe default. Verify actual API against pinned version.
- [ ] **7. Optional runtime AI analyst (90–120 min).** Pin compatible Common AI Provider and model backend; provide read-only ClickHouse user, table allowlist, query timeout/row limits. Demonstrate that DB denies DROP/DELETE regardless of prompt instructions. No live credentials in repo.
- [ ] **8. CI and demo (60 min).** Ruff, pytest, DAG import/policy tests, dbt build/tests, GitHub Actions, 5–7 minute walkthrough, `docs/lab-results.md` with actual commands and outcomes.

### Required security / operational controls
- Never expose API keys, passwords, tokens, or private user data in commits/logs.
- AI-generated SQL is untrusted; use read-only database credentials for analyst; separate elevated write roles.
- Block dangerous operations with permissions, not just prompt instructions or regex.
- Limit backfill date ranges, concurrency, retries, execution time, resource use, and query rows.
- Pin dependencies and verify provider compatibility with Airflow 3.1; distinguish Airflow 3.1 built-in HITL from separately released AI provider.
- Do not run destructive actions, force-push, merge, or modify external resources without explicit user approval.

### Acceptance criteria
1. One command starts the documented minimal lab on an Apple Silicon laptop.
2. At least five invalid DAG cases fail in the correct enforcement layer; valid DAG passes.
3. Tests verify cluster policy registration in the real DAG-processing path.
4. Orders mart passes schema and semantic checks; incorrect net-revenue formula fails.
5. HITL gates a high-risk backfill, with tests for approve/reject/timeout.
6. Optional runtime AI analyst cannot write to ClickHouse at DB permission level.
7. README includes setup, teardown, architecture, test matrix, troubleshooting, and a 5–7 minute demo.
8. Every result is reproducible and backed by logs/test outputs; unfinished work stays unchecked.

### Working protocol
Inspect repository → propose concise execution plan → implement one phase → run targeted tests → report changes, commands, results and blockers → request approval before risky actions. Do not silently substitute a different Airflow major/minor version. If APIs differ, cite versioned official docs in repository notes.

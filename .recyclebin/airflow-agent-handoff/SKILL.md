---
name: coding-agent-handoff
summary: Safely transfer a ChatGPT-generated plan into a local Git repository when direct GitHub writes are unavailable.
---

# Coding-agent handoff pattern

## Trigger
User wants to persist a plan, prompt or coding instructions in a repository, but the assistant cannot write there (read-only connector, empty remote, local-only clone, or unavailable workstation filesystem).

## Procedure
1. Identify repository and desired target files; inspect remotely if possible. Distinguish connector read permission from GitHub App installation permissions and actual filesystem access.
2. Produce portable UTF-8 files (`TODO.md`, `AGENTS.md`) plus a safe local installation script. Preserve existing user content by default.
3. Script must check path, ensure Git repository, search for source files in Downloads, copy or append without destructive overwrites, and back up existing files before changing them.
4. Provide clear terminal commands to install locally and hand off to Codex/Claude. Do not claim local execution or remote commit.
5. Require user review of `git diff`; commit/push are opt-in.
6. On future iterations, fetch current repository state first and update incrementally.

## Security and safety
Never embed secrets; never use `sudo`, force push, `git reset --hard`, or silent overwrite. A repository `AGENTS.md` is advisory, not an OS-level permission boundary. For code agents, recommend sandbox restrictions and explicit approvals.

## Template handoff prompt
"Read AGENTS.md and TODO.md in the repository root. Inspect git status and current files before changes. Propose a phased implementation. Implement only Phase 0 and Phase 1 unless explicitly authorized to continue. Run tests, document outcomes, and do not push or alter remote resources without permission."

#!/usr/bin/env bash
set -euo pipefail
REPO="${1:-$HOME/gi/@hnkovr/airflow-lab}"
BUNDLE="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
[[ -d "$REPO/.git" ]] || { echo "Not a Git repository: $REPO" >&2; exit 1; }
mkdir -p "$REPO/.agent-skills/coding-agent-handoff"
# If a hand-authored TODO exists in Downloads, preserve it and append the lab prompt.
DOWNLOAD_TODO=""
for candidate in "$HOME/Downloads/TODO.md" "$HOME/Downloads/airflow-lab-TODO.md"; do
  if [[ -f "$candidate" ]]; then DOWNLOAD_TODO="$candidate"; break; fi
done
if [[ -n "$DOWNLOAD_TODO" && ! -e "$REPO/TODO.md" ]]; then
  cp "$DOWNLOAD_TODO" "$REPO/TODO.md"
  echo "Copied existing TODO from: $DOWNLOAD_TODO"
fi
stamp="$(date +%Y%m%d-%H%M%S)"
if [[ -f "$REPO/TODO.md" ]]; then
  if ! grep -Fq '# Airflow 3.1 — Agentic Data Engineering Guardrails Lab' "$REPO/TODO.md"; then
    cp "$REPO/TODO.md" "$REPO/TODO.md.bak-$stamp"
    printf '\n\n---\n\n' >> "$REPO/TODO.md"
    cat "$BUNDLE/TODO.md" >> "$REPO/TODO.md"
    echo "Appended lab TODO; original backed up."
  else
    echo "Lab TODO already present; skipping."
  fi
else
  cp "$BUNDLE/TODO.md" "$REPO/TODO.md"
fi
if [[ -f "$REPO/AGENTS.md" ]]; then
  if ! grep -Fq '# AGENTS.md — airflow-lab' "$REPO/AGENTS.md"; then
    cp "$REPO/AGENTS.md" "$REPO/AGENTS.md.bak-$stamp"
    printf '\n\n---\n\n' >> "$REPO/AGENTS.md"
    cat "$BUNDLE/AGENTS.md" >> "$REPO/AGENTS.md"
    echo "Appended AGENTS.md; original backed up."
  else
    echo "Lab AGENTS.md already present; skipping."
  fi
else
  cp "$BUNDLE/AGENTS.md" "$REPO/AGENTS.md"
fi
cp "$BUNDLE/SKILL.md" "$REPO/.agent-skills/coding-agent-handoff/SKILL.md"
cd "$REPO"
echo "--- git status ---"
git status --short
echo "--- review before committing ---"
echo "git diff -- TODO.md AGENTS.md"
echo "git diff --no-index /dev/null TODO.md  # if untracked"
echo "No commit or push performed."

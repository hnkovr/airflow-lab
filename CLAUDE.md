# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Состояние проекта

Greenfield: репозиторий пока — **спецификация**, а не реализация. В git только `README.md` (заглушка) и `.gitignore`; `AGENTS.md` и `TODO.md` пока не закоммичены. Нет `pyproject.toml`, Compose, CI и тестов, поэтому **команд build/lint/test пока не существует** — не выдумывать их. Планируемый стек (из `AGENTS.md`/`TODO.md`): Airflow 3.1.x + Docker Compose, PostgreSQL (метаданные), ClickHouse + dbt-clickhouse, Ruff, pytest. Когда появится Фаза 1 — добавить сюда реальные команды (включая запуск одного теста).

## Сначала прочитать

- `AGENTS.md` — обязательные правила агента: приоритет источников, чек-лист старта сессии, режим работы, формат handoff в конце сессии.
- `TODO.md` — мастер-промпт лабы, фазы 0–8 с чекбоксами, критерии приёмки. Чекбокс ставится только для полностью проверенной работы.

Здесь не дублируется то, что уже есть в них; ниже — только то, что видно при чтении обоих файлов вместе.

## Архитектура (общая картина)

Лаба учит безопасно использовать AI-агентов для создания и эксплуатации пайплайнов. Цепочка слоёв:

`coding agent → AGENTS.md/hooks → git/CI → DAG processor + cluster policies → запуск DAG → проверки качества/семантики → (опц.) HITL → dbt → ClickHouse → read-only AI-аналитик`

- Три разных актора, не смешивать: (a) агент-кодогенератор, (b) scheduler/DAG processor Airflow, (c) AI-задача в рантайме.
- Каждый слой либо *advisory* (AGENTS.md, промпты, хуки), либо *enforceable* (права БД, CI/branch protection, изоляция контейнеров). Cluster policies — это parse-time governance, а не граница безопасности.
- Точки входа политик — `config/airflow_local_settings.py` (`dag_policy`, `task_policy`); сама логика — в чистых функциях `policies/`, чтобы тестироваться независимо. Интеграционный тест обязан доказывать, что DAG processor реально загружает политики.
- Postgres метаданных Airflow строго отдельно от аналитического ClickHouse.
- Раскладка (планируется): `dags/`, `config/`, `policies/`, `tests/`, `dbt/`, `contracts/`, `docs/{architecture,threat-model,lab-results}.md`, `.github/workflows/`.

## Жёсткие ограничения

- Airflow 3.1.x и constraints зафиксированы; мажор/минор молча не менять. API (HITL, Common AI Provider) проверять по версионной документации/исходникам, не выдумывать.
- Без push / PR / merge / tag / force-push / `reset --hard` / `clean -fd` / переписывания истории без явного разрешения. Коммитить только если пользователь попросил.
- AI в рантайме — только read-only роль БД с лимитами запроса/строк/времени; запрет DROP/DELETE обеспечивается правами БД, а не промптом или regex.
- HITL обязателен для рискованного backfill (тесты: approve / reject / timeout / default).
- Не ослаблять и не отключать тесты, политики, `AGENTS.md`, защиту CI ради зелёной сборки; пропущенный тест ≠ пройденный.
- Только синтетические данные; секреты и `.env` не коммитить и не печатать.
- При парсинге DAG — никаких сетевых вызовов и тяжёлых импортов; явные schedule, timezone, retries, timeout, owner, tags, pool.

## Глобальные правила пользователя, которые здесь действуют

(из `~/.claude/rules`)

- Изменения — в ветке `feat/<тема>` (`fix/`, `docs/`) от `main` в текущем каталоге; worktree только при реальной параллельной работе. Conventional Commits.
- Env — только из `.env`-файлов, читать строго и без дефолтов (`os.environ["X"]`, dbt `env_var('X')`); в репо — шаблоны `.env.template` / `*.demo`.
- ID, URL, таймауты, таймзоны, enum-значения — не литералами в коде, а в YAML-конфиге проекта или `.env`.
- `gh` залогинен под несколькими аккаунтами; перед push/PR проверить, что аккаунт совпадает с владельцем репозитория.

## Заметки

- `.agent-skills/coding-agent-handoff/` и `.recyclebin/` (`airflow-agent-handoff` + zip) — неотслеживаемые артефакты handoff из Downloads; сохранять, не удалять и не перезаписывать (сверять перед заменой).
- `.gitignore` скрывает `.env` и `.env.*`, кроме `.env.*.demo`.

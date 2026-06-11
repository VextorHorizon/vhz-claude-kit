# vhz-claude-skills

Personal Claude Code skill plugin — Obsidian second brain workflows backed up here.

## Skills

| Skill | Trigger | What it does |
|---|---|---|
| `obsidian-vault` | "open vault", "load obsidian" | Loads vault into context, activates ingest/query/lint/diary workflows |
| `obsidian-summarize` | "summarize for obsidian", "สรุปสิ่งที่คุยกัน" | Converts a conversation into a paste-ready Obsidian ingest block |
| `work-mode` | `/work-mode [project]` | Project execution session — loads progress, tracks tasks, writes checkpoints continuously |
| `skill-search` | `/skill-search [query]` | Finds best installed skill for a need; falls back to skillsmp.com and GitHub |

## Agents

Agents live in the `agents/` folder and are auto-loaded by Claude Code at session start.

| Agent | Model | What it does |
|---|---|---|
| `implementer` | Sonnet | Implements an already-agreed plan (coding/implementation work). Pinned to Sonnet so the main session can stay on a stronger model and delegate execution. |

## Setup

### 1. Set vault path

```bash
# Windows (PowerShell profile or Claude Code env)
$env:OBSIDIAN_VAULT = "C:\Users\you\Documents\my-vault"

# macOS / Linux
export OBSIDIAN_VAULT="$HOME/Documents/my-vault"
```

### 2. Install plugin

```
/plugin add https://github.com/VextorHorizon/vhz-claude-skills
```

## Vault structure expected

```
$OBSIDIAN_VAULT/
├── CLAUDE.md          ← schema + workflow rules (required)
├── index.md           ← page catalog
├── hotcaches.md       ← Q&A cache
├── log.md             ← append-only session log
├── data/
│   ├── daily/         ← Claude's session diary (YYYY-MM-DD.md)
│   ├── personal/
│   ├── research/
│   ├── reading/
│   └── work/          ← project progress files (*-progress.md)
├── raw/               ← unprocessed input, deleted after ingest
└── data/templates/
```

## work-mode

```
/work-mode my-project    ← loads data/work/my-project-progress.md
/work-mode               ← lists all progress files to pick from
```

Every interaction is logged to `raw/session-YYYY-MM-DD.md` for later ingest.

---

Personal backup — use at your own risk.

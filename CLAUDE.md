# CLAUDE.md

Instructions for restoring this kit onto a machine.

## Detect the platform first

Two variants of every OS-coupled file exist. Pick by platform — never mix them.

| | Windows | Linux / macOS |
|---|---|---|
| Settings | `config/claude/settings.json` | `config/claude/settings.linux.json` |
| Statusline | `config/claude/statusline-command.ps1` | `config/claude/statusline-command.sh` |
| Terminal theme | `config/windows-terminal/` | hex values only — see below |

Both settings files land at `~/.claude/settings.json`. The Linux one is not a patch, it is a
complete replacement.

## Restore

1. Copy the correct statusline script to `~/.claude/`.
2. Copy the correct settings file to `~/.claude/settings.json`.
3. **Edit the placeholder paths.** Claude Code does not expand `$env:` or `~` inside the
   `statusLine.command` string or in `env`. Both need a real absolute path:
   - `statusLine.command` → path to the script
   - `env.OBSIDIAN_VAULT` → path to the vault
4. On Linux, `chmod +x ~/.claude/statusline-command.sh`.
5. Restart Claude Code.

## Check dependencies before declaring success

The statusline fails silently if these are missing — it renders, just wrongly. Verify rather
than assume.

**Linux (Arch / EndeavourOS):**

```bash
sudo pacman -S jq noto-fonts-cjk
```

- `jq` — the bash statusline and both hooks parse stdin JSON with it. Missing means a blank
  statusline, no error.
- `noto-fonts-cjk` — **the kaomoji are CJK and Hangul, not emoji.** `눈_눈` is Korean,
  `｀・ω・´` is fullwidth Japanese. Arch ships no CJK font by default, so without this the
  script works perfectly and prints `□□_□□`. Do not debug the script before checking the font.

Windows needs neither: PowerShell is built in and Segoe UI covers CJK.

Verify end to end by running a tool and watching the statusline change, not by reading the
script.

## The statusline is three coupled parts

Restoring only the script leaves the tool slot permanently blank.

| Part | Where | Job |
|---|---|---|
| `statusline-command.{ps1,sh}` | `~/.claude/` | Renders the line |
| `statusLine` block | `settings.json` | Runs the script |
| `hooks` block | `settings.json` | `PreToolUse` writes `current-tool.txt`; `PostToolUse` and `PostToolUseFailure` delete it |

`PostToolUseFailure` is load-bearing. Without it a failed tool call strands the file and the
statusline sticks on a tool that already finished.

`current-tool.txt` is runtime scratch. Never commit it.

## Terminal theme

`config/windows-terminal/gruvbox-dark.json` is Windows Terminal's format. On Linux, Windows
Terminal does not exist — take the hex values and apply them in Kitty, Alacritty, Konsole, or
whatever the machine uses. The palette is portable, the file is not.

Keep `"theme": "dark-ansi"` in settings either way. It makes Claude Code emit ANSI colour
slots instead of hardcoded hex, so the terminal scheme drives everything.

## Permission allowlist policy

`permissions.allow` in both settings files is deliberately conservative. Never re-add an entry
whose wildcard lets a second command run. A trailing `*` on any of these is arbitrary code
execution, not a convenience:

| Never allowlist | Why |
|---|---|
| `node *`, `python *`, `sh *`, `pwsh *` | `-e` / `-c` runs anything |
| `npm *`, `npm run *`, `npm install *` | scripts and postinstall hooks |
| `git clone *`, `git fetch *`, `git push *` | `--upload-pack` / `--receive-pack` take a command |
| `git rebase *` | `--exec` takes a command |
| `git config *` | sets `core.pager` to a command that fires on the next git call |
| `gh api *`, `gh auth *`, `gh repo *` | full write access to the account, including repo deletion |
| `Remove-Item *`, `New-Item *`, `start *` | arbitrary filesystem writes and process launches |

Safe wildcards are read-only (`Get-Content *`, `Test-Path *`) or git subcommands that take no
command-valued flag (`git add *`, `git branch *`, `git ls-tree *`).

Audit before committing:

```bash
python -c "import json,io;[print(a) for p in ['config/claude/settings.json','config/claude/settings.linux.json'] for a in json.load(io.open(p,encoding='utf-8'))['permissions']['allow'] if a.rstrip(')').endswith('*')]"
```

## Before committing anything to this repo

Public repo. Never commit absolute user paths, client or employer project names, third-party
repo names, localhost service endpoints, or credentials. Use `C:\Users\you` and
`/home/you` placeholders.

```bash
grep -rniE 'C:\\+Users\\+[a-z]|/home/[a-z]+/|localhost:[0-9]+|sk-|ghp_|api[_-]?key|password' config/ docs/
```

Do not add Claude attribution to commits or PR bodies — no `Co-Authored-By`, no generated-with
footer, no session URLs.

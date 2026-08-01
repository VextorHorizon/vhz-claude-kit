# Config

Backup of the Claude Code + terminal setup. Restore by hand — there is no installer, the
steps are short and you should see what lands where.

```
config/
├─ claude/
│  ├─ settings.json            → ~/.claude/settings.json      (Windows)
│  ├─ settings.linux.json      → ~/.claude/settings.json      (Linux / macOS)
│  ├─ statusline-command.ps1   → ~/.claude/                   (Windows)
│  └─ statusline-command.sh    → ~/.claude/                   (Linux / macOS)
└─ windows-terminal/
   ├─ gruvbox-dark.json        → schemes[] in Windows Terminal settings.json
   └─ profile-defaults.json    → profiles.defaults in the same file
```

Pick one settings file and one statusline script per platform — never mix. The Linux settings
file is a complete replacement, not a patch. See [`../CLAUDE.md`](../CLAUDE.md) for the full
migration checklist.

### Linux dependencies

```bash
sudo pacman -S jq noto-fonts-cjk      # Arch / EndeavourOS
```

`jq` parses stdin JSON in the bash statusline and both hooks. `noto-fonts-cjk` matters more
than it looks: the kaomoji are **CJK and Hangul, not emoji** — `눈_눈` is Korean, `｀・ω・´`
is fullwidth Japanese. Arch ships no CJK font, so without it the script runs correctly and
prints `□□_□□`. Check the font before debugging the script.

Windows needs neither — PowerShell is built in, Segoe UI covers CJK.

---

## Kaomoji statusline

Shows the tool Claude is currently running, the model, and rate-limit bars:

```
(✿◠‿◠) editing | Opus 5 | 5h [###-------] 34% resets 2h11m | 7d [#####-----] 51% resets 3d4h
```

**This is three moving parts, not one file.** Restoring only the script gives you a
permanently blank tool slot.

| Part | Lives in | Job |
|---|---|---|
| `statusline-command.ps1` | `~/.claude/` | Reads `current-tool.txt`, renders the line |
| `statusLine` block | `settings.json` | Tells Claude Code to run the script |
| `hooks` block | `settings.json` | `PreToolUse` **writes** `current-tool.txt`; `PostToolUse` and `PostToolUseFailure` **delete** it |

`current-tool.txt` is runtime scratch — it is created and destroyed constantly and is not
backed up. The hooks recreate it.

`PostToolUseFailure` matters: without it, a failed tool call leaves the file behind and the
statusline gets stuck showing a tool that already finished.

### Restore

1. Copy `claude/statusline-command.ps1` → `~/.claude/statusline-command.ps1`
2. Copy `claude/settings.json` → `~/.claude/settings.json`
3. **Edit two placeholder paths** in `settings.json` — `C:\Users\you` is not expanded automatically:

   ```jsonc
   "env": { "OBSIDIAN_VAULT": "C:\\Users\\you\\Documents\\my-vault" },
   "statusLine": {
     "command": "powershell -ExecutionPolicy Bypass -File \"C:\\Users\\you\\.claude\\statusline-command.ps1\""
   }
   ```

4. Restart Claude Code.

Adding a tool to the kaomoji map: add a key to `$toolMap` in the script. Unmapped tools fall
back to `(｡◕‿◕｡) <ToolName>`, so nothing breaks if you skip it.

---

## Gruvbox terminal

Windows Terminal settings live at:

```
%LOCALAPPDATA%\Packages\Microsoft.WindowsTerminal_8wekyb3d8bbwe\LocalState\settings.json
```

1. Paste `gruvbox-dark.json` into the `"schemes": [ ]` array.
2. Merge `profile-defaults.json` into `"profiles": { "defaults": { } }`.

`defaults` is inherited by every profile — PowerShell, cmd, WSL, and anything added later.
Set it per-profile instead if you want exceptions.

Windows Terminal hot-reloads on save. No restart.

### Why these values

| Setting | Reason |
|---|---|
| `padding: "16"` | Stock is 0 — glyphs jam against the window edge. Biggest readability win here. |
| `antialiasingMode: "grayscale"` | Default ClearType throws colored fringes on glyph edges; against Gruvbox's warm `#282828` they read as smudges. |
| `opacity: 92` + `useAcrylic` | Acrylic is required for opacity to look like blur instead of ghosting. Below ~80 contrast suffers. |
| `scrollbarState: "hidden"` | Claude Code manages its own scroll region. |

### Pairing with Claude Code

`settings.json` here sets `"theme": "dark-ansi"`.

`dark-ansi` makes Claude Code emit ANSI colour slots instead of hardcoded hex, so the Gruvbox
scheme drives everything — diffs, tool names, dim text. Swap the terminal scheme later and
Claude Code follows with no reconfiguration.

Fonts are deliberately not pinned. Set `font.face` per machine.

---

## What was removed before committing

This repo is public. `settings.json` here is scrubbed, not a raw copy:

- 24 of 101 `permissions.allow` entries dropped — anything containing absolute user paths,
  client project names, third-party repos, or localhost service endpoints.
- The remaining 77 are generic patterns (`Bash(git add *)`, `PowerShell(Get-Process *)`) and
  are safe to restore as-is.
- `OBSIDIAN_VAULT` and the statusline path replaced with `C:\Users\you` placeholders.

Kept in full because they contain nothing personal: `hooks`, `spinnerVerbs` (58 kaomoji
thinking verbs), `enabledPlugins`, `extraKnownMarketplaces`, `model`, `effortLevel`, `tui`.

**Re-run the sweep before any future commit that touches this folder:**

```bash
grep -rniE 'C:\\+Users\\+[a-z]|localhost:[0-9]+|sk-|ghp_|api[_-]?key|password' config/
```

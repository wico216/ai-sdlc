---
name: sdlc:update
description: Update AI-SDLC to latest version with changelog display
---

<objective>
Check for AI-SDLC updates from GitHub, install if available, and display what changed.

Uses the GitHub API to check for new releases against the locally installed version.
</objective>

<process>

<step name="get_installed_version">
Read installed version:

```bash
cat __SDLC_HOME__/VERSION 2>/dev/null
```

**If VERSION file missing:**
```
## AI-SDLC Update

**Installed version:** Unknown

Your installation doesn't include version tracking.

Please re-install from the repository:
git clone https://github.com/wico216/ai-sdlc.git
cd ai-sdlc && ./install.sh
```

STOP here if no VERSION file. User needs to re-install.
</step>

<step name="check_latest_version">
Check GitHub for latest release:

```bash
curl -s https://api.github.com/repos/wico216/ai-sdlc/releases/latest 2>/dev/null | grep -o '"tag_name"[[:space:]]*:[[:space:]]*"[^"]*"' | grep -o '"[^"]*"$' | tr -d '"v'
```

**If no releases found, fall back to checking the VERSION file on main:**
```bash
curl -s https://raw.githubusercontent.com/wico216/ai-sdlc/main/src/VERSION 2>/dev/null
```

**If both fail:**
```
Couldn't check for updates (offline or GitHub unavailable).

To update manually:
  cd /path/to/ai-sdlc && git pull && ./install.sh
```

STOP here if GitHub unavailable.
</step>

<step name="compare_versions">
Compare installed vs latest:

**If installed == latest:**
```
## AI-SDLC Update

**Installed:** X.Y.Z
**Latest:** X.Y.Z

You're already on the latest version.
```

STOP here if already up to date.

**If installed > latest:**
```
## AI-SDLC Update

**Installed:** X.Y.Z
**Latest:** A.B.C

You're ahead of the latest release (development version?).
```

STOP here if ahead.
</step>

<step name="find_clone_dir">
Locate the AI-SDLC clone directory:

```bash
# Check common locations
for dir in \
  "$HOME/ai-sdlc" \
  "$HOME/Documents/ai-sdlc" \
  "$HOME/Documents/Work/ai-sdlc" \
  "$HOME/Projects/ai-sdlc" \
  "$HOME/Code/ai-sdlc" \
  "$HOME/repos/ai-sdlc"; do
  [ -d "$dir/.git" ] && echo "FOUND: $dir" && break
done
```

**If not found:** Ask user where they cloned the repo, or suggest re-cloning:
```
Could not find your ai-sdlc clone directory.

Option 1: Tell me where you cloned it
Option 2: Re-clone fresh:
  git clone https://github.com/wico216/ai-sdlc.git
  cd ai-sdlc && ./install.sh
```
</step>

<step name="show_changes_and_confirm">
**If update available**, fetch changelog and show what's new BEFORE updating:

```bash
cd {clone_dir} && git fetch origin main
git log --oneline HEAD..origin/main
```

Display preview and ask for confirmation:

```
## AI-SDLC Update Available

**Installed:** 0.1.0
**Latest:** 0.2.0

### What's New
────────────────────────────────────────────────────────────

{git log output showing commits between versions}

────────────────────────────────────────────────────────────

This will:
- Pull latest changes from GitHub
- Re-run install.sh to update commands, agents, and references
- Your project `.aidlc/` directories are NOT affected

Your custom files are preserved:
- Custom commands not in `sdlc/` directory
- Custom agents not prefixed with `sdlc-`
- Your CLAUDE.md files
```

Use AskUserQuestion:
- Question: "Proceed with update?"
- Options:
  - "Yes, update now"
  - "No, cancel"

**If user cancels:** STOP here.
</step>

<step name="run_update">
Run the update:

```bash
cd {clone_dir} && git pull origin main && ./install.sh
```

Capture output. If install fails, show error and STOP.

Clear the update cache so statusline indicator disappears:

```bash
rm -f __CLAUDE_HOME__/cache/sdlc-update-check.json
```
</step>

<step name="display_result">
Format completion message:

```
## AI-SDLC Updated: v{old} -> v{new}

Restart Claude Code to pick up the new commands.

[View releases](https://github.com/wico216/ai-sdlc/releases)
```
</step>

</process>

<success_criteria>
- [ ] Installed version read correctly
- [ ] Latest version checked via GitHub API
- [ ] Update skipped if already current
- [ ] Changes shown BEFORE update
- [ ] User confirmation obtained
- [ ] git pull + install.sh executed successfully
- [ ] Restart reminder shown
</success_criteria>

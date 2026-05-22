# homebrew-ccc

Homebrew tap for [Claude Command Center (CCC)](https://github.com/amirfish1/claude-command-center) — one local dashboard for every Claude Code, Codex, and Antigravity session on your Mac.

## Install

```bash
brew tap amirfish1/ccc
brew install ccc
```

Then either:

```bash
ccc                              # foreground
brew services start ccc          # brew-managed background
ccc --install-service            # CCC's own launchd agent
```

Open <http://localhost:8090>.

## License

[MIT](LICENSE)

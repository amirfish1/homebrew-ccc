class Ccc < Formula
  desc "Local command center for every Claude, Codex, and Antigravity session"
  homepage "https://github.com/amirfish1/claude-command-center"
  url "https://github.com/amirfish1/claude-command-center/archive/refs/tags/v4.9.0.tar.gz"
  sha256 "a1f5f465de666a7434d5a3b2319ba760513792778fc4d8de032a29e609f874b4"
  license "MIT"
  head "https://github.com/amirfish1/claude-command-center.git", branch: "main"

  # macOS only. The launchd integration in run.sh (--install-service) is
  # Darwin-specific; the dashboard works on Linux but the service install
  # path is plist-based. Mark macOS to avoid Linux brew users hitting that.
  depends_on :macos
  depends_on "python@3.12"

  def install
    # Copy the entire repo into libexec. run.sh uses $(dirname "$0") to
    # locate server.py, static/, hooks/, and skills/ relative to itself,
    # so every adjacent path must travel with it.
    libexec.install Dir["*"]

    # Wrapper on PATH. Pin python3 to the brew-managed interpreter so the
    # formula keeps working when the user's system python3 drifts.
    (bin/"ccc").write <<~SHELL
      #!/bin/bash
      export PATH="#{Formula["python@3.12"].opt_bin}:$PATH"
      exec "#{libexec}/run.sh" "$@"
    SHELL
    (bin/"ccc").chmod 0755
  end

  service do
    run opt_bin/"ccc"
    keep_alive true
    log_path var/"log/ccc.out.log"
    error_log_path var/"log/ccc.err.log"
    environment_variables PORT: "8090"
  end

  def caveats
    <<~EOS
      CCC needs the Claude Code CLI to be useful:
        https://docs.claude.com/en/docs/claude-code

      Optional integrations (UI surfaces light up when these exist on PATH):
        brew install gh           # GitHub PR / issue surfaces
        npm install -g vercel     # Vercel deploy status

      Start in the foreground:
        ccc

      Or run it as a brew-managed background service:
        brew services start ccc
        open http://localhost:8090

      Or install as a per-user launchd agent (CCC's native service install):
        ccc --install-service

      First launch installs two hooks into ~/.claude/settings.json that every
      Claude Code session on this machine writes sidecar state to. The
      dashboard reads that state — it does not own session execution.

      To bind to LAN (e.g. for a phone over Tailscale):
        CCC_BIND_HOST=0.0.0.0 \\
          CCC_ALLOWED_ORIGIN=http://your-mac.tailnet.ts.net:8090 \\
          brew services restart ccc
        # Or restart with explicit env. See SECURITY.md in the repo.
    EOS
  end

  test do
    # Smoke test: the launcher should print its usage banner and exit 0
    # without needing Claude Code or a free port.
    output = shell_output("#{bin}/ccc --help")
    assert_match "Usage:", output
    assert_match "--install-service", output

    # The wrapper should expose the core repo files under libexec.
    assert_predicate libexec/"server.py", :exist?
    assert_predicate libexec/"run.sh", :exist?
  end
end

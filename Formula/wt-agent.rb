class WtAgent < Formula
  desc "WatchTower — run fleets of AI coding-agent workers and know which queues are stuck"
  homepage "https://github.com/amirfish1/watchtower"
  url "https://github.com/amirfish1/watchtower/archive/refs/tags/v0.1.0.tar.gz"
  sha256 "488a097b115d15024f8892c4133dfa34648fdcd5e97ec03692c0a4f8d7877c49"
  license "MIT"
  head "https://github.com/amirfish1/watchtower.git", branch: "main"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath

    # wt is the entry point; the virtualenv wrapper is already linked.
    # Ensure the bin/wt shim points to our venv so system python doesn't
    # shadow it across brew upgrades.
    (bin/"wt").unlink if (bin/"wt").exist?
    bin.install_symlink libexec/"bin/wt"
  end

  test do
    output = shell_output("#{bin}/wt --help")
    assert_match "wt", output
  end
end

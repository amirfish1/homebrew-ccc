class WatchtowerCli < Formula
  desc "WatchTower — run fleets of AI coding-agent workers and know which queues are stuck"
  homepage "https://github.com/amirfish1/watchtower"
  url "https://github.com/amirfish1/watchtower/releases/download/v0.1.0/watchtower_cli-0.1.0.tar.gz"
  sha256 "e726e669bcafe1f4313b35b00037a42b2b9844f74989f0b5a123da4a595f8eb6"
  license "MIT"

  depends_on "python@3.11"

  def install
    venv = virtualenv_create(libexec, "python3.11")
    venv.pip_install_and_link buildpath

    # wt is the entry point installed by the venv; ensure our bin/ symlink
    # points to the venv shim rather than any ambient system 'wt'.
    (bin/"wt").unlink if (bin/"wt").exist?
    bin.install_symlink libexec/"bin/wt"
  end

  test do
    output = shell_output("#{bin}/wt --help")
    assert_match "wt", output
  end
end

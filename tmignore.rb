class Tmignore < Formula
  desc "Exclude development files from Time Machine backups"
  homepage "https://github.com/samuelmeuli/tmignore"
  url "https://github.com/samuelmeuli/tmignore/releases/download/v1.2.2/tmignore"
  sha256 "80a8b0e3e05dc30113b9a4db1997b39fadfabbe2a58fa7f63ac4f757b2de9012"
  head "https://github.com/samuelmeuli/tmignore.git"

  depends_on :macos => :high_sierra

  def install
    bin.install "./tmignore"
    system "curl", "-L","-o", "#{prefix}/homebrew.tmignore.plist", "https://github.com/samuelmeuli/tmignore/raw/master/homebrew.tmignore.plist"
  end

  test do
    system "#{bin}/tmignore", "version"
  end
end

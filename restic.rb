require 'securerandom'

class Restic < Formula
  desc "restic backup program"
  homepage "https://restic.github.io/"

  url "https://github.com/restic/restic/archive/v0.0.1alpha.tar.gz"
  sha256 "b8cc991ba73957056b17082edf8d4113bf88bcd6c0827ad127a2e68c2a9b12d0"
  version "0.0.1alpha"

  head "https://github.com/restic/restic.git"

  depends_on 'go'

  def install
    system "make"
    system "mkdir #{prefix}/bin"
    system "cp restic #{prefix}/bin"
  end

  test do
    test_repo_name = SecureRandom.hex
    test_repo_path = "/tmp/restic-#{test_repo_name}"

    system "RESTIC_PASSWORD=foo restic -r #{test_repo_path} init"
    system "RESTIC_PASSWORD=foo restic -r #{test_repo_path} backup #{$0}"

    snapshot = `RESTIC_PASSWORD=foo restic -r #{test_repo_path} snapshots | tail -n+3 | head -n1 | awk '{print $1}'`
    snapshot.chomp!

    system "RESTIC_PASSWORD=foo restic -r #{test_repo_path} restore #{snapshot} -t #{test_repo_path}-restore"
    system "diff -q #{$0} #{test_repo_path}-restore/#{File.basename($0)}"

    system "rm -rf #{test_repo_path}"
  end
end

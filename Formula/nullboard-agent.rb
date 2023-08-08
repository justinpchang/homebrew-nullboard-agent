require "language/node"

class NullboardAgent < Formula
  desc "Local backup utility for Nullboard"
  homepage "https://github.com/justinpchang/nullboard-agent-express"
  url "https://registry.npmjs.org/nullboard-agent-express/-/nullboard-agent-express-0.0.5.tgz"
  sha256 "0cb4196dde7f05a819afdd8d9e524d3a3ff309c23b78c4da7b8a13e19ede8dc7"
  license "BSD-2-Clause"

  depends_on "node"

  def install
    system "npm", "install", *Language::Node.std_npm_install_args(libexec)
    bin.install_symlink Dir["#{libexec}/bin/*"]
  end

  service do
    run [opt_bin / "nullboard-agent", "server"]
    log_path var / "log/nullboard-agent.log"
    error_log_path var / "log/nullboard-agent.log"
    keep_alive true
  end

  test do
    token = shell_output("#{bin}/nullboard-agent token").strip

    pid = fork { exec "#{bin}/nullboard-agent server" }

    sleep 3

    output =
      shell_output(
        "curl -sX PUT http://localhost:10001/config -H 'x-access-token: #{token}'",
      )
    assert_match "true", output
  ensure
    Process.kill("HUP", pid)
  end
end

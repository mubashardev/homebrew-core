class Flyctl < Formula
  desc "Command-line tools for fly.io services"
  homepage "https://fly.io"
  url "https://github.com/superfly/flyctl.git",
      tag:      "v0.2.127",
      revision: "4338c9a366483cc3eb1c4893d0a1163930a325bf"
  license "Apache-2.0"
  head "https://github.com/superfly/flyctl.git", branch: "master"

  # Upstream tags versions like `v0.1.92` and `v2023.9.8` but, as of writing,
  # they only create releases for the former and those are the versions we use
  # in this formula. We could omit the date-based versions using a regex but
  # this uses the `GithubLatest` strategy, as the upstream repository also
  # contains over a thousand tags (and growing).
  livecheck do
    url :stable
    strategy :github_latest
  end

  bottle do
    sha256 cellar: :any_skip_relocation, arm64_sequoia:  "3b3aae0fdc404871d27573ccbe95dcf39c696bcb7174e39bb81ee733630375b9"
    sha256 cellar: :any_skip_relocation, arm64_sonoma:   "3b3aae0fdc404871d27573ccbe95dcf39c696bcb7174e39bb81ee733630375b9"
    sha256 cellar: :any_skip_relocation, arm64_ventura:  "3b3aae0fdc404871d27573ccbe95dcf39c696bcb7174e39bb81ee733630375b9"
    sha256 cellar: :any_skip_relocation, arm64_monterey: "3b3aae0fdc404871d27573ccbe95dcf39c696bcb7174e39bb81ee733630375b9"
    sha256 cellar: :any_skip_relocation, sonoma:         "2d4a04eb66f5b03171436ebf4b393ad3e6af6e3bb8290edc5d3482ddf40beb00"
    sha256 cellar: :any_skip_relocation, ventura:        "2d4a04eb66f5b03171436ebf4b393ad3e6af6e3bb8290edc5d3482ddf40beb00"
    sha256 cellar: :any_skip_relocation, monterey:       "2d4a04eb66f5b03171436ebf4b393ad3e6af6e3bb8290edc5d3482ddf40beb00"
    sha256 cellar: :any_skip_relocation, x86_64_linux:   "ce76a16fc64205f043f1d319225a01ac5e803b86a0ac35109a52121ebd5bbbc5"
  end

  depends_on "go" => :build

  def install
    ENV["CGO_ENABLED"] = "0"
    ldflags = %W[
      -s -w
      -X github.com/superfly/flyctl/internal/buildinfo.buildDate=#{time.iso8601}
      -X github.com/superfly/flyctl/internal/buildinfo.buildVersion=#{version}
      -X github.com/superfly/flyctl/internal/buildinfo.commit=#{Utils.git_short_head}
    ]
    system "go", "build", *std_go_args(ldflags:), "-tags", "production"

    bin.install_symlink "flyctl" => "fly"

    generate_completions_from_executable(bin/"flyctl", "completion")
  end

  test do
    assert_match "flyctl v#{version}", shell_output("#{bin}/flyctl version")

    flyctl_status = shell_output("#{bin}/flyctl status 2>&1", 1)
    assert_match "Error: No access token available. Please login with 'flyctl auth login'", flyctl_status
  end
end

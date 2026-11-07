class AndroidTetherMac < Formula
  desc "USB tethering for Android phones on macOS (userspace RNDIS driver, no kext)"
  homepage "https://github.com/MoshiDuck/android-tether-mac"
  url "https://github.com/MoshiDuck/android-tether-mac/archive/refs/tags/v0.1.1.tar.gz"
  sha256 "73976800eaf69eddd0bfe055e86a581de29b193064fd3b63e9d8cc2cb500492d"
  license "GPL-3.0-or-later"
  head "https://github.com/MoshiDuck/android-tether-mac.git", branch: "main"

  depends_on :macos
  depends_on "pkgconf" => :build
  depends_on "libusb"

  def install
    # Garde les sources dans libexec : tethermac-install les recompile en tant
    # qu'utilisateur et installe le service (root) + l'icône de barre de menus.
    libexec.install Dir["*"]
    system "make", "-C", libexec.to_s
    bin.install_symlink libexec/"rndis-tether"

    (bin/"tethermac-install").write <<~SH
      #!/bin/sh
      exec sudo "#{libexec}/install.sh" "$@"
    SH
    (bin/"tethermac-uninstall").write <<~SH
      #!/bin/sh
      exec sudo "#{libexec}/uninstall.sh" "$@"
    SH
  end

  def caveats
    <<~EOS
      Android only (iPhones already work natively on macOS).

      Install the background service and the menu bar icon with:
        tethermac-install

      Remove them with:
        tethermac-uninstall

      After `brew upgrade`, run `tethermac-install` again to update the service.
    EOS
  end

  test do
    assert_match "Usage:", shell_output("#{bin}/rndis-tether -h 2>&1", 2)
  end
end

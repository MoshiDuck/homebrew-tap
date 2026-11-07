class AndroidTetherMac < Formula
  desc "USB tethering for Android phones on macOS (userspace RNDIS driver, no kext)"
  homepage "https://github.com/MoshiDuck/android-tether-mac"
  url "https://github.com/MoshiDuck/android-tether-mac/archive/refs/tags/v0.2.0.tar.gz"
  sha256 "23e724cf2cd261740290d491e005e335604c82ef71773fd6a671b6c4b63be1a2"
  license "GPL-3.0-or-later"
  head "https://github.com/MoshiDuck/android-tether-mac.git", branch: "main"

  depends_on "pkgconf" => :build
  depends_on "libusb"
  depends_on :macos

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

cask "morpheus121" do
  version "1.2.1"
  sha256 "692b0b3af5015c5c20fcf329ad8e1c4dd9356f43136642a7b1bb436eb7018aa8"

  url "https://imc.zih.tu-dresden.de/morpheus/packages/mac/Morpheus_v#{version}_rev_1047.dmg",
      verified: "imc.zih.tu-dresden.de/morpheus/"
  name "Morpheus"
  desc "Modelling environment for multi-cellular systems biology"
  homepage "https://morpheus.gitlab.io/"

  livecheck do
    url "https://imc.zih.tu-dresden.de/morpheus/packages/mac/"
    regex(/href=.*?Morpheus[._-](\d+(?:\.\d+)*)\.dmg/i)
  end

  app "Morpheus.app"

  zap trash: [
    "~/Library/Application Support/data/Morpheus",
    "~/Library/Application Support/Morpheus",
    "~/Library/Application Support/CrashReporter/morpheus_*.plist",
    "~/Library/Caches/Morpheus",
    "~/Library/Preferences/morpheus-gui.plist",
    "~/Library/Preferences/io.gitlab.morpheus.morpheus.plist",
    "~/Library/Preferences/de.tu-dresden.Morpheus.plist",
    "~/Library/Preferences/org.morpheus.Morpheus.plist",
    "~/Library/Saved Application State/de.tu-dresden.Morpheus.savedState",
    "~/Library/Saved Application State/io.gitlab.morpheus.morpheus.savedState",
  ]
end

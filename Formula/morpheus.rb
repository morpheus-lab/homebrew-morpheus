class Morpheus < Formula
  desc "Modelling environment for multi-cellular systems biology"
  homepage "https://morpheus.gitlab.io/"
  url "https://gitlab.com/morpheus.lab/morpheus/-/archive/v2.3.0_1/morpheus-v2.3.0_1.tar.gz"
  sha256 "af978a1918af10d47c5af60924ad5d3d5bad24d14406eb6f7baf05a758b3eb60"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+(?:_?\d+)?)$/i)
  end

  #  bottle do
  #    root_url "https://github.com/morpheus-lab/homebrew-morpheus/releases/download/morpheus-2.2.6"
  #    sha256 cellar: :any,                 arm64_monterey:               "f895c1c4757d1af1a99a795a80313d548cac928cf74f6c637101f57286f27110"
  #    sha256 cellar: :any,                 monterey:                     "6e9961d869546b16d93976f6aff99393477d7cd783a10df716f872d7d96209dd"
  #    sha256 cellar: :any,                 catalina:                     "d3f22b183cbb91227991e0e94440b8af0eeb05f0a56e90c2092dbd7bc2a7f4a5"
  #    sha256 cellar: :any_skip_relocation, x86_64_linux:                 "3264fd1d6fc496ff6b76cbf51c46ccefd0eed5b76d75df6ca6b510258c23de88"
  #  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ffmpeg"   # Runtime dependencies
  depends_on "gnuplot"  # Runtime dependencies
  depends_on "graphviz"
  depends_on "libomp"
  depends_on "libtiff"
  depends_on "qt@5"

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  def install
    args = std_cmake_args
    args << "-DMORPHEUS_RELEASE_BUNDLE=ON" if OS.mac?

    system "cmake", ".", *args
    system "make", "install"

    if OS.mac?
      bin.write_exec_script "#{prefix}/Morpheus.app/Contents/MacOS/morpheus"

      (bin/"morpheus-gui").write <<~EOS
        #!/bin/bash
        open #{prefix}/Morpheus.app
      EOS
      (bin/"morpheus-gui").chmod 0555
    end
  end

  def post_install
    if OS.mac?
      # Set PATH environment variable including Homebrew prefix in macOS app bundle
      inreplace "#{prefix}/Morpheus.app/Contents/Info.plist", "<key>CFBundleExecutable</key>",
        <<~EOS.chomp
          <key>LSEnvironment</key>
          <dict>
              <key>PATH</key>
              <string>#{ENV["PATH"]}</string>
          </dict>
          <key>CFBundleExecutable</key>
        EOS
    end
  end

  def caveats
    if OS.mac?
      <<~EOS
        To start the Morpheus GUI, type the following command:

          morpheus-gui

        Or add Morpheus to your Applications folder with:

          ln -sf #{prefix}/Morpheus.app /Applications
      EOS
    end
  end

  test do
    (testpath/"test.xml").write <<~EOF
      <?xml version='1.0' encoding='UTF-8'?>
      <MorpheusModel version="4">
          <Description>
              <Details></Details>
              <Title></Title>
          </Description>
          <Space>
              <Lattice class="linear">
                  <Neighborhood>
                      <Order>1</Order>
                  </Neighborhood>
                  <Size value="100,  0.0,  0.0" symbol="size"/>
              </Lattice>
              <SpaceSymbol symbol="space"/>
          </Space>
          <Time>
              <StartTime value="0"/>
              <StopTime value="0"/>
              <TimeSymbol symbol="time"/>
          </Time>
          <Analysis>
              <ModelGraph include-tags="#untagged" format="dot" reduced="false"/>
          </Analysis>
      </MorpheusModel>
    EOF

    assert_match "Simulation finished", shell_output("#{bin}/morpheus --file test.xml")
  end
end

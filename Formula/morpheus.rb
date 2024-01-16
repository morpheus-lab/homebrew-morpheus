class Morpheus < Formula
  desc "Modelling environment for multi-cellular systems biology"
  homepage "https://morpheus.gitlab.io/"
  url "https://gitlab.com/morpheus.lab/morpheus/-/archive/v2.3.5/morpheus-v2.3.5.tar.gz"
  sha256 "4270fb0d01939aa208025530f078931d806c57f608fa2798009d3adb0d6207f5"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+(?:_?\d+)?)$/i)
  end

  bottle do
    root_url "https://github.com/morpheus-lab/homebrew-morpheus/releases/download/morpheus-2.3.5"
    sha256 cellar: :any,                 arm64_sonoma: "668d598eca20eabf4f96f9fae8990a74365530a95d0075555bb27279e35952f4"
    sha256 cellar: :any,                 sonoma:       "a8401d851948575372e43e63f2c9ac34477ac608c56775a3b44d261d71dc4ee9"
    sha256 cellar: :any,                 ventura:      "d0ff492eff6c6ccccebd684dee3c948a49c8cdba1ae5ad2feb6323bc5a3e2410"
    sha256 cellar: :any_skip_relocation, x86_64_linux: "847610f4942e1db49a5402660daa1b7bf8501eba9fdf98dc448a4da9a6750a69"
  end

  depends_on "boost" => :build
  depends_on "cmake" => :build
  depends_on "doxygen" => :build
  depends_on "ninja" => :build
  depends_on "gnuplot"
  depends_on "graphviz"
  depends_on "libomp"
  depends_on "libtiff"
  depends_on "qt@5"
  depends_on "ffmpeg" => :recommended # Runtime dependencies

  uses_from_macos "bzip2"
  uses_from_macos "libxml2"
  uses_from_macos "zlib"

  def install
    args = std_cmake_args
    args << "-G Ninja"
    args << "-DMORPHEUS_RELEASE_BUNDLE=ON" if OS.mac?

    system "cmake", *args, "."
    system "ninja", "install"

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

        For more information about this release, visit: https://morpheus.gitlab.io/download/latest/
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

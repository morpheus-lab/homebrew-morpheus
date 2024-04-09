class Morpheus < Formula
  desc "Modelling environment for multi-cellular systems biology"
  homepage "https://morpheus.gitlab.io/"
  url "https://gitlab.com/morpheus.lab/morpheus/-/archive/v2.3.7/morpheus-v2.3.7.tar.gz"
  sha256 "ad5694a098e4752db53659ee983c3ae417a43747320e73c3005f6cf88b52d55c"
  license "BSD-3-Clause"

  livecheck do
    url :stable
    regex(/^v?(\d+(?:\.\d+)+(?:_?\d+)?)$/i)
  end

  option "with-sbml", "Enable SBML import via the internal libSBML build"

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
    args = []
    args << "-G Ninja"

    if OS.mac?
      args << "-DMORPHEUS_RELEASE_BUNDLE=ON"

      # SBML import currently disabled by default due to libSBML build errors with some macOS SDKs
      args << "-DMORPHEUS_SBML=OFF" if build.without? "sbml"
    end

    system "cmake", "-S", ".", "-B", "build", *args, *std_cmake_args
    system "cmake", "--build", "build"
    system "cmake", "--install", "build"

    if OS.mac?
      bin.write_exec_script "#{prefix}/Morpheus.app/Contents/MacOS/morpheus"
      bin.write_exec_script "#{prefix}/Morpheus.app/Contents/MacOS/morpheus-gui"
    end
  end

  def post_install
    if OS.mac? && File.read("#{prefix}/Morpheus.app/Contents/Info.plist").include?("HOMEBREW_BIN_PATH")
      # Set PATH environment variable including Homebrew prefix in macOS app bundle
      inreplace "#{prefix}/Morpheus.app/Contents/Info.plist", "HOMEBREW_BIN_PATH", "#{HOMEBREW_PREFIX}/bin"
    end
  end

  def caveats
    on_macos do
      <<~EOS
        To start the Morpheus GUI, type the following command:

          morpheus-gui

        Or add Morpheus to your Applications folder with:

          ln -sf #{opt_prefix}/Morpheus.app /Applications
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

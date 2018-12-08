class Satysfi < Formula
  desc "Statically-typed, functional typesetting system"
  homepage "https://github.com/gfngfn/SATySFi"
  url "https://github.com/gfngfn/SATySFi/archive/v0.0.2.tar.gz"
  sha256 "91b98654a99d8d13028d4c7334efa9d8cc792949b9ad1be5ec8b4cbacfaea732"
  head "https://github.com/gfngfn/SATySFi.git"

  depends_on "ocaml" => :build
  depends_on "opam" => :build

  def install
    # mktemp to prevent opam from recursively copying a directory into itself
    mktemp do
      opamroot = Pathname.pwd/"opamroot"
      opamroot.mkpath
      ENV["OPAMROOT"] = opamroot
      ENV["OPAMYES"] = "1"
      system "opam", "init", "--no-setup", "--disable-sandboxing"

      head do
        system "opam", "switch", "4.07.1"
      end

      stable do
        system "opam", "switch", "4.06.1"
      end
      
      system "opam", "config", "exec", "--", "opam", "repository", "add", "satysfi-external", "https://github.com/gfngfn/satysfi-external-repo.git"
      system "opam", "config", "exec", "--", "opam", "pin", "add", "-n", "satysfi", buildpath
      system "opam", "config", "exec", "--", "opam", "install", "satysfi", "--deps-only"

      system "mkdir", "-p", "temp"
      system "unzip", "-o", "lm2.004otf.zip", "*.otf", "-d", "lib-satysfi/dist/fonts/"
      system "unzip", "-o", "latinmodern-math-1959.zip", "*.otf", "-d", "temp/"
      system "cp", "temp/latinmodern-math-1959/otf/latinmodern-math.otf", "lib-satysfi/dist/fonts/"
      system "unzip", "-o", "junicode-1.002.zip", "*.ttf", "-d", "lib-satysfi/dist/fonts/"
      system "unzip", "-o", "IPAexfont00301.zip", "*.ttf", "-d", "temp/"
      system "cp", "temp/IPAexfont00301/ipaexg.ttf", "lib-satysfi/dist/fonts/"
      system "cp", "temp/IPAexfont00301/ipaexm.ttf", "lib-satysfi/dist/fonts/"
      system "opam", "config", "exec", "--", "make", "-C", buildpath, "PREFIX=#{prefix}"
    end
    system "make", "install", "PREFIX=#{prefix}"
  end

  test do
    assert_equal "! [Error] no input file designation.\n", shell_output("#{bin}/satysfi 2>&1", 1)
  end
end

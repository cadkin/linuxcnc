{
  src, version,

  lib, stdenv,

  automake, autoconf, pkg-config, ps, psmisc, sysvtools, util-linux, man, intltool, python3, groff, asciidoc,

  libtirpc, udev, libmodbus, libusb1, glib, gtk3, libgpiod, boost187, tcl, tk, tclPackages, pango, gobject-introspection, readline, libGLU, xorg, libepoxy,

  yapps2
}:

let
  boost = boost187.override {
    python = python3;
    enablePython = true;
  };

  pyenv = python3.withPackages (py: [
    py.pygobject3
    py.tkinter
  ]);
in stdenv.mkDerivation rec {
  pname = "linuxcnc";

  inherit version;
  inherit src;

  #sourceRoot = "source/src";

  buildInputs = [
    libtirpc
    udev
    libmodbus
    libusb1
    glib
    gtk3
    libgpiod
    tcl
    tk
    boost
    tclPackages.bwidget
    tclPackages.tclx
    pango
    readline
    libGLU
    xorg.libXmu
    pyenv
    libepoxy
  ];

  nativeBuildInputs = [
    automake
    autoconf
    pkg-config
    ps
    psmisc
    sysvtools
    util-linux
    intltool
    man
    yapps2
    gobject-introspection
    groff
    asciidoc
  ];

  postPatch = ''
    cd src
  '';

  preConfigure = ''
    ./autogen.sh
  '';

  configureFlags = [
    "--with-realtime=uspace"
    "--with-tclConfig=${tcl}/lib/tclConfig.sh"
    "--with-tkConfig=${tk}/lib/tkConfig.sh"
    "--enable-non-distributable=yes"
    "--with-boost-libdir=${boost}/lib"
    "--with-locale-dir=${placeholder "out"}/share"
    "--with-sitepy=${placeholder "out"}/lib/python3/dist-packages"
  ];

  makeFlags = [
    "BUILD_VERBOSE=1"
  ];

  meta = {
    description = "Control software for CNC machines";
    longDescription = ''
      LinuxCNC controls CNC machines. It can drive milling machines, lathes, 3d
      printers, laser cutters, plasma cutters, robot arms, hexapods, and more.
    '';
    homepage = "https://github.com/LinuxCNC/linuxcnc";
    license = lib.licenses.gpl2;
  };
}

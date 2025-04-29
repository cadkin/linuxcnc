{
  lib, buildPythonPackage, fetchPypi
}:

buildPythonPackage rec {
  pname = "yapps2";
  version = "2.2.0";

  src = fetchPypi {
    pname = "Yapps2";
    inherit version;
    hash = "sha256-+1hC0XF3q8N34yHtzHNJsbkD5NiDmBeE8n+lvuGrAJE=";
  };
}

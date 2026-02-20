{
  androidenv,
  includeEmulator ? false,
  platformVersions ? ["35" "36"],
  buildToolsVersions ? ["35.0.1" "28.0.3"],
  platformToolsVersion ? "35.0.1",
  cmdLineToolsVersion ? "9.0",
  ...
}: let
  androidComposition = androidenv.composeAndroidPackages {
    cmdLineToolsVersion = cmdLineToolsVersion;
    platformToolsVersion = platformToolsVersion;
    buildToolsVersions = buildToolsVersions;
    platformVersions = platformVersions;
    abiVersions = ["x86_64"];
    systemImageTypes = ["google_apis"];
    includeEmulator = includeEmulator;
    includeSystemImages = includeEmulator;
    includeNDK = false;
  };
in
  androidComposition.androidsdk

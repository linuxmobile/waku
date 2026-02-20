{
  description = "waku (枠) - A frame for Flutter development, defined by Nix.";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";
    systems.url = "github:nix-systems/default";
  };

  outputs = {
    self,
    nixpkgs,
    systems,
    ...
  }: let
    eachSystem = fn:
      nixpkgs.lib.genAttrs
      (import systems)
      (system:
        fn (import nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        }));

    pkgsDir = builtins.readDir ./pkgs;
    dirs = builtins.filter (
      name:
        pkgsDir.${name}
        == "directory"
        && builtins.hasAttr "package.nix" (builtins.readDir (./pkgs/${name}))
    ) (builtins.attrNames pkgsDir);
  in {
    templates = {
      default = {
        path = ./.;
        description = "waku (枠) - A precision-crafted frame for Flutter, providing a stable boundary with curated Android SDK and emulator support.";
      };
      flutter = self.templates.default;
    };

    packages = eachSystem (pkgs: let
      localPkgs = pkgs.lib.genAttrs dirs (name:
        pkgs.callPackage (./pkgs/${name}/package.nix) {
          inherit (localPkgs) android-sdk;
        });
    in
      localPkgs);

    formatter = eachSystem (pkgs: pkgs.alejandra);

    devShells = eachSystem (pkgs: let
      # --- USER CONFIGURATION ---
      # Easily update these versions when needed
      androidConfig = {
        platformVersions = ["34" "35" "36"];
        buildToolsVersions = ["35.0.1" "28.0.3"];
        platformToolsVersion = "35.0.1";
        includeEmulator = false;
      };

      # Set your preferred browser here (e.g., pkgs.chromium, pkgs.ungoogled-chromium)
      # Some browsers might need extra configuration for the binary name below.
      defaultChromePackage = pkgs.google-chrome;

      # If you use a browser outside of nixpkgs (e.g., helium), set its path here.
      # Example: "/usr/bin/helium" or "helium" if it's in your PATH.
      defaultChromeExecutable = null;
      # --- END USER CONFIGURATION ---

      androidSdk = pkgs.callPackage ./pkgs/android-sdk/package.nix androidConfig;
      androidSdkWithEmulator = pkgs.callPackage ./pkgs/android-sdk/package.nix (androidConfig // {includeEmulator = true;});

      basePackages = with pkgs; [
        flutter
        gradle
        jdk17
        scrcpy
      ];

      mkDevShell = {
        sdk,
        withEmulator ? false,
        chromePackage ? defaultChromePackage,
        chromeExecutable ? defaultChromeExecutable,
      }:
        pkgs.mkShell {
          buildInputs =
            basePackages
            ++ [sdk]
            ++ (pkgs.lib.optional (chromePackage != null) chromePackage)
            ++ (
              if withEmulator
              then [(pkgs.callPackage ./pkgs/start-emulator/package.nix {android-sdk = sdk;})]
              else []
            );

          shellHook = let
            # Determine the chrome executable path
            chromeBin =
              if chromeExecutable != null
              then chromeExecutable
              else if chromePackage != null
              then let
                binaryName =
                  if chromePackage ? meta && chromePackage.meta ? mainProgram
                  then chromePackage.meta.mainProgram
                  else if chromePackage ? pname
                  then chromePackage.pname
                  else "google-chrome";
              in "${chromePackage}/bin/${binaryName}"
              else "google-chrome";
          in
            ''
              export ANDROID_HOME="${sdk}/libexec/android-sdk"
              export ANDROID_SDK_ROOT="${sdk}/libexec/android-sdk"
              export ANDROID_AVD_HOME="$HOME/.android/avd"
              export JAVA_HOME="${pkgs.jdk17.home}"
              export CHROME_EXECUTABLE="${chromeBin}"

              # Gradle and Android paths
              export PATH="$PATH:$ANDROID_HOME/emulator"
              export PATH="$PATH:$ANDROID_HOME/platform-tools"
              export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
              export PATH="$PATH:$HOME/.pub-cache/bin"

              # Fix for aapt2 not found by Gradle
              export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/${builtins.head androidConfig.buildToolsVersions}/aapt2"
            ''
            + (
              if withEmulator
              then ''
                # Create emulator if it doesn't exist
                if ! avdmanager list avd | grep -q "flutter_emulator"; then
                  echo "Creating new emulator..."
                  avdmanager create avd \
                    -n flutter_emulator \
                    -k 'system-images;android-34;google_apis;x86_64' \
                    -d pixel_6
                else
                  echo "Emulator 'flutter_emulator' already exists"
                fi
              ''
              else ""
            );
        };
    in {
      default = mkDevShell {sdk = androidSdk;};
      emulator = mkDevShell {
        sdk = androidSdkWithEmulator;
        withEmulator = true;
      };
      chromium = mkDevShell {
        sdk = androidSdk;
        chromePackage = pkgs.chromium;
      };
    });
  };
}

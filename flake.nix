{
  description = "Flutter development environment with Android Emulator";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    systems.url = "github:nix-systems/default-linux";
    flake-parts.url = "github:hercules-ci/flake-parts";
    flake-parts.inputs.nixpkgs-lib.follows = "nixpkgs";
  };

  outputs = {flake-parts, ...} @ inputs:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = import inputs.systems;
      perSystem = {
        pkgs,
        system,
        ...
      }: let
        emulatorScripts = with pkgs; {
          startEmulator = writeShellScriptBin "start-emulator" ''
            export QT_QPA_PLATFORM=xcb
            export QT_WAYLAND_DISABLE_WINDOWDECORATION=1
            export ANDROID_EMULATOR_USE_SYSTEM_LIBS=1
            export LIBGL_ALWAYS_SOFTWARE=1

            GPU_MODE=''${1:-swiftshader_indirect}
            echo "Starting emulator with GPU mode: $GPU_MODE"

            pkill -9 emulator-x86_64 2>/dev/null

            $ANDROID_HOME/emulator/emulator -avd flutter_emulator \
              -gpu $GPU_MODE \
              -accel on \
              -memory 8192 \
              -cores 4 \
              -no-boot-anim \
              -qemu -smp 4,threads=1 \
              -enable-kvm
          '';
        };
        pkgs = import inputs.nixpkgs {
          inherit system;
          config = {
            allowUnfree = true;
            android_sdk.accept_license = true;
          };
        };

        androidComposition = pkgs.androidenv.composeAndroidPackages {
          cmdLineToolsVersion = "9.0";
          platformToolsVersion = "34.0.4";
          buildToolsVersions = ["34.0.0"];
          platformVersions = ["34"];
          abiVersions = ["x86_64"];
          systemImageTypes = ["google_apis"];
          includeEmulator = true;
          includeSystemImages = true;
          includeNDK = false;
        };
        androidSdk = androidComposition.androidsdk;
      in {
        devShells.default = pkgs.mkShell {
          name = "flutter-android-env";

          shellHook = ''
            export ANDROID_HOME="${androidSdk}/libexec/android-sdk"
            export ANDROID_SDK_ROOT="${androidSdk}/libexec/android-sdk"
            export ANDROID_AVD_HOME="$HOME/.android/avd"
            export JAVA_HOME="${pkgs.jdk17.home}"
            export PATH="$PATH:$ANDROID_HOME/emulator"
            export PATH="$PATH:$ANDROID_HOME/platform-tools"
            export PATH="$PATH:$ANDROID_HOME/cmdline-tools/latest/bin"
            export PATH="$PATH:$HOME/.pub-cache/bin"
            export GRADLE_OPTS="-Dorg.gradle.project.android.aapt2FromMavenOverride=$ANDROID_HOME/build-tools/34.0.0/aapt2"

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

            echo "Flutter environment ready!"
            echo "Commands available:"
            echo "  start-emulator [gpu_mode] - Start the Android emulator (default: swiftshader_indirect)"
            echo "  start-scrcpy - Start scrcpy to display and control the emulator"
          '';

          buildInputs = with pkgs;
            [
              flutter
              androidSdk
              gradle
              jdk17
              scrcpy
            ]
            ++ (with emulatorScripts; [
              startEmulator
            ]);
        };
      };
    };
}

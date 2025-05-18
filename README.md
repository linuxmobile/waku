# Flutter Development Environment

A simple Nix setup for Flutter development with Android testing options.

## Key Features

- Flutter and Dart SDK development environment
- Android SDK with build tools
- Two options for testing Android apps:
  - Standard Android Emulator (using `default.nix`)
  - Waydroid for native Wayland support (using `flake.nix`)

## Quick Start

### Method 1: Android Emulator (recommended for most cases)

```bash
# Build and run the emulator
nix-build default.nix
./result/bin/run-test-emulator
```

### Method 2: Flutter + Waydroid (for Wayland environments)

```bash
# Setup in NixOS configuration.nix
virtualisation.waydroid.enable = true;

# Enter development environment
nix develop

# Start Waydroid
sudo waydroid init -s GAPPS -f
sudo systemctl start waydroid-container
waydroid session start
waydroid show-full-ui
```

## Flutter Workflow

```bash
# Create new project
flutter create my_app
cd my_app

# Build your app
flutter build apk

# Install on Android Emulator
adb install build/app/outputs/flutter-apk/app-release.apk

# Or install on Waydroid
waydroid app install build/app/outputs/flutter-apk/app-release.apk
```

## Troubleshooting

### Android Emulator Issues

If you have problems with the emulator:

- Try with `JDK8` instead of `JDK17` if the AVD manager fails
- Ensure KVM is enabled: `sudo modprobe kvm`
- Check virtualization is enabled in BIOS/UEFI

### Waydroid Issues

For GPU performance problems:

```bash
echo "ro.hardware.gralloc=default
ro.hardware.egl=swiftshader" | sudo tee -a /var/lib/waydroid/waydroid_base.prop
```

# 枠 (waku)

> A frame for Flutter, defined by Nix.

**枠 (waku)** translates to "Frame" or "Framework"—the boundary that gives structure to form. This project provides a precision-crafted space that contains and protects your Flutter imagination, ensuring every tool remains exactly where it was intended.

### The Atelier

Within this frame, tools are curated for clarity and purpose:

- **Flutter**: A stable environment for crafting interfaces.
- **Android SDK**: A deliberate selection of platform versions and build tools.
- **Browser Curation**: Support for Chrome, Chromium, or custom paths, ensuring your web interfaces breathe correctly within the frame.
- **Emulator Rituals**: Seamless creation and activation of Android emulators within the shell.
- **Gradle Harmony**: Automatic handling of internal paths, removing the friction of local configuration.

### The Ritual

To begin your journey, initialize the frame:

```bash
mkdir project && cd project
nix flake init -t github:linuxmobile/flutter-flake-template
```

Enter the sanctuary that suits your intention:

```bash
# The Standard Shell
nix develop

# The Web Shell (Chromium)
nix develop .#chromium

# The Emulator Shell
nix develop .#emulator
```

Once inside, the tools are ready for your touch:

```bash
flutter doctor
flutter create .
flutter run
```

### Curation

Adjust the `USER CONFIGURATION` within `flake.nix` to align the frame with your project's specific needs. Here, you define the versions and tools that will form your boundary.

### Troubleshooting

Should the frame feel misaligned, verify your Android licenses with `flutter doctor --android-licenses` or ensure KVM is active for your emulators.

_The frame does not limit the art; it makes the art possible._

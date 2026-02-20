{
  writeShellScriptBin,
  android-sdk,
  ...
}:
writeShellScriptBin "start-emulator" ''
  export ANDROID_HOME="${android-sdk}/libexec/android-sdk"
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
''

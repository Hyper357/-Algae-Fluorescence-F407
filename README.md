# Algae-Fluorescence-F407

STM32F407-based control and acquisition work for an 8-excitation × 3-emission fluorescence instrument. This repository starts from an empty remote; the existing V2 ESP32 project remains separate.

Current stage: G0, establish board identity, a minimal build, and the existing serial link. Real board model, pin assignment and ADS1115 wiring are pending confirmation. No experimental performance or hardware compatibility should be inferred from a build or simulation.

See [board identity](docs/BOARD_ID.md), [pin map](docs/BOARD_PINMAP.md), and [G0 evidence](evidence/G0.md). Build dependencies and generated binaries are excluded from version control.

## Offline build preparation

From PowerShell on the development machine:

```powershell
powershell -ExecutionPolicy Bypass -File tools/setup_deps.ps1
powershell -ExecutionPolicy Bypass -File tools/build_g0.ps1
python tools/check_g0_binary.py build/f407-g0/f407_g0.bin
python -m unittest discover -s tests
```

The setup script fetches pinned ST STM32CubeF4, CMSIS-device and HAL revisions; it never overwrites an existing dependency checkout. The build script uses the GCC and CMake bundled with STM32CubeIDE and a locally installed Ninja. Override `-IdePlugins`, `-CubeRoot`, or `-BuildDir` if needed. This builds the **provisional** STM32F407ZG/USART1 PA9/PA10 configuration; it must not be treated as confirmation of the physical board or as a flashing instruction.

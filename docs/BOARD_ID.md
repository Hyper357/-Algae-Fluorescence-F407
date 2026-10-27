# Board identification

Status: **partially identified**. The user-provided board photograph visibly shows the ALIENTEK Explorer (正点原子探索者) and STM32F4 markings. The board revision and complete MCU marking are not yet legible enough to establish them confidently. STM32F407ZG is a provisional build target until the chip marking is confirmed.

Windows currently sees a CH340 USB-to-serial adapter at COM8. On 2026-10-27, listening at 115200 8N1 with flow control disabled produced diagnostic text, including `LCD ID:ffff`, `g_tpad_default_val:295`, `NEXT: KEY1` and `SPI_FLASH`. This is evidence of serial output, not a unique proof of the board model or UART wiring.

Outstanding: record the markings on the board and MCU, board revision, USB connector, debugger or bootloader path, and any existing firmware that must be preserved.

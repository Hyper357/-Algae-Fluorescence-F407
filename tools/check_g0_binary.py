#!/usr/bin/env python3
"""Check basic Cortex-M vector placement in the provisional G0 binary.

This is an artifact integrity check, not a board or UART runtime test.
"""
from __future__ import annotations

import argparse
import struct
from pathlib import Path

FLASH_BASE = 0x08000000
RAM_BASE = 0x20000000
RAM_END = RAM_BASE + 128 * 1024
BOOT_MARKER = b"F407_BOOT,unverified_board,g0-0.1\r\n"


def check_binary(data: bytes) -> list[str]:
    errors: list[str] = []
    if len(data) < 64:
        return ["binary too short to contain the core exception vectors"]
    stack, reset = struct.unpack_from("<II", data, 0)
    hardfault = struct.unpack_from("<I", data, 3 * 4)[0]
    systick = struct.unpack_from("<I", data, 15 * 4)[0]
    if not (RAM_BASE < stack <= RAM_END and stack % 8 == 0):
        errors.append(f"invalid initial stack pointer: 0x{stack:08x}")
    if not (reset & 1 and FLASH_BASE <= (reset & ~1) < FLASH_BASE + len(data)):
        errors.append(f"invalid reset vector: 0x{reset:08x}")
    if not (systick & 1 and FLASH_BASE <= (systick & ~1) < FLASH_BASE + len(data)):
        errors.append(f"invalid SysTick vector: 0x{systick:08x}")
    elif systick == hardfault:
        errors.append("SysTick still points to the default fault handler")
    if BOOT_MARKER not in data:
        errors.append("boot marker absent")
    return errors


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("binary", type=Path)
    args = parser.parse_args()
    data = args.binary.read_bytes()
    errors = check_binary(data)
    if errors:
        for error in errors:
            print(f"FAIL: {error}")
        return 1
    print(f"PASS: vector table, SysTick and boot marker in {len(data)} bytes (static only)")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())

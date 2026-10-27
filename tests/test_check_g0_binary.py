import struct
import sys
import unittest
from pathlib import Path

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))
from check_g0_binary import BOOT_MARKER, check_binary


class VectorValidationTests(unittest.TestCase):
    def setUp(self):
        self.binary = bytearray(128)
        struct.pack_into("<II", self.binary, 0, 0x20020000, 0x08000041)
        struct.pack_into("<I", self.binary, 3 * 4, 0x08000045)
        struct.pack_into("<I", self.binary, 15 * 4, 0x08000049)
        self.binary[64:64 + len(BOOT_MARKER)] = BOOT_MARKER

    def test_candidate_vector_table_is_accepted(self):
        self.assertEqual(check_binary(self.binary), [])

    def test_invalid_stack_and_default_systick_are_rejected(self):
        struct.pack_into("<I", self.binary, 0, 0x10000000)
        struct.pack_into("<I", self.binary, 15 * 4, 0x08000045)
        errors = check_binary(self.binary)
        self.assertTrue(any("stack" in error for error in errors))
        self.assertTrue(any("default" in error for error in errors))

    def test_missing_marker_is_rejected(self):
        self.binary[64:64 + len(BOOT_MARKER)] = b"x" * len(BOOT_MARKER)
        self.assertTrue(any("marker" in error for error in check_binary(self.binary)))


if __name__ == "__main__":
    unittest.main()

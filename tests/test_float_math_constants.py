import math
from pathlib import Path
import re
import struct
import unittest

ROOT = Path(__file__).resolve().parents[1]


def source_doubles(stem):
    source = (ROOT / "src/sdk" / (stem + ".c")).read_text()
    declarations = source.split("extern float", 1)[0]
    words = [int(value, 16) for value in re.findall(r"0x([0-9A-F]{8})", declarations)]
    return struct.unpack(">8d", struct.pack(">16I", *words))


class FloatMathConstantTests(unittest.TestCase):
    def test_coefficient_blocks_agree(self):
        sine = source_doubles("sine_float")
        cosine = source_doubles("cosine_float")
        self.assertEqual(sine, cosine)
        self.assertEqual(sine[0], 1.0)
        self.assertAlmostEqual(sine[5], 1.0 / math.pi, places=16)
        self.assertAlmostEqual(sine[6] + sine[7], math.pi, places=15)

    def test_polynomial_on_reduced_interval(self):
        coefficients = source_doubles("sine_float")[:5]
        for index in range(-100, 101):
            angle = index * math.pi / 200
            square = angle * angle
            polynomial = ((coefficients[4] * square + coefficients[3]) * square
                          + coefficients[2]) * square + coefficients[1]
            result = angle + angle * square * polynomial
            self.assertAlmostEqual(result, math.sin(angle), delta=2e-8)


if __name__ == "__main__":
    unittest.main()

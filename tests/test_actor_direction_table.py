import math
from pathlib import Path
import re
import unittest


class ActorDirectionTableTests(unittest.TestCase):
    def test_all_entries_agree_with_independent_tangent_formula(self):
        source = Path(__file__).resolve().parents[1] / 'src/game/actor_groups/direction_table.c'
        declaration = re.search(r'int D_8007C338\[65\] = \{([^}]+)\};', source.read_text())
        self.assertIsNotNone(declaration)
        values = [int(value.strip()) for value in declaration[1].split(',')]
        self.assertEqual(values, [round(math.tan(index * math.pi / 256) * 32767)
                                  for index in range(65)])


if __name__ == '__main__':
    unittest.main()

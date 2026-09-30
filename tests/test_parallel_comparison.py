from contextlib import redirect_stdout
import io
from pathlib import Path
import sys
from threading import Event
import unittest
from unittest.mock import patch

sys.path.insert(0, str(Path(__file__).resolve().parents[1] / "tools"))

from compare_runtime import compare_blocks


class ParallelComparisonTests(unittest.TestCase):
    records = (
        ("first", "src/game/first.c", 0x80001000, 0x80001010),
        ("second", "src/game/second.c", 0x80002000, 0x80002014),
    )

    def test_reverse_completion_keeps_registered_order_and_each_result(self):
        first_started, second_finished = Event(), Event()
        completion_order = []
        target, layout = b"synthetic target", object()

        def compare(name, source, vram, start, end, actual_target, **kwargs):
            self.assertIs(actual_target, target)
            self.assertIs(kwargs["layout"], layout)
            self.assertEqual(kwargs["family"], "parallel-fixture")
            if name == "first":
                first_started.set()
                self.assertTrue(second_finished.wait(5), "independent work did not overlap")
            else:
                self.assertTrue(first_started.wait(5))
            completion_order.append(name)
            if name == "second":
                second_finished.set()
            return {"source": source, "actual_size": end - start,
                    "expected_size": end - start, "different_words": [],
                    "matches": name == "first"}

        output = io.StringIO()
        with patch("compare_runtime.compare_block", side_effect=compare), redirect_stdout(output):
            blocks = compare_blocks(self.records, target, "parallel-fixture", layout, jobs=2)
        self.assertEqual(completion_order, ["second", "first"])
        self.assertEqual(list(blocks), ["first", "second"])
        self.assertTrue(blocks["first"]["matches"])
        self.assertFalse(blocks["second"]["matches"])
        self.assertLess(output.getvalue().index("first:"), output.getvalue().index("second:"))

    def test_integrity_error_from_a_worker_is_propagated(self):
        def compare(*args, **kwargs):
            raise ValueError("Build input changed during comparison")

        with patch("compare_runtime.compare_block", side_effect=compare), redirect_stdout(io.StringIO()):
            with self.assertRaisesRegex(ValueError, "Build input changed"):
                compare_blocks(self.records, b"", "error-fixture", object(), jobs=2)

    def test_duplicate_output_name_is_rejected_before_compilation(self):
        repeated = (self.records[0], ("first", *self.records[1][1:]))
        with patch("compare_runtime.compare_block") as compare:
            with self.assertRaisesRegex(ValueError, "names must be unique"):
                compare_blocks(repeated, b"", "duplicate-fixture", object(), jobs=2)
            compare.assert_not_called()


if __name__ == "__main__":
    unittest.main()

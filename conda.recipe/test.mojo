"""Smoke test: verifies the window package imports and surfaces SDL errors correctly."""

from std.os import setenv
from std.testing import TestSuite, assert_raises
from window import Window


def test_import_and_error_on_no_display() raises -> None:
    _ = setenv("SDL_VIDEODRIVER", "bogus_driver_xyz", True)
    with assert_raises(contains="SDL_Init(SDL_INIT_VIDEO) failed"):
        var w = Window("t", 1, 1)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

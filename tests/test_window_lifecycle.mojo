"""Headless lifecycle tests for `Window`. Requires `SDL_VIDEODRIVER=dummy`
(no real display) -- set by `pixi run test`.
"""

from std.testing import TestSuite, assert_true, assert_false
from window import Window


def test_open_then_close() raises -> None:
    var w = Window("t", 100, 100)
    assert_true(w.is_open())
    w.close()
    assert_false(w.is_open())


def test_sequential_create_destroy() raises -> None:
    for _ in range(3):
        var w = Window("t", 64, 64)
        assert_true(w.is_open())


def test_ticks_monotonic() raises -> None:
    var w = Window("t", 64, 64)
    var a = w.ticks()
    var b = w.ticks()
    assert_true(b >= a)


def test_events_empty_when_none_pending() raises -> None:
    var w = Window("t", 64, 64)
    var events = w.events()
    assert_true(len(events) == 0)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

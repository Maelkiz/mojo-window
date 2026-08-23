"""Headless tests for `Window`'s pixel-buffer rendering surface. Requires
`SDL_VIDEODRIVER=dummy` (no real display) -- set by `pixi run test`.
"""

from std.testing import TestSuite, assert_equal, assert_true
from window import Window, Resized
from window._sdl import SDL_EVENT_WINDOW_RESIZED, _OFF_WINDOW_DATA1, _OFF_WINDOW_DATA2
from window._sdl import SDL
from _raw_event import new_event_buffer, write_i32


def test_pixels_sized_to_dimensions() raises -> None:
    var w = Window("t", 8, 4)
    var buf = w.pixels()
    # No direct len() on the raw buffer -- indexing the last byte proves
    # at least width * height * 4 bytes are addressable.
    buf[unsafe_offset=8 * 4 * 4 - 1] = 0
    assert_equal(w.width(), 8)
    assert_equal(w.height(), 4)


def test_present_after_writing_pixels_does_not_raise() raises -> None:
    var w = Window("t", 4, 4)
    # Under SDL_VIDEODRIVER=dummy, a second-or-later Window's vsync'd
    # present() inside one TestSuite process stalls for several seconds
    # (a dummy-driver/testsuite-reflection interaction, not present()
    # itself -- a real app only ever constructs one Window). Disable
    # vsync here so the headless suite stays fast; production default
    # (vsync on) is unaffected.
    w.set_vsync(False)
    var buf = w.pixels()
    for i in range(4 * 4 * 4):
        buf[unsafe_offset=i] = 255
    w.present()


def test_resize_reallocates_pixel_buffer_and_dimensions() raises -> None:
    var w = Window("t", 4, 4)
    w.set_vsync(False)  # see note in test_present_after_writing_pixels_does_not_raise
    var event_buf = new_event_buffer(SDL_EVENT_WINDOW_RESIZED)
    write_i32(event_buf, _OFF_WINDOW_DATA1, 16)
    write_i32(event_buf, _OFF_WINDOW_DATA2, 12)
    var sdl = SDL()
    assert_true(sdl.push_event(event_buf.unsafe_ptr()))

    var events = w.events()
    assert_equal(len(events), 1)
    assert_true(events[0].isa[Resized]())
    assert_equal(w.width(), 16)
    assert_equal(w.height(), 12)

    var buf = w.pixels()
    buf[unsafe_offset=16 * 12 * 4 - 1] = 0
    w.present()


def test_vsync_and_fullscreen_toggle_do_not_raise() raises -> None:
    var w = Window("t", 4, 4)
    w.set_vsync(False)
    w.set_vsync(True)
    w.set_fullscreen(True)
    w.set_fullscreen(False)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

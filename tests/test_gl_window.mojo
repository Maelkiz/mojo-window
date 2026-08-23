"""Headless tests for `GLWindow`. Requires `SDL_VIDEODRIVER=dummy` (no real
display) -- set by `pixi run test`.

The dummy driver has no GPU backend, so `SDL_CreateWindow` itself refuses
the `SDL_WINDOW_OPENGL` flag under it (verified empirically while building
this feature, not assumed) -- `SDL_GL_CreateContext` is never even reached.
`GLWindow` construction therefore always fails cleanly here; there is no
headless success path to exercise construction, `is_open()`/`close()`,
`events()`, `get_proc_address()`, or `swap_buffers()` against. Those need a
real GL-capable display and are exercised manually via `pixi run
example_gl`. The shared event-translation logic `GLWindow.events()` relies
on is covered headlessly in `test_translate_event.mojo` instead, since
that part doesn't need a live window at all.
"""

from std.testing import TestSuite, assert_raises
from window import GLWindow


def test_construction_fails_cleanly_under_dummy_driver() raises -> None:
    with assert_raises(contains="SDL_CreateWindow failed"):
        var w = GLWindow("t", 64, 64)


def test_sequential_failed_construction_does_not_crash() raises -> None:
    for _ in range(3):
        with assert_raises(contains="SDL_CreateWindow failed"):
            var w = GLWindow("t", 64, 64)


def main() raises:
    TestSuite.discover_tests[__functions_in_module()]().run()

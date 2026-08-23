"""Public `Event` type — window/input events translated from raw SDL3 events."""

from std.utils import Variant


@fieldwise_init
struct Quit(ImplicitlyCopyable, Movable):
    pass


@fieldwise_init
struct Resized(ImplicitlyCopyable, Movable):
    var width: Int
    var height: Int


@fieldwise_init
struct KeyDown(ImplicitlyCopyable, Movable):
    var keycode: Int


@fieldwise_init
struct KeyUp(ImplicitlyCopyable, Movable):
    var keycode: Int


@fieldwise_init
struct MouseMoved(ImplicitlyCopyable, Movable):
    var x: Int
    var y: Int


@fieldwise_init
struct MouseButtonDown(ImplicitlyCopyable, Movable):
    var button: Int
    var x: Int
    var y: Int


@fieldwise_init
struct MouseButtonUp(ImplicitlyCopyable, Movable):
    var button: Int
    var x: Int
    var y: Int


comptime Event = Variant[
    Quit, Resized, KeyDown, KeyUp, MouseMoved, MouseButtonDown, MouseButtonUp
]
"""A window/input event. Check the concrete kind with `.isa[T]()`, then
read fields with `[T]`, e.g. `if e.isa[KeyDown](): print(e[KeyDown].keycode)`.
"""

"""Minimal live-OpenGL-context example. Demonstrates the intended split of
responsibility: `mojo-window` hands back a current GL context via
`GLWindow`, and this example binds the handful of raw GL calls it needs
itself via `get_proc_address` -- mojo-window does not know or bind any GL
functions. Just clears the screen to a changing solid color each frame (not
an actual triangle -- proving the context is live doesn't need shaders/VBOs).
"""

from std.math import sin

from window import GLWindow, Quit

comptime GL_COLOR_BUFFER_BIT: UInt32 = 0x00004000

comptime GLClearColorFn = def (Float32, Float32, Float32, Float32) thin abi(
    "C"
) -> None
comptime GLClearFn = def (UInt32) thin abi("C") -> None


def bind[
    FnT: TrivialRegisterPassable
](window: GLWindow, name: String) raises -> FnT:
    var addr = window.get_proc_address(name)
    if addr == 0:
        raise Error("GL function not available: " + name)
    var opaque = Pointer[NoneType, MutUntrackedOrigin](
        unsafe_from_address=addr
    )
    return Pointer(to=opaque).unsafe_bitcast[FnT]()[]


def main() raises:
    var window = GLWindow("GL Triangle", 800, 600)
    window.set_swap_interval(1)

    var gl_clear_color = bind[GLClearColorFn](window, "glClearColor")
    var gl_clear = bind[GLClearFn](window, "glClear")

    while window.is_open():
        for event in window.events():
            if event.isa[Quit]():
                window.close()

        var t = Float32(window.ticks()) / 1000.0
        var r = 0.5 + 0.5 * sin(t)
        var g = 0.5 + 0.5 * sin(t + 2.0)
        var b = 0.5 + 0.5 * sin(t + 4.0)
        gl_clear_color(r, g, b, 1.0)
        gl_clear(GL_COLOR_BUFFER_BIT)

        window.swap_buffers()

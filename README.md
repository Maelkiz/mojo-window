# Window

## Vision

Window aims to be a simple and ease to use windowing library for the Mojo programming language.

## Initial scope

* Set up Mojo ↔ SDL3 interoperability, including building and linking.
* Create and destroy native windows.
* Configure window title, width, and height.
* Provide a simple event loop.
* Support:
  * window close events
  * window resize events
  * keyboard input
  * mouse movement
  * mouse button input
  * mouse wheel input
* Provide basic timing functionality if straightforward.
* Design a clean Mojo-facing API that hides SDL3 implementation details as much as possible.
* Keep SDL3 as an internal implementation dependency rather than exposing SDL types directly.

## Usage

```mojo
from window import Window, Quit, KeyDown, MouseMoved

def main() raises:
    var window = Window("Hello Mojo", 800, 600)

    while window.is_open():
        for event in window.events():
            if event.isa[Quit]():
                window.close()
            elif event.isa[KeyDown]():
                print("key_down:", event[KeyDown].keycode)
            elif event.isa[MouseMoved]():
                var e = event[MouseMoved]
                print("mouse_moved:", e.x, e.y)
```

`Event` is a `Variant` of these payload types: `Quit`, `Resized`,
`KeyDown`, `KeyUp`, `MouseMoved`, `MouseButtonDown`, `MouseButtonUp`,
`MouseWheel`. Check which kind an event is with `.isa[T]()`, then read
its fields with `[T]`. See `examples/basic_window.mojo` for the full
list handled.

### GPU rendering with GLWindow

`GLWindow` gives you a native window with a live, current OpenGL (Core
profile) context instead of the CPU pixel buffer. `mojo-window` does
not bind any GL functions itself — load what you need with
`get_proc_address()` and call through the raw pointer:

```mojo
from window import GLWindow, Quit

comptime GLClearColorFn = def (Float32, Float32, Float32, Float32) thin abi(
    "C"
) -> None

def main() raises:
    var window = GLWindow("Hello GL", 800, 600)
    window.set_swap_interval(1)

    var addr = window.get_proc_address("glClearColor")
    var opaque = Pointer[NoneType, MutUntrackedOrigin](unsafe_from_address=addr)
    var gl_clear_color = Pointer(to=opaque).unsafe_bitcast[GLClearColorFn]()[]

    while window.is_open():
        for event in window.events():
            if event.isa[Quit]():
                window.close()
        gl_clear_color(0.1, 0.2, 0.3, 1.0)
        window.swap_buffers()
```

See `examples/gl_triangle.mojo` for a fuller version (animated clear
color, error-checked binding helper). Run it with `pixi run example_gl`.

## Dependencies

SDL3 is obtained via [pixi](https://pixi.sh)/conda-forge (the `sdl3`
package), not a system package — `pixi install` pulls it automatically,
no manual SDL install needed. Run the example with `pixi run example`.

**Consumers of this library** (e.g. a project importing `window` via
`-I`) need `sdl3` in their own `pixi.toml` too — pixi/conda dependencies
aren't transitive across projects, this repo's `pixi.toml` only covers
developing `window` itself. Add `libdecor` as well if you want window
decorations on Wayland (see "Known limitations" below).

## Planned

* **Vulkan context exposure** — deliberately deferred. `GLWindow`
  covers the GPU-accelerated case via OpenGL; a native Vulkan/Metal
  surface is a separate, larger addition — not built until a consumer
  actually needs it.

## Known limitations

* **Wayland — no window decorations:** on a native Wayland compositor
  (e.g. GNOME's default session), windows render and receive input
  correctly, but appear with no title bar / borders. This is SDL3
  falling back to an undecorated window because the `sdl3` conda-forge
  package doesn't pull in `libdecor` — GNOME/Mutter doesn't support the
  compositor-side `xdg-decoration` protocol, so SDL needs `libdecor` to
  draw client-side decorations itself. Purely cosmetic; not a bug in
  this library. Installing `libdecor` alongside `sdl3` should fix it, if
  ever needed.



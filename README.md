# Mojo Window 🔥

Mojo Window is a native windowing and input library for the [Mojo programming
language](https://www.modular.com/mojo). Mojo's standard library has no
windowing API of its own; this project fills that gap so that graphics
libraries have a native window, an event loop, and a rendering surface to
build on, without each one reimplementing SDL bindings from scratch.

## What it does

* Creates and destroys native windows, with configurable title, size, and
  resizability.
* Runs a per-frame event loop covering window close/resize, keyboard,
  mouse movement, mouse buttons, and the mouse wheel.
* Offers two rendering surfaces, chosen per window:
  * a CPU-side RGBA8 pixel buffer, for software rendering with no GPU
    dependency; or
  * a live OpenGL (Core profile) context, for GPU-accelerated rendering.
* Provides basic timing (`ticks()`) for frame-rate-independent logic.

## How it works

SDL3 is the only implementation dependency, loaded dynamically through
Mojo's FFI and wrapped entirely inside one internal module
(`window._sdl`). Nothing SDL-specific crosses into the public API: window
and context handles are opaque, and every SDL event is translated into a
typed `Event` — a `Variant` over `Quit`, `Resized`, `KeyDown`, `KeyUp`,
`MouseMoved`, `MouseButtonDown`, `MouseButtonUp`, and `MouseWheel` — before
it ever reaches consuming code.

`Window` and `GLWindow` share this same window-and-event-loop foundation
and differ only in rendering surface:

* **`Window`** owns an SDL renderer and texture internally and exposes
  them as a plain `pixels()` buffer plus `present()` — write RGBA bytes,
  call `present()`, done. No OpenGL, no GPU driver required.
* **`GLWindow`** creates the native window with an OpenGL context already
  current, and gets out of the way. This library does not bind any GL
  functions itself; `get_proc_address()` hands back raw function pointers
  for the consumer to bind and call as needed. Binding a full GL API is a
  much larger, open-ended task that belongs to whichever consumer actually
  needs it, not to this thin windowing layer.

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

See `examples/basic_window.mojo` for the full set of events handled and a
working pixel-buffer render loop.

### GPU rendering with GLWindow

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
no manual SDL install needed. Run the examples with `pixi run example`
and `pixi run example_gl`.

**Consumers of this library** (e.g. a project importing `window` via
`-I`) need `sdl3` in their own `pixi.toml` too — pixi/conda dependencies
aren't transitive across projects, this repo's `pixi.toml` only covers
developing `window` itself. Add `libdecor` as well if you want window
decorations on Wayland (see "Known limitations" below).

## Planned

* **Vulkan context exposure** — deliberately deferred. `GLWindow` already
  covers the GPU-accelerated case via OpenGL; a native Vulkan/Metal
  surface is a separate, larger addition, not built until a consumer
  actually needs it.

## Known limitations

* **Threading — single-threaded use only:** create and drive each `Window`
  or `GLWindow` from the one thread that constructed it (SDL itself
  requires window creation and event polling to happen on the thread that
  called `SDL_Init`). This library does no cross-thread synchronization of
  its own.
* **Wayland — no window decorations:** on a native Wayland compositor
  (e.g. GNOME's default session), windows render and receive input
  correctly, but appear with no title bar / borders. This is SDL3
  falling back to an undecorated window because the `sdl3` conda-forge
  package doesn't pull in `libdecor` — GNOME/Mutter doesn't support the
  compositor-side `xdg-decoration` protocol, so SDL needs `libdecor` to
  draw client-side decorations itself. Purely cosmetic; not a bug in
  this library. Installing `libdecor` alongside `sdl3` should fix it, if
  ever needed.

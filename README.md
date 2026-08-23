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

## Dependencies

SDL3 is obtained via [pixi](https://pixi.sh)/conda-forge (the `sdl3`
package), not a system package — `pixi install` pulls it automatically,
no manual SDL install needed. Run the example with `pixi run example`.

## Known limitations

* **Wayland:** since this library does no rendering (out of scope for
  this MVP — see "Initial scope" above), a native Wayland compositor
  (e.g. GNOME's default session) may never map the window as
  interactive — it can appear in the window switcher but show no
  decorations and receive no input. Workaround: run under XWayland,
  e.g. `SDL_VIDEODRIVER=x11 <your app>`.



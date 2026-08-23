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
* Provide basic timing functionality if straightforward.
* Design a clean Mojo-facing API that hides SDL3 implementation details as much as possible.
* Keep SDL3 as an internal implementation dependency rather than exposing SDL types directly.

The target API is something like this (but not set in stone yet):

```mojo
from mojo_window import Window, Event

fn main() raises:
    var window = Window("Hello Mojo", 800, 600)

    while window.is_open():
        for event in window.events():
            match event:
                case Event.quit:
                    window.close()
                case Event.key_down(key):
                    ...
                case Event.mouse_move(x, y):
                    ...
```



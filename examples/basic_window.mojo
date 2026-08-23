from window import (
    Window,
    Quit,
    Resized,
    KeyDown,
    KeyUp,
    MouseMoved,
    MouseButtonDown,
    MouseButtonUp,
    MouseWheel,
)


def main() raises:
    var window = Window("Hello Mojo", 800, 600)

    while window.is_open():
        for event in window.events():
            if event.isa[Quit]():
                window.close()
            elif event.isa[Resized]():
                var e = event[Resized]
                print("resized:", e.width, e.height)
            elif event.isa[KeyDown]():
                print("key_down:", event[KeyDown].keycode)
            elif event.isa[KeyUp]():
                print("key_up:", event[KeyUp].keycode)
            elif event.isa[MouseMoved]():
                var e = event[MouseMoved]
                print("mouse_moved:", e.x, e.y)
            elif event.isa[MouseButtonDown]():
                var e = event[MouseButtonDown]
                print("mouse_button_down:", e.button, e.x, e.y)
            elif event.isa[MouseButtonUp]():
                var e = event[MouseButtonUp]
                print("mouse_button_up:", e.button, e.x, e.y)
            elif event.isa[MouseWheel]():
                var e = event[MouseWheel]
                print("mouse_wheel:", e.x, e.y)

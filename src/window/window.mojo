"""Public `Window` type — the Mojo-facing wrapper over an SDL3 window."""

from ._sdl import (
    SDL,
    SDL_EVENT_SIZE,
    SDL_EVENT_QUIT,
    SDL_EVENT_WINDOW_RESIZED,
    SDL_EVENT_KEY_DOWN,
    SDL_EVENT_KEY_UP,
    SDL_EVENT_MOUSE_MOTION,
    SDL_EVENT_MOUSE_BUTTON_DOWN,
    SDL_EVENT_MOUSE_BUTTON_UP,
    event_type,
    window_data1,
    window_data2,
    key_keycode,
    mouse_x,
    mouse_y,
    button_index,
    button_x,
    button_y,
)
from .event import (
    Event,
    Quit,
    Resized,
    KeyDown,
    KeyUp,
    MouseMoved,
    MouseButtonDown,
    MouseButtonUp,
)


struct Window:
    var _sdl: SDL
    var _handle: Int
    var _open: Bool

    def __init__(out self, title: String, width: Int, height: Int) raises:
        self._sdl = SDL()
        self._sdl.init_video()
        try:
            self._handle = self._sdl.create_window(
                title, Int32(width), Int32(height), True
            )
        except e:
            self._sdl.quit_video()
            raise e
        self._open = True

    def __deinit__(deinit self):
        try:
            self._sdl.destroy_window(self._handle)
            self._sdl.quit_video()
        except:
            pass

    def is_open(self) -> Bool:
        return self._open

    def close(mut self):
        self._open = False

    def events(mut self) raises -> List[Event]:
        """Drains all pending SDL events for this frame as translated `Event`s.

        A quit event also flips the window to closed.
        """
        var events: List[Event] = []
        var buf = InlineArray[UInt8, SDL_EVENT_SIZE](fill=0)
        var ptr = buf.unsafe_ptr()
        while self._sdl.poll_event(ptr):
            var kind = event_type(ptr)
            var e: Event
            if kind == SDL_EVENT_QUIT:
                self._open = False
                e = Quit()
            elif kind == SDL_EVENT_WINDOW_RESIZED:
                e = Resized(Int(window_data1(ptr)), Int(window_data2(ptr)))
            elif kind == SDL_EVENT_KEY_DOWN:
                e = KeyDown(Int(key_keycode(ptr)))
            elif kind == SDL_EVENT_KEY_UP:
                e = KeyUp(Int(key_keycode(ptr)))
            elif kind == SDL_EVENT_MOUSE_MOTION:
                e = MouseMoved(Int(mouse_x(ptr)), Int(mouse_y(ptr)))
            elif kind == SDL_EVENT_MOUSE_BUTTON_DOWN:
                e = MouseButtonDown(
                    Int(button_index(ptr)), Int(button_x(ptr)), Int(button_y(ptr))
                )
            elif kind == SDL_EVENT_MOUSE_BUTTON_UP:
                e = MouseButtonUp(
                    Int(button_index(ptr)), Int(button_x(ptr)), Int(button_y(ptr))
                )
            else:
                continue
            events.append(e)
        return events^

"""Public `Window` type — the Mojo-facing wrapper over an SDL3 window."""

from ._sdl import SDL


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

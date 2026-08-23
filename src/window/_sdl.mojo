"""Raw SDL3 bindings via `std.ffi._DLHandle`.

Internal only — nothing here is re-exported from the package `__init__`.
`_DLHandle` is a private stdlib API (no public `DLHandle` exists in this
Mojo release); isolating all use of it in this one file means a future
stdlib rename only touches this module.

`_DLHandle.call` requires its `return_type` to be `RegisterPassable`, which
rules out returning pointer types directly. SDL handles (`SDL_Window *`)
and pointer results we don't need to dereference are therefore treated as
opaque `Int` addresses. Where we do need to read through a pointer (error
strings), `Pointer[T, MutUntrackedOrigin]` is used — `MutUntrackedOrigin`
is the concrete origin the stdlib itself uses for FFI-returned pointers.
"""

from std.ffi import _DLHandle

comptime SDL_INIT_VIDEO: UInt32 = 0x00000020
comptime SDL_WINDOW_RESIZABLE: UInt64 = 0x0000000000000020

comptime SDL_EVENT_QUIT: UInt32 = 0x100
comptime SDL_EVENT_WINDOW_RESIZED: UInt32 = 0x206
comptime SDL_EVENT_KEY_DOWN: UInt32 = 0x300
comptime SDL_EVENT_KEY_UP: UInt32 = 0x301
comptime SDL_EVENT_MOUSE_MOTION: UInt32 = 0x400
comptime SDL_EVENT_MOUSE_BUTTON_DOWN: UInt32 = 0x401
comptime SDL_EVENT_MOUSE_BUTTON_UP: UInt32 = 0x402
comptime SDL_EVENT_MOUSE_WHEEL: UInt32 = 0x403

comptime SDL_EVENT_SIZE = 128
"""Size in bytes of SDL_Event — the union is padded to this size for ABI stability."""

# Byte offsets into an SDL_Event buffer, shared by every event struct
# variant (SDL_CommonEvent header: type@0, reserved@4, timestamp@8).
comptime _OFF_WINDOW_ID = 16
comptime _OFF_WINDOW_DATA1 = 20
comptime _OFF_WINDOW_DATA2 = 24

comptime _OFF_KEY_SCANCODE = 24
comptime _OFF_KEY_KEYCODE = 28
comptime _OFF_KEY_MOD = 32
comptime _OFF_KEY_REPEAT = 37

comptime _OFF_MOTION_X = 28
comptime _OFF_MOTION_Y = 32

comptime _OFF_BUTTON_INDEX = 24
comptime _OFF_BUTTON_X = 28
comptime _OFF_BUTTON_Y = 32

comptime _OFF_WHEEL_X = 24
comptime _OFF_WHEEL_Y = 28


struct SDL:
    """Thin wrapper over the dynamically-loaded SDL3 library."""

    var lib: _DLHandle

    def __init__(out self) raises:
        self.lib = _DLHandle("libSDL3.so")

    def get_error(self) raises -> String:
        var ptr = self.lib.call[
            "SDL_GetError", Pointer[UInt8, MutUntrackedOrigin]
        ]()
        return String(unsafe_from_utf8_ptr=ptr)

    def init_video(self) raises:
        if not self.lib.call["SDL_Init", Bool](SDL_INIT_VIDEO):
            raise Error("SDL_Init(SDL_INIT_VIDEO) failed: " + self.get_error())

    def quit(self) raises:
        self.lib.call["SDL_Quit"]()

    def quit_video(self) raises:
        """Decrement the video subsystem's SDL-internal ref count.

        SDL_Init/SDL_InitSubSystem ref-count each subsystem internally; the
        subsystem only actually shuts down once every matching
        SDL_QuitSubSystem call has landed. `Window` relies on this instead
        of tracking its own live-window count (which this Mojo release has
        no global mutable state to hold outside a function body).
        """
        self.lib.call["SDL_QuitSubSystem"](SDL_INIT_VIDEO)

    def create_window(
        self, title: String, width: Int32, height: Int32, resizable: Bool
    ) raises -> Int:
        var flags: UInt64 = SDL_WINDOW_RESIZABLE if resizable else 0
        var window = self.lib.call["SDL_CreateWindow", Int](
            title.unsafe_ptr(), width, height, flags
        )
        if window == 0:
            raise Error("SDL_CreateWindow failed: " + self.get_error())
        return window

    def destroy_window(self, window: Int) raises:
        self.lib.call["SDL_DestroyWindow"](window)

    def poll_event(self, buf: Pointer[UInt8, _]) raises -> Bool:
        return self.lib.call["SDL_PollEvent", Bool](buf)

    def get_ticks(self) raises -> UInt64:
        return self.lib.call["SDL_GetTicks", UInt64]()


# --- SDL_Event field readers -------------------------------------------
#
# Each takes a pointer to an `SDL_EVENT_SIZE`-byte buffer previously filled
# by `SDL.poll_event` and reads the field at its fixed byte offset. Which
# reader is valid depends on `event_type(buf)` — same layout SDL itself
# uses for the `SDL_Event` union.


def event_type(buf: Pointer[UInt8, _]) -> UInt32:
    return buf.unsafe_bitcast[UInt32]()[]


def window_id(buf: Pointer[UInt8, _]) -> UInt32:
    return buf.unsafe_offset(_OFF_WINDOW_ID).unsafe_bitcast[UInt32]()[]


def window_data1(buf: Pointer[UInt8, _]) -> Int32:
    return buf.unsafe_offset(_OFF_WINDOW_DATA1).unsafe_bitcast[Int32]()[]


def window_data2(buf: Pointer[UInt8, _]) -> Int32:
    return buf.unsafe_offset(_OFF_WINDOW_DATA2).unsafe_bitcast[Int32]()[]


def key_scancode(buf: Pointer[UInt8, _]) -> UInt32:
    return buf.unsafe_offset(_OFF_KEY_SCANCODE).unsafe_bitcast[UInt32]()[]


def key_keycode(buf: Pointer[UInt8, _]) -> UInt32:
    return buf.unsafe_offset(_OFF_KEY_KEYCODE).unsafe_bitcast[UInt32]()[]


def key_mod(buf: Pointer[UInt8, _]) -> UInt16:
    return buf.unsafe_offset(_OFF_KEY_MOD).unsafe_bitcast[UInt16]()[]


def key_repeat(buf: Pointer[UInt8, _]) -> Bool:
    return buf.unsafe_offset(_OFF_KEY_REPEAT).unsafe_bitcast[UInt8]()[] != 0


def mouse_x(buf: Pointer[UInt8, _]) -> Float32:
    return buf.unsafe_offset(_OFF_MOTION_X).unsafe_bitcast[Float32]()[]


def mouse_y(buf: Pointer[UInt8, _]) -> Float32:
    return buf.unsafe_offset(_OFF_MOTION_Y).unsafe_bitcast[Float32]()[]


def button_index(buf: Pointer[UInt8, _]) -> UInt8:
    return buf.unsafe_offset(_OFF_BUTTON_INDEX).unsafe_bitcast[UInt8]()[]


def button_x(buf: Pointer[UInt8, _]) -> Float32:
    return buf.unsafe_offset(_OFF_BUTTON_X).unsafe_bitcast[Float32]()[]


def button_y(buf: Pointer[UInt8, _]) -> Float32:
    return buf.unsafe_offset(_OFF_BUTTON_Y).unsafe_bitcast[Float32]()[]


def wheel_x(buf: Pointer[UInt8, _]) -> Float32:
    return buf.unsafe_offset(_OFF_WHEEL_X).unsafe_bitcast[Float32]()[]


def wheel_y(buf: Pointer[UInt8, _]) -> Float32:
    return buf.unsafe_offset(_OFF_WHEEL_Y).unsafe_bitcast[Float32]()[]

import gi
gi.require_version("GLib", "2.0")
assert("__init__" in gi.__file__)
from gi.repository import GLib
assert(31 == GLib.Date.get_days_in_month(GLib.DateMonth.JANUARY, 2000))

from gi.repository import Gio, GObject


class Probe(GObject.Object):
    value = GObject.Property(type=int, default=0)
    __gsignals__ = {"result": (GObject.SignalFlags.RUN_LAST, None, (int,))}


probe = Probe()
notifications = []
results = []
probe.connect("notify::value", lambda obj, pspec: notifications.append(obj.value))
probe.connect("result", lambda obj, value: results.append(value))
probe.value = 42
probe.emit("result", probe.value)
assert notifications == [42]
assert results == [42]
assert GLib.Variant("a{si}", {"answer": 42}).unpack() == {"answer": 42}

stream = Gio.MemoryInputStream.new_from_bytes(GLib.Bytes.new(b"native"))
assert stream.read_bytes(6, None).get_data() == b"native"
stream.close(None)

callbacks = []


def on_idle():
    callbacks.append(42)
    return GLib.SOURCE_REMOVE


GLib.idle_add(on_idle)
context = GLib.MainContext.default()
for _ in range(100):
    if callbacks:
        break
    context.iteration(False)
assert callbacks == [42]
gi.require_foreign("cairo")
print("PASS: GObject properties/signals, GLib variants/callbacks, GIO bytes, Cairo bridge")

import sys

include("test_actorsworld.jl")
include("test_kara_01.jl")
include("test_xml.jl")
using Gtk
Gtk.libgtk_version >= v"3.20" && include("test_kara_gui.jl")

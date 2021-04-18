#!/usr/bin/python3
import gi
gi.require_version('Gtk', '3.0')
from gi.repository import Gtk
c=Gtk.ColorSelectionDialog()
c.connect("destroy",Gtk.main_quit)
c.show_all()
Gtk.main()

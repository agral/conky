-- Main lua module for master.conky
package.path = string.format( "%s;%s;%s",
    package.path,
    "/home/simba/Source/Conky/Utils/?.lua",
    "/home/simba/Source/Conky/Modules/?.lua"
)
print(package.path)

require("cairo")
local Cairo = require("CairoHelper")
local Widgets = require("Widgets")
Widgets:Init({cairo = Cairo})
local Clock = require("Clock")
local Mpd = require("Mpd")
local Info = require("Info")
local ReferenceRenderer = require("ReferenceRenderer")

local extraMarginL = 32 -- Reserved for tint2-bar
local padding = 25 -- from every side
local screen = {w = 1366, h = 768}

function conky_main()
  -- Exits early there is no window to draw on:
  if not conky_window or conky_window.width == 0 or conky_window.height == 0 then
    print("[master.lua] Error: no conky_window present.")
    return
  end

  -- If not done so already, prepares a cairo context and exports it to a global variable cr:
  if cr == nil then
    print("[master.lua] Initializing conky-cairo...")
    csurface = cairo_xlib_surface_create(
        conky_window.display,
        conky_window.drawable,
        conky_window.visual,
        conky_window.width,
        conky_window.height
    )
    cr = cairo_create(csurface)
  end

  Mpd:Draw({cairo = Cairo, x = 500, y = 20, size = 128})
  Clock:Draw({cairo = Cairo, x = 170, y = 150})
  Info:Draw({cairo = Cairo, widgets = Widgets, x = 25, y = 310})
  ReferenceRenderer:Draw({
    cairo = Cairo,
    pos = {x = screen.w - extraMarginL - padding, y = screen.h - padding},
    --reference = ReferenceRenderer.SolarizedReference,
    reference = ReferenceRenderer.KorKeyboardReference,
  })
end

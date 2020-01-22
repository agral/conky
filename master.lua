-- Main lua module for master.conky
package.path = string.format( "%s;%s;%s",
    package.path,
    "/home/simba/Source/Conky/Utils/?.lua",
    "/home/simba/Source/Conky/Modules/?.lua"
)
print(package.path)

require("cairo")
local Cairo = require("CairoHelper")
local Mpd = require("Mpd")

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
end

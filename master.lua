-- Main lua module for master.conky
package.path = package.path .. ";/home/simba/Source/Conky/Utils/?.lua"
print(package.path)

require("cairo")
local Cairo = require("CairoHelper")

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

  Cairo:DrawDebugLine()
end

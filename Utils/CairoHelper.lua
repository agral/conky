require("cairo")

local CairoHelper = {
}

setmetatable(CairoHelper, {
  __index = CairoHelper,
} )

function CairoHelper:DrawDebugLine()
  cairo_set_line_width(cr, 10)
  cairo_set_source_rgba(cr, 1.0, 0.0, 1.0, 0.5)
  cairo_move_to(cr, 50, 50)
  cairo_line_to(cr, 100, 100)
  cairo_stroke(cr)
end

return CairoHelper

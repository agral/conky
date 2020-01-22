require("cairo")
local Color = require("Color")

local CairoHelper = {
}

setmetatable(CairoHelper, {
  __index = CairoHelper,
} )

function CairoHelper:ImageSurfaceCreateFromPng(path)
  return cairo_image_surface_create_from_png(path)
end

function CairoHelper:ImageSurfaceGetHeight(image)
  return cairo_image_surface_get_height(image)
end

function CairoHelper:ImageSurfaceGetWidth(image)
  return cairo_image_surface_get_width(image)
end

function CairoHelper:LineTo(x, y)
  cairo_line_to(cr, x, y)
end

function CairoHelper:MoveTo(x, y)
  cairo_move_to(cr, x, y)
end

function CairoHelper:Paint()
  cairo_paint(cr)
end

function CairoHelper:Restore()
  cairo_restore(cr)
end

function CairoHelper:Save()
  cairo_save(cr)
end

function CairoHelper:Scale(sx, sy)
  cairo_scale(cr, sx, sy)
end

function CairoHelper:SetColor(color)
  assert(type(color) == "table", "[CairoHelper] SetColor(): Malformed color")
  self:SetSourceRgba(color.r, color.g, color.b, color.a)
end

function CairoHelper:SetLineWidth(newLineWidth)
  cairo_set_line_width(cr, newLineWidth)
end

function CairoHelper:SetSourceRgba(red, green, blue, alpha)
  cairo_set_source_rgba(cr, red, green, blue, alpha)
end

function CairoHelper:SetSourceSurface(surface, x, y)
  cairo_set_source_surface(cr, surface, x, y)
end

function CairoHelper:Stroke()
  cairo_stroke(cr)
end

function CairoHelper:SurfaceDestroy(surface)
  cairo_surface_destroy(surface)
end

return CairoHelper

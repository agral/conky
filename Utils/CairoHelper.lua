require("cairo")

local CairoHelper = {
  Font = {
    Slant = {
      Normal = CAIRO_FONT_SLANT_NORMAL,
      Italic = CAIRO_FONT_SLANT_ITALIC,
      Oblique = CAIRO_FONT_SLANT_OBLIQUE,
    },
    Weight = {
      Normal = CAIRO_FONT_WEIGHT_NORMAL,
      Bold = CAIRO_FONT_WEIGHT_BOLD,
    },
  },
  LineCap = {
    Round = CAIRO_LINE_CAP_ROUND,
    Butt = CAIRO_LINE_CAP_BUTT,
  },
}

setmetatable(CairoHelper, {
  __index = CairoHelper,
} )

function CairoHelper:Fill()
  cairo_fill(cr)
end

function CairoHelper:GetTextSize(text)
  local extents = cairo_text_extents_t:create()
  tolua.takeownership(extents)
  cairo_text_extents(cr, text, extents)
  return extents.width, extents.height
end

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

function CairoHelper:SelectFontFace(name, slant, weight)
  slant = slant or self.Font.Slant.Normal
  weight = weight or self.Font.Weight.Normal
  cairo_select_font_face(cr, name, slant, weight)
end

function CairoHelper:SetFontSize(newFontSize)
  cairo_set_font_size(cr, newFontSize)
end

function CairoHelper:SetLineCap(newLineCap)
  cairo_set_line_cap(cr, newLineCap)
end

function CairoHelper:SetLineWidth(newLineWidth)
  cairo_set_line_width(cr, newLineWidth)
end

function CairoHelper:ShowText(text)
  cairo_show_text(cr, text)
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

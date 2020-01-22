require("cairo")

local CairoHelper = {
}

setmetatable(CairoHelper, {
  __index = CairoHelper,
} )


function CairoHelper:LineTo(x, y)
  cairo_line_to(cr, x, y)
end

function CairoHelper:MoveTo(x, y)
  cairo_move_to(cr, x, y)
end

function CairoHelper:SetLineWidth(newLineWidth)
  cairo_set_line_width(cr, newLineWidth)
end

function CairoHelper:SetSourceRgba(red, green, blue, alpha)
  cairo_set_source_rgba(cr, red, green, blue, alpha)
end

function CairoHelper:Stroke()
  cairo_stroke(cr)
end

function CairoHelper:DrawDebugLine()
  self:SetLineWidth(10)
  self:SetSourceRgba(1.0, 0.0, 1.0, 0.5)
  self:MoveTo(50, 50)
  self:LineTo(100, 100)
  self:Stroke()
end

return CairoHelper

local Solarized = require("Solarized")

local Widgets = {
  cairo = nil,
}

setmetatable(Widgets, {
  __index = Widgets,
})

function Widgets:Init(params)
  assert(params.cairo)
  self.cairo = params.cairo
end

function Widgets:GetIndicatorColor(value, normal_color, warning_color, alarm_color)
  if value < 0.3 then
    return normal_color or Solarized.GREEN
  elseif value < 0.7 then
    return warning_color or Solarized.YELLOW
  else
    return alarm_color or Solarized.RED
  end
end

function Widgets:DrawArcIndicator(params)
  assert(params and params.radius and params.width)
  assert(params.pos and params.pos.x and params.pos.y)
  assert(params.value and params.value.normalized)

  self.cairo:SetColor(Solarized.BASE00:WithAlpha(0.2))
  self.cairo:SetLineWidth(params.width)
  local min_angle, max_angle = math.pi * 0.5, math.pi * 1.75
  local range_angle = max_angle - min_angle

  -- Draws the widget's shadow and indicator:
  self.cairo:Arc(params.pos.x, params.pos.y, params.radius, min_angle, max_angle)
  self.cairo:Stroke()
  self.cairo:SetColor(params.color or self:GetIndicatorColor(params.value.normalized))
  self.cairo:Arc(
      params.pos.x,
      params.pos.y,
      params.radius,
      min_angle,
      min_angle + range_angle * params.value.normalized
  )
  self.cairo:Stroke()

  -- Draws the indicator's value:
  if params.value.text then
    local innerRadius = params.radius - 0.5 * params.width
    local innerDim = math.floor(0.85 * (innerRadius / math.sqrt(2.0)))
    local textSize = 2.2 * innerDim
    self.cairo:SelectFontFace("Helvetica")
    self.cairo:SetFontSize(textSize)
    local textW = self.cairo:GetTextSize(params.value.text)
    self.cairo:MoveTo(
        params.pos.x - math.min(0.52 * textSize, 0.5 * textW),
        params.pos.y + 0.36 * textSize
    )
    self.cairo:ShowText(params.value.text)
    self.cairo:Stroke()
  end

  -- Draws the indicator's label (the symbol of the value indicated, e.g. "CPU")
  if params.value.label then
    self.cairo:SetLineWidth(1)
    self.cairo:SetColor(Solarized.BASE1)
    self.cairo:SelectFontFace("Helvetica")
    self.cairo:SetFontSize(math.floor(1.3 * params.width))
    self.cairo:MoveTo(
        math.floor(params.pos.x + 0.4 * params.width),
        math.floor(params.pos.y + params.radius + 0.5 * params.width)
    )
    self.cairo:ShowText(params.value.label)
    self.cairo:Stroke()
  end

  if not params.hidePercentSign then
    self.cairo:SetColor(Solarized.BASE0)
    self.cairo:SelectFontFace("Helvetica", self.cairo.Font.Slant.NORMAL, self.cairo.Font.Weight.BOLD)
    self.cairo:SetFontSize(math.floor(1.1 * params.width))
    self.cairo:MoveTo(
        params.pos.x + params.radius * math.cos(max_angle),
        params.pos.y + params.radius * math.sin(max_angle) + 0.75 * params.width
    )
    self.cairo:ShowText("%")
    self.cairo:Stroke()
  end

end

return Widgets

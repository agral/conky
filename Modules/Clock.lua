local Color = require("Color")
local Solarized = require("Solarized")

local Clock = {
  Analog = {
    border = {
      color = Solarized.BASE0,
      width = 2,
    },
    radius = 80,
  }
}
Clock.Analog.mark = {
  radius = Clock.Analog.radius - 5,
  major = {
    cap = CAIRO_LINE_CAP_ROUND,
    color = Solarized.BASE01,
    length = 10,
    width = 3,
  },
  minor = {
    cap = CAIRO_LINE_CAP_ROUND,
    color = Solarized.BASE00,
    length = 5,
    width = 2
  },
},
setmetatable(Clock, {__index = Clock,})

function Clock:Draw(params, settingsOverride)
  assert(params and params.cairo and params.x and params.y)
  self.cairo, self.x, self.y = params.cairo, params.x, params.y
  -- TODO: add merge-tables utility, allow overriding of default settings.

  self:DrawAnalogClock()
end

function Clock:DrawAnalogClock()
  self.cairo:SetColor(self.Analog.border.color)
  self.cairo:SetLineWidth(self.Analog.border.width)
  self.cairo:Arc(self.x, self.y, self.Analog.radius, 0, 2 * math.pi)
  self.cairo:Stroke()

  local mark, markNumber, x, y, angle
  for markNumber = 0, 11 do
    mark = (markNumber % 3 == 0) and self.Analog.mark.major or self.Analog.mark.minor
    self.cairo:SetColor(mark.color)
    self.cairo:SetLineCap(mark.cap)
    self.cairo:SetLineWidth(mark.width)
    angle = markNumber * math.pi / 6    -- == 30 * math.pi/180, in radians.
    x = self.x + self.Analog.mark.radius * math.sin(angle)
    y = self.y + self.Analog.mark.radius * math.cos(angle)
    self.cairo:MoveTo(x, y)
    x = self.x + (self.Analog.mark.radius - mark.length) * math.sin(angle)
    y = self.y + (self.Analog.mark.radius - mark.length) * math.cos(angle)
    self.cairo:LineTo(x, y)
    self.cairo:Stroke()
  end
end

return Clock

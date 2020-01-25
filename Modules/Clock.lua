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
    width = 2,
  },
}
Clock.Analog.Hands = {
  hour = {
    cap = CAIRO_LINE_CAP_BUTT,
    color = Solarized.BLUE:WithAlpha(0.95),
    radius = {
      inner = Clock.Analog.radius - 40,
      outer = Clock.Analog.radius - 15,
    },
    width = 6,
  },
  minute = {
    cap = CAIRO_LINE_CAP_BUTT,
    color = Solarized.BLUE:WithAlpha(0.75),
    radius = {
      inner = Clock.Analog.radius - 40,
      outer = Clock.Analog.radius - 5,
    },
    width = 3,
  },
  second = {
    bar = {
      cap = CAIRO_LINE_CAP_BUTT,
      color = Solarized.MAGENTA:WithAlpha(0.4),
      radius = Clock.Analog.radius - 2,
      width = 4,
    },
    cap = CAIRO_LINE_CAP_ROUND,
    color = Solarized.MAGENTA:WithAlpha(0.8),
    radius = {
      inner = Clock.Analog.radius - 8,
      outer = Clock.Analog.radius - 2,
    },
    width = 3,
  },
}
setmetatable(Clock, {__index = Clock,})

function Clock:Draw(params, settingsOverride)
  assert(params and params.cairo and params.x and params.y)
  self.cairo, self.x, self.y = params.cairo, params.x, params.y
  -- TODO: add merge-tables utility, allow overriding of default settings.

  self:GetDateTime()
  self:DrawAnalogClock()
end

function Clock:DrawAnalogClock()
  -- Draws the clock face: a round border and twelve hour marks:
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

  -- Draws the clock hands:
  local angles = {
    hour = math.pi * self.Time.InSeconds.hours / 21600,
    minute = math.pi * self.Time.InSeconds.minutes / 1800,
    second = math.pi * self.Time.seconds / 30
  }
  for name, hand in pairs(self.Analog.Hands) do
    self.cairo:SetColor(hand.color)
    self.cairo:SetLineCap(hand.cap)
    self.cairo:SetLineWidth(hand.width)
    x = self.x + hand.radius.outer * math.sin(angles[name])
    y = self.y - hand.radius.outer * math.cos(angles[name])
    self.cairo:MoveTo(x, y)
    x = self.x + hand.radius.inner * math.sin(angles[name])
    y = self.y - hand.radius.inner * math.cos(angles[name])
    self.cairo:LineTo(x, y)
    self.cairo:Stroke()
    if hand.bar then
      local startAngle, endAngle = -0.5 * math.pi, math.pi * (-0.5 + (self.Time.seconds / 30))
      self.cairo:SetColor(hand.bar.color)
      self.cairo:SetLineCap(hand.bar.cap)
      self.cairo:SetLineWidth(hand.bar.width)
      self.cairo:Arc(self.x, self.y, hand.bar.radius, startAngle, endAngle)
      self.cairo:Stroke()
    end
  end
end

function Clock:GetDateTime()
  local time = os.date("*t")
  self.Time = {
    seconds = time.sec,
    minutes = time.min,
    hours = time.hour,
    InSeconds = {
      minutes = 60 * time.min + time.sec,
    },
  }
  self.Time.InSeconds.hours = self.Time.InSeconds.minutes + 3600 * self.Time.hours
end

return Clock

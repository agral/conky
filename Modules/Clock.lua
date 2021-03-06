local Color = require("Color")
local Solarized = require("Solarized")

local dirWorktime = "/tmp/Clock/Worktime/"

local Clock = {
  Analog = {
    border = {
      color = Solarized.BASE0,
      width = 2,
    },
    radius = 80,
  },
  Time = {}
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
Clock.Digital = {
  hours = {
    color = {
      foreground = Solarized.BASE2:WithAlpha(0.9),
      background = Solarized.BASE2:WithAlpha(0.05),
    },
    font = {
      name = "Segment7",
      size = 28,
    },
    offset = {
      x = -36,
      y = 10,
    },
  },
  minutes = {
    color = {
      foreground = Solarized.BASE2:WithAlpha(0.7),
      background = Solarized.BASE2:WithAlpha(0.05),
    },
    font = {
      name = "Segment7",
      size = 28,
    },
    offset = {
      x = 3,
      y = 10,
    },
  },
}
Clock.Worktime = {
  Bar = {
    angle = {
      left = 0.75 * math.pi,    -- == 135 degrees
      right = 2.25 * math.pi,   -- == 405 degrees
    },
    cap = CAIRO_LINE_CAP_BUTT,
    color = {
      background = Solarized.BASE01:WithAlpha(0.25),
      worktime = Solarized.ORANGE:WithAlpha(0.7),
      overtime = Solarized.BASE3:WithAlpha(0.95),
    },
    marks = {
      major = {
        color = Color:FromHex("161616"),
        length = 10,
        width = 2.0,
      },
      minor = {
        color = Color:FromHex("090909"),
        length = 7,
        width = 0.7,
      },
    },
    radius = Clock.Analog.radius + 40,
    width = 15,
  },
  Files = {
    start = dirWorktime .. "start",
    target = dirWorktime .. "target",
  },
  Summary = {
    offset = {
      x = -225,
      y = 30,
      valueX = 45,
    },
    Title = {
      label = "Worktime",
      width = 90,
    },
  },
}
Clock.Worktime.Bar.angle.width = Clock.Worktime.Bar.angle.right - Clock.Worktime.Bar.angle.left
Clock.Worktime.Bar.marks.outerRadius = Clock.Worktime.Bar.radius + 0.5 * Clock.Worktime.Bar.width
Clock.Worktime.Bar.marks.major.innerRadius =
    Clock.Worktime.Bar.marks.outerRadius - Clock.Worktime.Bar.marks.major.length
Clock.Worktime.Bar.marks.minor.innerRadius =
    Clock.Worktime.Bar.marks.outerRadius - Clock.Worktime.Bar.marks.minor.length

setmetatable(Clock, {__index = Clock,})

local function SecondsToHHMM(seconds)
  local fullHours = math.floor(seconds / 3600)
  seconds = seconds - (3600 * fullHours)
  local fullMinutes = math.floor(seconds / 60)
  return string.format("%02d:%02d", fullHours, fullMinutes)
end

function Clock:Draw(params)
  assert(params and params.cairo and params.x and params.y)
  self.cairo, self.x, self.y = params.cairo, params.x, params.y
  -- TODO: add merge-tables utility, allow overriding of default settings.

  self:GetDateTime()
  self:DrawAnalogClock()
  self:DrawDigitalClock(self.Digital)
  self:DrawWorktime()
end

function Clock:DrawAnalogClock()
  -- Draws the clock face: a round border and twelve hour marks:
  self.cairo:SetColor(self.Analog.border.color)
  self.cairo:SetLineWidth(self.Analog.border.width)
  self.cairo:Arc(self.x, self.y, self.Analog.radius, 0, 2 * math.pi)
  self.cairo:Stroke()

  local mark, x, y, angle
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

function Clock:DrawDigitalClock(config)
  for name, part in pairs(config) do
    self.cairo:SelectFontFace(part.font.name, part.font.slant, part.font.weight)
    self.cairo:SetFontSize(part.font.size)
    self.cairo:SetColor(part.color.background)
    self.cairo:MoveTo(self.x + part.offset.x, self.y + part.offset.y)
    self.cairo:ShowText("88")
    self.cairo:Stroke()
    self.cairo:SetColor(part.color.foreground)
    self.cairo:MoveTo(self.x + part.offset.x, self.y + part.offset.y)
    self.cairo:ShowText(string.format("%02d", self.Time[name]))
    self.cairo:Stroke()
  end
end

function Clock:GetDateTime()
  local time = os.date("*t")
  self.Time.seconds = time.sec
  self.Time.minutes = time.min
  self.Time.hours = time.hour
  self.Time.InSeconds = {
    minutes = 60 * time.min + time.sec,
  }
  self.Time.InSeconds.hours = self.Time.InSeconds.minutes + 3600 * self.Time.hours
end

function Clock:ReadAndCalculateWorktimeData()
  local s,t = io.open(self.Worktime.Files.start), io.open(self.Worktime.Files.target)
  if not (s and t) then
    self.Time.Worktime, self.Time.Overtime = {}, {}
    return false
  end
  local start, target = tonumber(s:read()), tonumber(t:read())
  s:close()
  t:close()

  -- Values directly related to worktime start/end are expected to almost never change.
  -- Checks whether values derived from worktime start/end need update, if so, recalculates them:
  if
    (self.Time.Worktime == nil or self.Time.Worktime.start == nil or self.Time.Worktime.target == nil) or
    (start ~= self.Time.Worktime.start) or (target ~= self.Time.Worktime.target)
  then
    print("[Clock] Time update")
    self.Time.Worktime, self.Time.Overtime = {}, {}
    self.Time.Worktime.start, self.Time.Worktime.target = start, target
    self.Time.Worktime.duration = self.Time.Worktime.target - self.Time.Worktime.start
    self.Time.Worktime.startStr = SecondsToHHMM(self.Time.Worktime.start)
  end

  -- Calculates how much worktime and overtime is already done:
  self.Time.Worktime.seconds = math.max(math.min(
      self.Time.InSeconds.hours - self.Time.Worktime.start, self.Time.Worktime.duration), 0)
  self.Time.Overtime.seconds = math.max(math.min(
      self.Time.InSeconds.hours - self.Time.Worktime.target, self.Time.Worktime.duration), 0)
  self.Time.Worktime.percentDone = math.max(math.min(
      self.Time.Worktime.seconds / self.Time.Worktime.duration, 1), 0)
  self.Time.Overtime.percentDone = math.max(math.min(
      self.Time.Overtime.seconds / self.Time.Worktime.duration, 1), 0)

  return true
end

function Clock:DrawWorktime()
  -- Draws the background for the worktime/overtime bar:
  self.cairo:SetColor(self.Worktime.Bar.color.background)
  self.cairo:SetLineCap(self.Worktime.Bar.cap)
  self.cairo:SetLineWidth(self.Worktime.Bar.width)
  self.cairo:Arc(
      self.x, self.y, self.Worktime.Bar.radius,
      self.Worktime.Bar.angle.left, self.Worktime.Bar.angle.right
  )
  self.cairo:Stroke()

  if not self:ReadAndCalculateWorktimeData() then
    return
  end

  -- Draws the worktime and overtime bars, if any time is registered on them:
  if self.Time.Worktime.percentDone > 0 then
    local worktimeAngle = self.Worktime.Bar.angle.left +
        (self.Worktime.Bar.angle.width * self.Time.Worktime.percentDone)
    self.cairo:SetColor(self.Worktime.Bar.color.worktime)
    self.cairo:Arc(
        self.x, self.y, self.Worktime.Bar.radius,
        self.Worktime.Bar.angle.left, worktimeAngle
    )
    self.cairo:Stroke()

    -- Prepares to draw the worktime summary section:
    local Summary = self.Worktime.Summary
    local summaryX, summaryY = self.x + Summary.offset.x, self.y + Summary.offset.y
    local summaryCurrentY = summaryY
    self.cairo:SelectFontFace("GohuFont")
    self.cairo:SetFontSize(11)
    self.cairo:SetLineWidth(1)
    self.cairo:SetColor(Solarized.BASE00)

    -- Draws the title bar of worktime summary widget
    local titleW = self.cairo:GetTextSize(Summary.Title.label)
    self.cairo:MoveTo(summaryX + 0.5 * (Summary.Title.width - titleW), summaryCurrentY - 2)
    self.cairo:ShowText(Summary.Title.label)
    self.cairo:MoveTo(summaryX + 0.5, summaryCurrentY + 0.5)
    self.cairo:RelLineTo(Summary.Title.width, 0)
    self.cairo:Stroke()

    -- Renders the work start time:
    summaryCurrentY = summaryCurrentY + 15
    self.cairo:MoveTo(summaryX, summaryCurrentY)
    self.cairo:ShowText("Start:")
    self.cairo:MoveTo(summaryX + Summary.offset.valueX, summaryCurrentY)
    self.cairo:ShowText(self.Time.Worktime.startStr)
    self.cairo:Stroke()

    -- Renders the elapsed worktime:
    summaryCurrentY = summaryCurrentY + 11
    self.cairo:MoveTo(summaryX, summaryCurrentY)
    self.cairo:ShowText("Done:")
    self.cairo:Stroke()
    self.cairo:SetColor(Solarized.ORANGE)
    self.cairo:MoveTo(summaryX + Summary.offset.valueX, summaryCurrentY)
    self.cairo:ShowText(SecondsToHHMM(self.Time.Worktime.seconds))
    self.cairo:Stroke()

    -- Renders the currently remaining worktime / currently done overtime (whichever applies):
    summaryCurrentY = summaryCurrentY + 11
    self.cairo:SetColor(Solarized.BASE00)
    self.cairo:MoveTo(summaryX, summaryCurrentY)
    if self.Time.Overtime.percentDone > 0 then
      self.cairo:ShowText("Ovrt:")
      self.cairo:SetColor(Solarized.BASE3)
      self.cairo:MoveTo(summaryX + Summary.offset.valueX, summaryCurrentY)
      self.cairo:ShowText(SecondsToHHMM(self.Time.Overtime.seconds))
    else
      self.cairo:ShowText("Left:")
      self.cairo:MoveTo(summaryX + Summary.offset.valueX, summaryCurrentY)
      self.cairo:ShowText(SecondsToHHMM(self.Time.Worktime.target - self.Time.InSeconds.hours))
    end
    self.cairo:Stroke()
  end

  if self.Time.Overtime.percentDone > 0 then
    local overtimeAngle = self.Worktime.Bar.angle.left +
        (self.Worktime.Bar.angle.width * self.Time.Overtime.percentDone)
    self.cairo:SetLineWidth(self.Worktime.Bar.width)
    self.cairo:SetColor(self.Worktime.Bar.color.overtime)
    self.cairo:Arc(
        self.x, self.y, self.Worktime.Bar.radius,
        self.Worktime.Bar.angle.left, overtimeAngle
    )
    self.cairo:Stroke()
  end

  -- Draws the bar's hour and minute marks:
  local currentAngle = self.Worktime.Bar.angle.left + 0.5 * math.pi
  local deltaAngle = self.Worktime.Bar.angle.width / 48
  local x, y
  for i = 0, 7 do
    if i > 0 then
      self.cairo:SetColor(self.Worktime.Bar.marks.major.color)
      self.cairo:SetLineWidth(self.Worktime.Bar.marks.major.width)
      x = self.x + self.Worktime.Bar.marks.outerRadius * math.sin(currentAngle)
      y = self.y - self.Worktime.Bar.marks.outerRadius * math.cos(currentAngle)
      self.cairo:MoveTo(x, y)
      x = self.x + self.Worktime.Bar.marks.major.innerRadius * math.sin(currentAngle)
      y = self.y - self.Worktime.Bar.marks.major.innerRadius * math.cos(currentAngle)
      self.cairo:LineTo(x, y)
      self.cairo:Stroke()
    end
    currentAngle = currentAngle + deltaAngle
    self.cairo:SetColor(self.Worktime.Bar.marks.minor.color)
    self.cairo:SetLineWidth(self.Worktime.Bar.marks.minor.width)
    for _ = 1, 5 do
      x = self.x + self.Worktime.Bar.marks.outerRadius * math.sin(currentAngle)
      y = self.y - self.Worktime.Bar.marks.outerRadius * math.cos(currentAngle)
      self.cairo:MoveTo(x, y)
      x = self.x + self.Worktime.Bar.marks.minor.innerRadius * math.sin(currentAngle)
      y = self.y - self.Worktime.Bar.marks.minor.innerRadius * math.cos(currentAngle)
      self.cairo:LineTo(x, y)
      currentAngle = currentAngle + deltaAngle
    end
    self.cairo:Stroke()
  end
end

return Clock

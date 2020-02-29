local Solarized = require("Solarized")

local Info = {
  iterations = 0
}
setmetatable(Info, {
  __index = Info
})

function Info:Draw(params)
  assert(params.cairo and params.widgets)
  assert(params.x and params.y)

  self.cairo, self.widgets = params.cairo, params.widgets
  self.x, self.y = params.x, params.y

  local conky_cpu = conky_parse("${cpu}")
  local cpuNormalized = tonumber(conky_cpu) / 100
  self.widgets:DrawArcIndicator({
    pos = {x = self.x + 25, y = self.y + 25},
    radius = 20,
    width = 8,
    value = {
      normalized = cpuNormalized,
      text = string.format("%d", 100 * cpuNormalized),
      label = "CPU",
    },
  })

  local conky_memperc = conky_parse("${memperc}")
  local memNormalized = tonumber(conky_memperc) / 100
  self.widgets:DrawArcIndicator({
    pos = {x = self.x + 100, y = self.y + 25},
    radius = 20,
    width = 8,
    value = {
      normalized = memNormalized,
      text = conky_memperc,
      label = "RAM",
    },
  })

  local conky_fs_used_perc = conky_parse("${fs_used_perc}")
  local hddNormalized = tonumber(conky_fs_used_perc) / 100
  self.widgets:DrawArcIndicator({
    pos = {x = self.x + 175, y = self.y + 25},
    radius = 20,
    width = 8,
    value = {
      normalized = hddNormalized,
      text = conky_fs_used_perc,
      label = "SDD",
    },
  })

  local conky_battery_percent = conky_parse("${battery_percent}")
  local batNormalized = tonumber(conky_battery_percent) / 100
  self.widgets:DrawArcIndicator({
    color = Solarized.VIOLET,
    pos = {x = self.x + 250, y = self.y + 25},
    radius = 20,
    width = 8,
    value = {
      normalized = batNormalized,
      text = conky_battery_percent,
      label = "BAT"
    },
  })

  local conky_desktop = tonumber(conky_parse("${desktop}"))
  local conky_desktop_count = tonumber(conky_parse("${desktop_number}"))
  local desktopNormalized = conky_desktop / conky_desktop_count
  self.widgets:DrawArcIndicator({
    color = Solarized.MAGENTA,
    pos = {x = self.x + 325, y = self.y + 25},
    radius = 20,
    width = 8,
    value = {
      normalized = desktopNormalized,
      text = string.format("%d", conky_desktop),
      label = "DST",
    },
    hidePercentSign = true,
  })

  self.iterations = self.iterations + 1
  print("Drawn, iter=" .. self.iterations)
end

return Info

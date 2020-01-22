-- Solarized.lua
-- Contains definitions of the colors from Solarized palette as instances of Color class.

local Color = require("Color")

local Solarized = {
  BASE03  = Color:FromHex("002b36"),
  BASE02  = Color:FromHex("073642"),
  BASE01  = Color:FromHex("586e75"),
  BASE00  = Color:FromHex("657b83"),
  BASE0   = Color:FromHex("839496"),
  BASE1   = Color:FromHex("93a1a1"),
  BASE2   = Color:FromHex("eee8d5"),
  BASE3   = Color:FromHex("fdf6e3"),
  YELLOW  = Color:FromHex("b58900"),
  ORANGE  = Color:FromHex("cb4b15"),
  RED     = Color:FromHex("dc322f"),
  MAGENTA = Color:FromHex("d33682"),
  VIOLET  = Color:FromHex("6c71c4"),
  BLUE    = Color:FromHex("268bd2"),
  CYAN    = Color:FromHex("2aa198"),
  GREEN   = Color:FromHex("859900"),
}

setmetatable(Solarized, {
  __index = Solarized,
  __newindex = function()
    error("[Solarized] Attempt to modify a read-only Solarized table")
  end,
  __metatable = false,
})

return Solarized

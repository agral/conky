-- Color.lua
-- Handles colors in various representations.

local function ToString(color)
  return string.format("Color(%.2f, %.2f, %.2f, %.2f)", color.r, color.g, color.b, color.a)
end

local Color = {}
setmetatable(Color, {
  __index = Color,
  __tostring = ToString,})


-- Creates a new instance of Color class based on four channels in normalized (0.0 - 1.0) range.
function Color:New(red, green, blue, alpha)
  assert(type(red) == "number" and red >= 0.0 and red <= 1.0,
      "[Color] New(): Red component should be specified as a number in range 0..1")
  assert(type(green) == "number" and green >= 0.0 and green <= 1.0,
      "[Color] New(): Green component should be specified as a number in range 0..1")
  assert(type(blue) == "number" and blue >= 0.0 and blue <= 1.0,
      "[Color] New(): Blue component should be specified as a number in range 0..1")
  assert(type(alpha) == "number" and alpha >= 0.0 and alpha <= 1.0,
      "[Color] New(): Alpha component should be specified as a number in range 0..1")

  local color = {r = red, g = green, b = blue, a = alpha}
  setmetatable(color, {
    __index = Color,
    __tostring = ToString,
  })
  return color
end

-- Creates a new instance of Color class based on a hex representation, using 6 or 8 hex digits.
function Color:FromHex(hexString)
  assert(type(hexString) == "string", "[Color] FromHex(): hexString has to be of string type")
  assert(#hexString == 6 or #hexString == 8, "[Color] FromHex(): hexString has to be exactly 6 or 8 chars long")

  local a = 1.0 -- Unless overriden, the default opacity of the created color is 100%.
  if #hexString == 8 then
    local alphaString = string.sub(hexString, 7, 8)
    a = tonumber(alphaString, 16) / 255
  end

  local redString, greenString, blueString = hexString:match("(..)(..)(..)")
  local r = tonumber(redString, 16) / 255
  local g = tonumber(greenString, 16) / 255
  local b = tonumber(blueString, 16) / 255

  return self:New(r, g, b, a)
end

-- Returns a new Color instance with modified alpha value.
function Color:WithAlpha(newAlpha)
  return self:New(self.r, self.g, self.b, newAlpha)
end

return Color

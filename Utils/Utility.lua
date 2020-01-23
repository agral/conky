-- Utility.lua
-- Exposes various utility/helper functions

local Utility = {}
setmetatable(Utility, {__index = Utility,})

-- Extracts the base directory's path from a file path
-- (e.g. DirectoryFromPath("/tmp/foo/bar") --> "/tmp/foo/"
function Utility:DirectoryFromPath(path, separator)
  separator = separator or "/"
  return path:match("(.*" .. separator .. ")")
end

-- Returns true if file exists at given path
function Utility:FileExists(filepath)
  if type(filepath) ~= "string" then return false end

  local f = io.open(filepath, "r")
  if f ~= nil then
    io.close(f)
    return true
  end

  return false
end

-- Converts a duration string to number of seconds equaling that duration
-- (e.g. DurationToSeconds("1:03:25") --> 3805  /== 3600 + 180 + 25/
function Utility:DurationToSeconds(duration)
  local values = self:Split(duration, ":")
  assert(#values <= 3, "[Utility.lua] Malformed duration passed to DurationToSeconds method")

  local result = 0
  for _,v in ipairs(values) do
    -- Works since there's 60 seconds in a minute and 60 minutes in an hour.
    result = result * 60 + tonumber(v)
  end

  return result
end

-- Returns a string with certain black-listed characters substituted by an underscore character
function Utility:Sanitize(str)
  if type(str) ~= "string" then return "_" end
  return str:gsub("%s+", "_"):gsub("/+", "_"):gsub("\\+", "_"):gsub("'+", "_")
            :gsub("\"+", "_"):gsub("&+", "_"):gsub("%(+", "_"):gsub("%)+", "_")
            :gsub("$+", "_"):gsub("!+", "_"):gsub(":+", "_")
end

-- Splits a str into a table of strings, by given delimiter (default: space).
-- (e.g. Split("a b, c, d e f", ",") --> {"a b", "c", "d e f"}
function Utility:Split(str, delimiter)
  delimiter = delimiter or "%s"
  local result = {}
  for token in string.gmatch(str, "([^" .. delimiter .. "]+)") do
    table.insert(result, token)
  end
  return result
end

return Utility

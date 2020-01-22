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


-- Returns a string with certain black-listed characters substituted by an underscore character
function Utility:Sanitize(str)
  if type(str) ~= "string" then return "_" end
  return str:gsub("%s+", "_"):gsub("/+", "_"):gsub("\\+", "_"):gsub("'+", "_")
            :gsub("\"+", "_"):gsub("&+", "_"):gsub("%(+", "_"):gsub("%)+", "_")
            :gsub("$+", "_"):gsub("!+", "_"):gsub(":+", "_")
end

return Utility

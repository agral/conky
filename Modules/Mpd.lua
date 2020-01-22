local Utility = require("Utility")
local Color = require("Color")
local Solarized = require("Solarized")

local dirCovers = "/home/simba/Pictures/AlbumCovers"
local dirMusic = "/home/simba/Audio/Music"

local Mpd = {
  cover = {
    border = {
      width = 4,
    },
  },
}
setmetatable(Mpd, {__index = Mpd,})

function Mpd:Draw(params)
  assert(params.cairo)
  assert(params.x and params.y and params.size)

  self.cairo = params.cairo
  self.x, self.y, self.size = params.x, params.y, params.size

  local mpdStatus = conky_parse("${mpd_status}")
  if not mpdStatus or mpdStatus == "" then
    print("[Mpd] Draw(): no MPD process")
    return
  end

  self:DrawCover()
end

function Mpd:DrawCover()
  local relativeFilePath = conky_parse("${mpd_file}")
  local absoluteFilePath = string.format("%s/%s", dirMusic, relativeFilePath)
  local basePath = Utility:DirectoryFromPath(absoluteFilePath)
  local borderColor = Solarized.BASE0
  local pathCover

  local candidate = basePath .. "cover.png"
  if Utility:FileExists(candidate) then
    pathCover = candidate
    borderColor = Solarized.VIOLET
  else
    local mpd_artist = conky_parse("${mpd_artist}")
    local mpd_album = conky_parse("${mpd_album}")
    local artist, album = Utility:Sanitize(mpd_artist), Utility:Sanitize(mpd_album)

    if album ~= "" and artist ~= "" then
      candidate = string.format("%s/%s/%s.png", dirCovers, artist, album)
      if Utility:FileExists(candidate) then
        pathCover = candidate
        borderColor = Solarized.YELLOW
      end
    end
  end

  if pathCover then
    local image = self.cairo:ImageSurfaceCreateFromPng(pathCover)
    self.cairo:Save()
    local iw, ih = self.cairo:ImageSurfaceGetWidth(image), self.cairo:ImageSurfaceGetHeight(image)
    local sx, sy = self.size / iw, self.size / ih
    self.cairo:Scale(sx, sy)
    self.cairo:SetSourceSurface(image, self.x / sx, self.y / sy)
    self.cairo:Paint()
    self.cairo:Restore()
    self.cairo:SurfaceDestroy(image)
  else
    print("[Mpd] No cover found.")
  end

  self.cairo:SetLineWidth(self.cover.border.width)
  self.cairo:SetColor(borderColor)
  self.cairo:MoveTo(self.x + 0.5 * self.size, self.y)
  self.cairo:LineTo(self.x + self.size, self.y)
  self.cairo:LineTo(self.x + self.size, self.y + self.size)
  self.cairo:LineTo(self.x, self.y + self.size)
  self.cairo:LineTo(self.x, self.y)
  self.cairo:LineTo(self.x + 0.5 * self.size, self.y)
  self.cairo:Stroke()
end

return Mpd

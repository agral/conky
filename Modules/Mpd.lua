local Color = require("Color")
local Solarized = require("Solarized")
local Utility = require("Utility")

local dirCovers = "/home/simba/Pictures/AlbumCovers"
local dirMusic = "/home/simba/Audio/Music"


local Mpd = {
  cover = {
    border = {
      width = 2, -- should be an even number (i.e. multiple of 2) to avoid Cairo's antialiasing kicking in.
    },
  },
  font = {
    name = "GohuFont",
    size = 11,
  },
  Glyph = {
    color = Solarized.BASE00,
    size = 20,
    x = 145,
    y = 4,
  },
  MpdStatus = {
    Killed = "MPD not responding",
    Offline = "Offline",
    Paused = "Paused",
    Playing = "Playing",
    Stopped = "Stopped",
  },
  progressBar = {
    border = 1,
    outer = {
      x = 145.5,
      y = 30.5,
      width = 150,
      height = 3,
      color = Solarized.BASE0,
    },
    inner = {
      x = 145,
      y = 31,
      height = 2,
      width = 148,
      color = Solarized.BASE1,
    },
  },
  texts = {
    color = Solarized.BASE0,
    songProgress = {
      x = 190,
      y = 12,
    },
    songTitle = {
      color = Solarized.BASE1,
      x = 145,
      y = 38,
    },
    status = {
      x = 190,
      y = 0,
    },
  },
}
setmetatable(Mpd, {__index = Mpd,})

function Mpd:Draw(params)
  assert(params.cairo)
  assert(params.x and params.y and params.size)

  self.cairo = params.cairo
  self.x, self.y, self.size = params.x, params.y, params.size

  self.mpdStatus = conky_parse("${mpd_status}")
  if not self.mpdStatus or self.mpdStatus == "" or self.mpdStatus == self.MpdStatus.Killed then
    self.mpdStatus = self.MpdStatus.Offline
  end

  if self.mpdStatus == self.MpdStatus.Offline or self.mpdStatus == self.MpdStatus.Stopped then
    self.mpdTitle = nil
    self.mpdArtist = nil
    self.mpdAlbum = nil
    self.mpdBitrate = nil
    self.mpdElapsed = nil
    self.mpdLength = nil
  else
    self.mpdTitle = conky_parse("${mpd_title}")
    self.mpdArtist = conky_parse("${mpd_artist}")
    self.mpdAlbum = conky_parse("${mpd_album}")
    self.mpdBitrate = conky_parse("${mpd_bitrate}")
    self.mpdElapsed = conky_parse("${mpd_elapsed}")
    self.mpdLength = conky_parse("${mpd_length}")
  end
  self:DrawStatus()
  self:DrawCover()
  self:DrawProgressBar()
  self:DrawTexts()
end

function Mpd:DrawCover()
  local borderColor, pathCover = Solarized.BASE0, nil

  if self.mpdStatus == self.MpdStatus.Offline then
    borderColor = Solarized.RED
    pathCover = nil -- TODO: add generic "killed" and "stopped" images.
  elseif self.mpdStatus == self.MpdStatus.Stopped then
    borderColor = Solarized.BASE0
    pathCover = nil
  else
    local relativeFilePath = conky_parse("${mpd_file}")
    local absoluteFilePath = string.format("%s/%s", dirMusic, relativeFilePath)
    local basePath = Utility:DirectoryFromPath(absoluteFilePath)
    local candidate = basePath .. "cover.png"
    if Utility:FileExists(candidate) then
      borderColor = Solarized.VIOLET
      pathCover = candidate
    else
      local artist, album = Utility:Sanitize(self.mpdArtist), Utility:Sanitize(self.mpdAlbum)
      if album ~= "" and artist ~= "" then
        candidate = string.format("%s/%s/%s.png", dirCovers, artist, album)
        if Utility:FileExists(candidate) then
          borderColor = Solarized.YELLOW
          pathCover = candidate
        end
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

function Mpd:DrawStatus()
  local gx, gy = self.x + self.Glyph.x, self.y + self.Glyph.y
  self.cairo:SetColor(self.Glyph.color)
  if self.mpdStatus == self.MpdStatus.Playing then
    -- Draws a right-facing filled triangle (a "Play" symbol):
    self.cairo:MoveTo(gx, gy + 0.5 * self.Glyph.size)
    self.cairo:LineTo(gx, gy)
    self.cairo:LineTo(gx + 0.5 * math.sqrt(3) * self.Glyph.size, gy + 0.5 * self.Glyph.size)
    self.cairo:LineTo(gx, gy + self.Glyph.size)
    self.cairo:LineTo(gx, gy + 0.5 * self.Glyph.size)
    self.cairo:Fill()
    self.cairo:Stroke()
  elseif self.mpdStatus == self.MpdStatus.Paused then
    -- Draws two vertical bars (a "Pause" symbol):
    self.cairo:MoveTo(gx, gy + 0.5 * self.Glyph.size)
    self.cairo:LineTo(gx, gy)
    self.cairo:LineTo(gx + 0.4 * self.Glyph.size, gy)
    self.cairo:LineTo(gx + 0.4 * self.Glyph.size, gy + self.Glyph.size)
    self.cairo:LineTo(gx, gy + self.Glyph.size)
    self.cairo:LineTo(gx, gy + 0.5 * self.Glyph.size)

    self.cairo:MoveTo(gx + 0.6 * self.Glyph.size, gy + 0.5 * self.Glyph.size)
    self.cairo:LineTo(gx + 0.6 * self.Glyph.size, gy)
    self.cairo:LineTo(gx + self.Glyph.size, gy)
    self.cairo:LineTo(gx + self.Glyph.size, gy + self.Glyph.size)
    self.cairo:LineTo(gx + 0.6 * self.Glyph.size, gy + self.Glyph.size)
    self.cairo:LineTo(gx + 0.6 * self.Glyph.size, gy + 0.5 * self.Glyph.size)
  elseif self.mpdStatus == self.MpdStatus.Stopped then
    -- Draws a filled square (a "Playback Stopped" symbol):
    self.cairo:MoveTo(gx, gy + 0.5 * self.Glyph.size)
    self.cairo:LineTo(gx, gy)
    self.cairo:LineTo(gx + self.Glyph.size, gy)
    self.cairo:LineTo(gx + self.Glyph.size, gy + self.Glyph.size)
    self.cairo:LineTo(gx, gy + self.Glyph.size)
    self.cairo:LineTo(gx, gy + 0.5 * self.Glyph.size)
  else
    -- Draws an X symbol:
  end
  self.cairo.Fill()
  self.cairo.Stroke()
end

function Mpd:DrawTexts()
  self.cairo:SelectFontFace(self.font.name)
  self.cairo:SetFontSize(self.font.size)
  self.cairo:SetColor(self.texts.color)

  -- Writes out a status string in form of "MPD: STATUS" (e.g. "MPD: Playing"):
  self.cairo:MoveTo(self.x + self.texts.status.x, self.y + self.texts.status.y + self.font.size)
  self.cairo:ShowText(string.format("MPD: %s", self.mpdStatus))
  self.cairo:Stroke()

  if self.mpdStatus == self.MpdStatus.Playing or self.mpdStatus == self.MpdStatus.Paused then
    -- Writes out current song's progress:
    self.cairo:MoveTo(self.x + self.texts.songProgress.x, self.y + self.texts.songProgress.y + self.font.size)
    self.cairo:ShowText(string.format("%s / %s", self.mpdElapsed, self.mpdLength))
    self.cairo:Stroke()

    -- Writes out current song's name, artist and album (if available):
    if self.mpdTitle then
      self.cairo:SetColor(self.texts.songTitle.color)
      self.cairo:MoveTo(self.x + self.texts.songTitle.x, self.y + self.texts.songTitle.y + self.font.size)
      self.cairo:ShowText(self.mpdTitle)
      self.cairo:Stroke()
    end
  end
end

function Mpd:DrawProgressBar()
  self.cairo:SetLineWidth(1)
  self.cairo:SetColor(self.progressBar.outer.color)
  self.cairo:MoveTo(
      self.x + self.progressBar.outer.x + 0.5 * self.progressBar.outer.width,
      self.y + self.progressBar.outer.y
  )
  self.cairo:RelLineTo(0.5 * self.progressBar.outer.width, 0)
  self.cairo:RelLineTo(0, self.progressBar.outer.height)
  self.cairo:RelLineTo(-self.progressBar.outer.width, 0)
  self.cairo:RelLineTo(0, -self.progressBar.outer.height)
  self.cairo:RelLineTo(0.5 * self.progressBar.outer.width, 0)
  self.cairo:Stroke()

  if self.mpdStatus == self.MpdStatus.Playing or self.mpdStatus == self.MpdStatus.Paused then
    local tElapsed = Utility:DurationToSeconds(self.mpdElapsed)
    local tLength = Utility:DurationToSeconds(self.mpdLength)
    local perc = math.min(1.0, math.max(0.0, tElapsed / tLength))

    self.cairo:SetColor(self.progressBar.inner.color)
    self.cairo:MoveTo(self.x + self.progressBar.inner.x, self.y + self.progressBar.inner.y)
    self.cairo:RelLineTo(perc * self.progressBar.inner.width, 0)
    self.cairo:RelLineTo(0, self.progressBar.inner.height)
    self.cairo:RelLineTo(-perc * self.progressBar.inner.width, 0)
    self.cairo:RelLineTo(0, -self.progressBar.inner.height)
    self.cairo:ClosePath()
    self.cairo:Fill()
    self.cairo:Stroke()
  end
end

return Mpd

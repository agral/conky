local Color = require("Color")
local Utility = require("Utility")

local Research = {
  width = 300,
  height = 400,
  headerHeight = 12,
  padding = 10,
  y = 0,
  pathResearch = "/home/simba/Library/Research",
  pathProgressScript = "/home/simba/Source/Conky/Utils/Scripts/GetPdfProgress",
  progressBarHeight = 4,
  clBlack = Color:FromHex("000000"),
  clWhite = Color:FromHex("FFFFFF"),
  clSilver = Color:FromHex("C0C0C0"),
  clWindowBg = Color:FromHex("303030"),
  clWindowTopLine = Color:FromHex("565656"),
  clWindowBreakLineDark = Color:FromHex("0D0C0F"),
  clWindowBreakLineLight = Color:FromHex("4C4B4E"),
  clProgressBarBorder = Color:FromHex("1919197f"),
  clProgressBarFg = Color:FromHex("00A000"),
  clProgressBarBg = Color:FromHex("393939"),

  -- Sets it to a type that is not a "table".
  -- This is a stupid fix for Lua's "loop in gettable" error when checking whether a member field exists.
  -- E.g. "if self.books = nil" when self.books is indeed nil, causes the "loop in gettable" error.
  books = 0,
  booksUpdatePeriod = 60 * 20,
  booksUpdateCounter = 60 * 20,
}
setmetatable(Research, {
  __index = Research,
})

function Research:Draw(params)
  assert(params.cairo)
  assert(params.rightX)
  self.cairo = params.cairo
  self.x = params.rightX - self.width

  if type(self.books) ~= "table" or self.booksUpdateCounter <= 0 then
    self:QueryBookProgress()
  end

  self:DrawWindow()
  self:DrawBookProgress()
  self.booksUpdateCounter = self.booksUpdateCounter - 1
end

function Research:DrawWindow()
  self:DrawWindowShadows()
  -- Draws the window background:
  self.cairo:SetLineWidth(1)
  self.cairo:SetColor(self.clWindowBg)
  self.cairo:MoveTo(self.x, self.y)
  self.cairo:RelLineTo(self.width, 0)
  self.cairo:RelLineTo(0, self.height)
  self.cairo:RelLineTo(-self.width, 0)
  self.cairo:RelLineTo(0, -self.height)
  self.cairo:ClosePath()
  self.cairo:Fill()

  -- Draws the bright line on the top:
  self.cairo:SetColor(self.clWindowTopLine)
  self.cairo:MoveTo(self.x + 1.5, self.y + 1.5)
  self.cairo:RelLineTo(self.width - 2, 0)
  self.cairo:Stroke()

  -- Draws the header:
  self.cairo:SetColor(self.clSilver)
  self.cairo:SelectFontFace("Deja Vu Sans", nil, self.cairo.Font.Weight.Bold)
  self.cairo:SetFontSize(10)
  local prompt = "Press  W-e, S-r  to Research"
  local promptW = self.cairo:GetTextSize(prompt)
  self.cairo:MoveTo(self.x + 0.5 * (self.width - promptW), self.y + 15)
  self.cairo:ShowText(prompt)
  self.cairo:Stroke()
end

function Research:DrawWindowShadows()
  self.cairo:SetColor(Color:FromHex("000000"):WithAlpha(0.33))
  for w = 5, 9, 2 do  -- draws shadows of width: 5, 7 and 9.
    self.cairo:SetLineWidth(w)
    self.cairo:MoveTo(self.x, self.y)
    self.cairo:RelLineTo(0, self.height)
    self.cairo:RelLineTo(self.width, 0)
    self.cairo:Stroke()
  end
end

function Research:QueryBookProgress()
  print("QueryBookProgress()")
  self.books = {}
  local find_command = string.format("ls -A \"%s\"", self.pathResearch)
  local pFile = io.popen(find_command)
  local counter = 1

  for filename in pFile:lines() do
    local progress_command = string.format("bash \"%s\" \"%s/%s\"",
        self.pathProgressScript, self.pathResearch, filename)
    local progress_result = io.popen(progress_command):read("*all")
    local progress_tokens = Utility:Split(progress_result, "/")

    local book_data = {}
    book_data.name = filename
    book_data.current_page = tonumber(progress_tokens[1])
    book_data.pages_count = tonumber(progress_tokens[2])
    book_data.progress = math.min(math.max(book_data.current_page / book_data.pages_count, 0.0), 1.0)
    self.books[counter] = book_data
    counter = counter + 1
  end

  self.booksUpdateCounter = self.booksUpdatePeriod
end

function Research:DrawBookProgress()
  if self.books == nil then return end

  local x, y = self.x + self.padding, self.y + self.padding + self.headerHeight

  for i = 1, #self.books, 1 do
    local book = self.books[i]
    -- Draws the horizontal split-line:
    self.cairo:SetLineWidth(1)
    self.cairo:SetColor(self.clWindowBreakLineLight)
    self.cairo:MoveTo(x - self.padding + 0.5, y + 0.5)
    self.cairo:LineTo(x - self.padding + self.width - 0.5, y + 0.5)
    self.cairo:Stroke()
    self.cairo:SetColor(self.clWindowBreakLineDark)
    self.cairo:MoveTo(x - self.padding + 0.5, y + 1.5)
    self.cairo:LineTo(x - self.padding + self.width - 0.5, y + 1.5)
    self.cairo:Stroke()
    y = y + 10

    -- Renders the book's title:
    self.cairo:MoveTo(x, y + 10)
    self.cairo:SetColor(self.clWhite)
    self.cairo:SelectFontFace("Deja Vu Sans", nil, self.cairo.Font.Weight.Bold)
    self.cairo:SetFontSize(10)
    self.cairo:ShowText(book.name)
    y = y + 17

    -- Draws the progress bar's background:
    self.cairo:SetColor(self.clProgressBarBg)
    self.cairo:MoveTo(x + 0.5, y + 0.5)
    self.cairo:RelLineTo(self.width - 2 * self.padding, 0)
    self.cairo:RelLineTo(0, self.progressBarHeight)
    self.cairo:RelLineTo(-(self.width - 2 * self.padding), 0)
    self.cairo:ClosePath()
    self.cairo:Fill()

    -- Draws the actual progress bar:
    local pbFillWidth = book.progress * (self.width - 2 * self.padding)
    self.cairo:SetColor(self.clProgressBarFg)
    self.cairo:MoveTo(x + 0.5, y + 0.5)
    self.cairo:RelLineTo(pbFillWidth, 0)
    self.cairo:RelLineTo(0, self.progressBarHeight)
    self.cairo:RelLineTo(-pbFillWidth, 0)
    self.cairo:ClosePath()
    self.cairo:Fill()

    -- Draws the progress bar's borders:
    self.cairo:SetColor(self.clProgressBarBorder)
    self.cairo:MoveTo(x + 0.5, y + 0.5)
    self.cairo:RelLineTo(self.width - 2 * self.padding, 0)
    self.cairo:RelLineTo(0, self.progressBarHeight)
    self.cairo:RelLineTo(-(self.width - 2 * self.padding), 0)
    self.cairo:ClosePath()
    self.cairo:Stroke()

    -- Draws the summary text:
    y = y + 6
    self.cairo:SetColor(self.clSilver)
    self.cairo:SelectFontFace("GohuFont")
    self.cairo:SetFontSize(11)
    local caption = string.format("%.2f%% (%d/%d)", 100 * book.progress, book.current_page, book.pages_count)
    local captionW, captionH = self.cairo:GetTextSize(caption)

    self.cairo:MoveTo(self.x + self.width - self.padding - captionW, y + captionH)
    self.cairo:ShowText(caption)
    self.cairo:Stroke()

    y = y + 30
  end
end

return Research

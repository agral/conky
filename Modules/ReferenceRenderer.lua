local ReferenceRenderer = {
  SolarizedReference = "/home/simba/Tools/ToolsPictures/SolarizedCheatsheet-withbg.png",
  KorKeyboardReference = "/home/simba/Tools/ToolsPictures/KeyboardKorean.png",
}

setmetatable(ReferenceRenderer, {
  __index = ReferenceRenderer,
})

function ReferenceRenderer:Draw(params)
  assert(params.cairo)
  assert(params.pos and params.pos.x and params.pos.y)
  self.cairo = params.cairo

  if params.reference then
    self.referenceImg = self.cairo:ImageSurfaceCreateFromPng(params.reference)
    self.cairo:Save()
    self.width = self.cairo:ImageSurfaceGetWidth(self.referenceImg)
    self.height = self.cairo:ImageSurfaceGetHeight(self.referenceImg)
    self.cairo:SetSourceSurface(self.referenceImg, params.pos.x - self.width, params.pos.y - self.height)
    self.cairo:Paint()
    self.cairo:Restore()
    self.cairo:SurfaceDestroy(self.referenceImg)
    print(string.format("Ref img: %s x %s", self.width, self.height))
  end
end

return ReferenceRenderer

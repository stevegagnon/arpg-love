--[[
  NOTE: Some fonts may have incorrect outline rendering due to the author exporting it out poorly.
  To fix this, we can re-export the font using [bit font maker](http://www.pentacom.jp/pentacom/bitfontmaker2/editfont.php).
]]

local Component = require 'modules.component'
local groups = require 'components.groups'
local font = require 'components.font'
local f = require 'utils.functional'
local pixelOutlineShader = require 'modules.shaders.pixel-text-outline'

local textForMeasuringCache = {}
local function getTextForMeasuring(font)
  local textObject = textForMeasuringCache[font]
  if (not textObject) then
    textObject = love.graphics.newText(font, '')
    textForMeasuringCache[font] = textObject
  end
  return textObject
end

local GuiTextLayer = {
  group = groups.gui,
  font = font.secondary.font,
  outline = true,
  color = {1,1,1,1},

  -- statics
  getTextSize = function(text, font, wrapLimit, alignMode)
    local textForMeasuring = getTextForMeasuring(font)
    if (type(text) == 'table' or wrapLimit) then
      textForMeasuring:setf(
        text,
        wrapLimit or 99999,
        alignMode or 'left'
      )
    else
      textForMeasuring:set(text)
    end
    return textForMeasuring:getWidth(), textForMeasuring:getHeight()
  end
}

local floor = math.floor

function GuiTextLayer.add(self, text, color, x, y)
  self.tablePool[1] = color
  self.tablePool[2] = text
  self.textGraphic:add(self.tablePool, x, y)
end

function GuiTextLayer.addf(self, formattedText, wrapLimit, alignMode, x, y)
  self.textGraphic:addf(
    formattedText, -- [TABLE]
    wrapLimit,
    alignMode or 'left',
    x,
    y
  )
end

function GuiTextLayer.init(self)
  self.textGraphic = love.graphics.newText(self.font, '')
  self.tablePool = {}
end

function GuiTextLayer.getSize(self)
  return self.textGraphic:getWidth(), self.textGraphic:getHeight()
end

function GuiTextLayer.draw(self)
  local textWidth = self:getSize()
  local isEmpty = textWidth == 0

  if isEmpty then
    return
  end

  if self.outline then
    pixelOutlineShader.attach(nil, self.color[4])
  end

  love.graphics.setColor(self.color)
  love.graphics.draw(self.textGraphic)
  self.textGraphic:clear()

  if self.outline then
    pixelOutlineShader.detach()
  end
end

function GuiTextLayer.drawOrder()
  return 6
end

return Component.createFactory(GuiTextLayer)
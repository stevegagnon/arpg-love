-- local dynamicRequire = require 'utils.dynamic-require'
-- local Component = require 'modules.component'
-- local AnimationFactory = require 'components.animation-factory'
-- local GuiDialog = dynamicRequire 'components.gui.gui-dialog'
-- local GlobalState = require 'main.global-state'

-- local Quests = {
--   ['1-1'] = {
--     title = 'The Menace',
--     description = 'Find and kill *R-1 the Mad* in *Aureus-floor-2*',
--     condition = function()

--     end
--   }
-- }

-- local function drawShadow(self, sx, sy, ox, oy)
--   local sh = select(3, self.animation.sprite:getViewport())
--   local ox, oy = self.animation:getSourceOffset()
--   -- SHADOW
--   love.graphics.setColor(0,0,0,0.25)
--   self.animation:draw(
--     self.x,
--     self.y + sh/2,
--     0,
--     sx,
--     -1/4,
--     ox,
--     oy
--   )
-- end

-- local function makeDialog(self)
--   local characterName = GlobalState.gameState:get().characterName or ''
--   self.dialog = GuiDialog.create({
--     id = 'QuestMasterSpeechBubble',
--     x = self.x,
--     y = self.y - 30,
--     script = {
--       {
--         text = "Hi "..characterName.."! I'm Lisa, the quest master.",
--       },
--       {
--         text = "See you!"
--       }
--     }
--   }):setParent(self)
-- end

-- local QuestMaster = Component.createFactory({
--   init = function(self)
--     local parent = self
--     Component.addToGroup(self, 'all')
--     Component.addToGroup(self, 'npcs')

--     makeDialog(self)

--     self.animation = AnimationFactory:new({
--       'npc-quest-master/character-8',
--       'npc-quest-master/character-9',
--       'npc-quest-master/character-10',
--       'npc-quest-master/character-11'
--     }):setDuration(1.25)

--     local Gui = require 'components.gui.gui'
--     local width, height = self.animation:getWidth(), self.animation:getHeight()
--     self.interactNode = Gui.create({
--       group = 'all',
--       width = width,
--       height = height,
--       onUpdate = function(self)
--         self.x = parent.x - width/2
--         self.y = parent.y - height/2

--         local msgBus = require 'components.msg-bus'
--         local isInDialogue = self.hovered or
--           (parent.dialog and (not parent.dialog:isDeleted()))
--         msgBus.send('CURSOR_SET', {
--           type = isInDialogue and 'speech' or 'default'
--         })
--       end,
--       getMousePosition = function()
--         local camera = require 'components.camera'
--         return camera:getMousePosition()
--       end,
--       onClick = function()
--         makeDialog(parent)
--       end
--     }):setParent(parent)
--   end,
--   update = function(self, dt)
--     self.animation:update(dt)

--     local config = require 'config.config'
--     local gs = config.gridSize
--     -- self.x, self.y = (origin.x * gs) + obj.x,
--     --   (origin.y * gs) + obj.y
--   end,
--   draw = function(self)
--     drawShadow(self, 1, 1)

--     local Shaders = require 'modules.shaders'
--     local shader = Shaders('pixel-outline.fsh')

--     if self.interactNode.hovered then
--       local atlasData = AnimationFactory.atlasData
--       love.graphics.setShader(shader)
--       shader:send('sprite_size', {atlasData.meta.size.w, atlasData.meta.size.h})
--       shader:send('outline_width', 1)
--       local Color = require 'modules.color'
--       shader:send('outline_color', Color.WHITE)
--     end

--     love.graphics.setColor(1,1,1)
--     self.animation:draw(self.x, self.y)

--     shader:send('outline_width', 0)
--   end
-- })

-- Component.create({
--   id = 'QuestMasterExample',
--   group = 'all',
--   init = function()
--     QuestMaster.create({
--       id = 'QuestMaster',
--       x = 450,
--       y = 350
--     })
--   end,
--   update = function(self)
--   end
-- })
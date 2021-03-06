-- local dynamicRequire = require 'utils.dynamic-require'
-- local Component = require 'modules.component'
-- local AnimationFactory = require 'components.animation-factory'
-- local GuiDialog = dynamicRequire 'components.gui.gui-dialog'
-- local GlobalState = require 'main.global-state'
-- local msgBus = require 'components.msg-bus'
-- local Md = dynamicRequire 'modules.markdown-to-love2d-string'
-- local scriptRoutines = require 'components.quest-log.script-routines'
-- local Conversation = dynamicRequire 'repl.components.conversation'
-- local convos = dynamicRequire 'repl.shared.conversations'
-- local memoize = require 'utils.memoize'
-- dynamicRequire 'components.map-text'

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

-- local conversation = Conversation:new(convos)
-- conversation:setIfDifferent('something_lurking')

-- local function makeDialog(self)
--   local textPosition = {
--     x = self.x + 12,
--     y = self.y
--   }

--   local parseOptions = memoize(function(options)
--     local F = require 'utils.functional'
--     return F.map(options, function(o)
--       return o.label
--     end)
--   end)

--   self.dialog = GuiDialog.create({
--     id = 'QuestMasterSpeechBubble',
--     renderPosition = textPosition,
--     isDone = function()
--       return conversation:isDone()
--     end,
--     getText = function()
--       return conversation:get().text
--     end,
--     getOptions = function()
--       return parseOptions(conversation:get().options)
--     end,
--     onOptionSelect = function(optionNumber)
--       -- print('option ['..optionNumber..'] selected')
--       conversation:selectOption(optionNumber)
--     end,
--     onResume = function()
--       conversation:resume()
--     end,
--     onDone = function()
--       if conversation:is('cancel') then
--         conversation:set('something_lurking')
--       end
--     end,
--   }):setParent(self)
-- end

-- local Npc = Component.createFactory({
--   name = 'Npc name',
--   init = function(self)
--     local parent = self
--     Component.addToGroup(self, 'all')
--     Component.addToGroup(self, 'npcs')

--     self.animation = AnimationFactory:new({
--       'npc-quest-master/character-8',
--       'npc-quest-master/character-9',
--       'npc-quest-master/character-10',
--       'npc-quest-master/character-11'
--     }):setDuration(1.25)

--     local Gui = require 'components.gui.gui'
--     local width, height = self.animation:getWidth(), self.animation:getHeight()
--     local nameHeight = 12
--     self.interactNode = Gui.create({
--       group = 'all',
--       width = width,
--       height = height + nameHeight,
--       onUpdate = function(self)
--         self.x = parent.x - width/2
--         self.y = parent.y - height/2 - nameHeight

--         local msgBus = require 'components.msg-bus'
--         local isInDialogue = (parent.canInteract and self.hovered) or
--           (parent.dialog and (not parent.dialog:isDeleted()))
--         msgBus.send('CURSOR_SET', {
--           type = isInDialogue and 'speech' or 'default'
--         })

--         parent.canInteract = msgBus.send('INTERACT_ENVIRONMENT_OBJECT', self)
--       end,
--       getMousePosition = function()
--         local camera = require 'components.camera'
--         return camera:getMousePosition()
--       end,
--       onClick = function()
--         if parent.canInteract and parent.hasDialogue then
--           makeDialog(parent)
--         end
--       end,
--       render = function()
--         if parent.hasDialogue then
--           love.graphics.setColor(1,0.8,0)
--           AnimationFactory:newStaticSprite('gui-exclamation-mark')
--             :draw(parent.x, parent.y - 30)
--         end
--       end,
--       drawOrder = function()
--         local drawOrders = require 'modules.draw-orders'
--         return drawOrders.InteractableIndicator
--       end
--     }):setParent(parent)
--   end,
--   update = function(self, dt)
--     self.animation:update(dt)

--     local config = require 'config.config'
--     local gs = config.gridSize

--     local lightWorld = Component.get('lightWorld')
--     lightWorld:addLight(self.x, self.y, 20)

--     if self.canInteract then
--       Component.addToGroup(
--         Component.newId(),
--         'interactableIndicators', {
--           icon = 'cursor-speech',
--           x = self.x + self.interactNode.w,
--           y = self.y - 4
--         }
--       )
--     end

--     self.hasDialogue = not conversation:isDone()
--   end,
--   draw = function(self)
--     drawShadow(self, 1, 1)

--     Component.addToGroup(
--       Component.newId(),
--       'mapText',
--       {
--         text = self.name,
--         x = self.interactNode.x + self.interactNode.width/2,
--         y = self.interactNode.y,
--         align = 'center'
--       }
--     )

--     local Shaders = require 'modules.shaders'
--     local shader = Shaders('pixel-outline.fsh')

--     if self.interactNode.hovered then
--       local atlasData = AnimationFactory.atlasData
--       love.graphics.setShader(shader)
--       shader:send('sprite_size', {atlasData.meta.size.w, atlasData.meta.size.h})
--       shader:send('outline_width', 1)
--       local Color = require 'modules.color'
--       shader:send('outline_color', Color.YELLOW)
--     end

--     love.graphics.setColor(1,1,1)
--     self.animation:draw(self.x, self.y)

--     shader:send('outline_width', 0)
--   end
-- })

-- Component.create({
--   id = 'QuestMasterExample',
--   group = 'all',
--   init = function(self)
--     Npc.create({
--       id = 'QuestMaster',
--       name = 'Lisa',
--       x = 60,
--       y = 60
--     })
--   end,
--   update = function(self)
--   end
-- })
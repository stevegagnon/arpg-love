local Component = require 'modules.component'
local Gui = require 'components.gui.gui'
local MenuList2 = require 'components.gui.menu-list-2'
local GuiText = require 'components.gui.gui-text'
local msgBus = require 'components.msg-bus'
local msgBus = require 'components.msg-bus'
local Color = require 'modules.color'
local MenuManager = require 'modules.menu-manager'
local F = require 'utils.functional'
local Constants = require 'components.state.constants'
local getRect = require 'utils.rect'
local markdownToLove2d = require 'modules.markdown-to-love2d-string'
local Grid = require 'utils.grid'

local QuestLog = {
  width = 0,
  height = 0
}

local colors = {
  questTitle = {0,0.85,1},
  completed = Color.MED_GRAY
}

local calcCompleted = function(completeCount, task)
  return completeCount + (task.completed and 1 or 0)
end

local function layoutQuests(quests, wrapLimit, font)
  local questsList = F.reduce(F.keys(quests), function(list, questId)
    table.insert(list, quests[questId])
    return list
  end, {})
  local glyphs = Constants.glyphs
  local layout = F.reduce(questsList, function(layout, quest)
    local numTasks = #quest.subTasks
    local numTasksCompleted = F.reduce(quest.subTasks, calcCompleted, 0)
    local questCompleted = numTasks == numTasksCompleted
    local checkIcon = (questCompleted and glyphs.checkboxChecked or glyphs.checkbox)..' '
    local w,h = GuiText.getTextSize(checkIcon..quest.title, font, wrapLimit)
    table.insert(layout, {
      {
        text = {
          questCompleted and colors.completed or Color.WHITE,
          checkIcon,

          colors.questTitle,
          quest.title
        },
        type = 'questTitle',
        width = w,
        height = h,
        paddingTop = 8
      }
    })

    F.forEach(quest.subTasks, function(task)
      local paddingLeft = 10
      local parsedString = markdownToLove2d(task.description)
      local checkIcon = (task.completed and glyphs.checkboxChecked or glyphs.checkbox) .. ' '
      local w,h = GuiText.getTextSize(checkIcon..parsedString.plainText, font, wrapLimit - paddingLeft)
      local formattedString = parsedString.formatted
      table.insert(formattedString, 1, checkIcon)
      table.insert(formattedString, 1, task.completed and colors.completed or Color.WHITE)
      return table.insert(layout, {
        {
          text = formattedString,
          type = 'task',
          width = w,
          height = h,
          paddingTop = 1,
          paddingLeft = paddingLeft
        }
      })
    end)

    return layout
  end, {})
  local rect = getRect(layout)
  return rect
end

function QuestLog.init(self)
  Component.addToGroup(self, 'gui')
  Component.addToGroup(self, 'gameWorld')

  msgBus.send(msgBus.TOGGLE_MAIN_MENU, false)
  MenuManager.clearAll()
  MenuManager.push(self)

  local parent = self
  local bodyText = GuiText.create({
    font = require 'components.font'.primary.font
  }):setParent(self)
  self.bodyText = bodyText
  self.titleText = GuiText.create({
    font = require 'components.font'.secondary.font
  }):setParent(self)

  self.guiNodes = {
    {
      Gui.create({
        onPointerLeave = function(self)
          parent.hovered = false
        end,
        onPointerEnter = function(self)
          parent.hovered = true
        end,
        onUpdate = function(self)
          local EventLog = require 'modules.log-db.events-log'
          local log = EventLog.read(
            msgBus.send('GAME_STATE_GET'):getId()
          )

          local padding = 5
          local wrapLimit = parent.width - padding
          local titleText = {Color.SKY_BLUE, 'QUESTS'}
          parent.titleText:addf(titleText, wrapLimit, 'center', self.x + padding, self.y + padding)
          local titleWidth, titleHeight = parent.titleText:getSize()

          if (#F.keys(log.quests) > 0) then
            local offsetY = 16
            local rect = layoutQuests(log.quests, wrapLimit, bodyText.font)
            Grid.forEach(rect.childRects, function(layoutBlock, x, y)
              bodyText:addf(
                layoutBlock.colData.text,
                layoutBlock.width,
                'left',
                self.x + padding + layoutBlock.x,
                self.y + padding + offsetY + layoutBlock.y
              )
            end)
            self.width, self.height = math.max(titleWidth, rect.width),
              titleHeight + rect.height + offsetY
          end
        end
      })
    }
  }

  self.log = MenuList2.create({
    x = self.x,
    y = self.y,
    height = self.height,
    inputContext = 'any',
    layoutItems = self.guiNodes,
    otherItems = {
      bodyText,
      parent.titleText
    },
    autoWidth = false,
    drawOrder = function()
      return 2
    end
  }):setParent(self)
end

function QuestLog.update(self)
  -- self.log.height = self.height
  self.log.width = self.width
end

function QuestLog.draw(self)
  local opacity = 1
  local log = self.log
  local bw = 1
  local x, y, width, height = log.x - bw, log.y - bw, log.width + bw * 2, log.height + bw * 2
  local drawBox = require 'components.gui.utils.draw-box'
  drawBox(self)
end

function QuestLog.drawOrder(self)
  return self.log:drawOrder() - 1
end

function QuestLog.final(self)
  MenuManager.pop()
end

return Component.createFactory(QuestLog)
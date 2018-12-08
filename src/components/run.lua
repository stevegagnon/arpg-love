local config = require'config.config'
local msgBus = require'components.msg-bus'
local windowFocused = true

local paused = false

msgBus.PAUSE_GAME_TOGGLE = 'PAUSE_GAME_TOGGLE'
msgBus.on(msgBus.PAUSE_GAME_TOGGLE, function()
	paused = not paused
end)

function love.focus(focused)
  print('window '..(focused and 'focused' or 'unfocused'))
  windowFocused = focused
  msgBus.send(msgBus.WINDOW_FOCUS, {focused = focused})
end

function love.run()
	if love.load then love.load(love.arg.parseGameArguments(arg), arg) end

	-- We don't want the first frame's dt to include time taken by love.load.
	if love.timer then love.timer.step() end

	local dt = 0

	-- Main loop time.
	return function()
		local focused = windowFocused

		-- Process events.
		if love.event then
			love.event.pump()
			for name, a,b,c,d,e,f in love.event.poll() do
				if name == "quit" then
					if not love.quit or not love.quit() then
						return a or 0
					end
				end
				love.handlers[name](a,b,c,d,e,f)
			end
		end

		-- Update dt, as we'll be passing it to update
    if love.timer then
      dt = love.timer.step()
    end

		-- Call update and draw
		if love.update and (not paused) then
			love.update(dt)
    end -- will pass 0 if love.timer is disabled

		if love.graphics and love.graphics.isActive() then
			love.graphics.origin()
			love.graphics.clear(love.graphics.getBackgroundColor())

			if love.draw then love.draw() end

			love.graphics.present()
		end

		if love.timer then love.timer.sleep(0.001) end
	end
end
local Stats = {}
Stats.__index = Stats

--[[
  functional stats are calculated at the end but do not affect the base stats
]]

local readOnlyMt = {
  __newindex = function()
    error('read only')
  end
}

local EMPTY = setmetatable({}, readOnlyMt)

local statsMt = {
  __newindex = function(self, k, v)
    self.hasChanges = true
    self._stats[k] = v
  end
}

function statsMt.add(self, prop, value, context)
  local isFunction = type(value) == 'function'
  if isFunction then
    self._functionalStats[prop] = self._functionalStats[prop] or {}
    table.insert(self._functionalStats[prop], value)
    -- add 0 to add property to _stats list
    self[prop] = self[prop] + 0
  else
    self[prop] = self[prop] + value
  end
  return self
end

-- returns the fully calculated property
function statsMt.get(self, prop)
  local fStats = self._functionalStats[prop] or EMPTY
  local mTotal = 0 -- modifier total
  local baseValue = self[prop]
  for i=1, #fStats do
    mTotal = mTotal + fStats[i](self)
  end
  return baseValue + mTotal
end

local function eachCo(ctx)
  coroutine.yield()
  for k in pairs(ctx._stats) do
    coroutine.yield(k, ctx:get(k))
  end
  -- also iterate over initial stats to show any missing stats
  for k in pairs(ctx._initialStats) do
    if (nil == ctx._stats[k]) then
      coroutine.yield(k, ctx:get(k))
    end
  end
end

function statsMt.forEach(self)
  local co = coroutine.wrap(eachCo)
  co(self)
  return co
end

statsMt.__index = function(self, k)
  return statsMt[k] or self._stats[k] or self._initialStats[k] or 0
end

function Stats.new(self, initialStats)
  return setmetatable({
    _stats = {},
    _initialStats = initialStats or EMPTY,
    _functionalStats = {},
    hasChanges = false
  }, statsMt)
end

function Stats.is(value)
  return getmetatable(value) == Stats
end

return Stats
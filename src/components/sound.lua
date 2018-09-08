local Sound = {
  drinkPotion = love.audio.newSource('built/sounds/drink-potion.wav', 'static'),
  levelUp = love.audio.newSource('built/sounds/level-up.wav', 'static'),
  INVENTORY_PICKUP = love.audio.newSource('built/sounds/inventory-pickup.wav', 'static'),
  INVENTORY_DROP = love.audio.newSource('built/sounds/inventory-drop.wav', 'static'),
  PLASMA_SHOT = love.audio.newSource('built/sounds/plasma-shot.wav', 'static'),
  MOVE_SPEED_BOOST = love.audio.newSource('built/sounds/generic-spell-rush.wav', 'static'),
  LOW_HEALTH_WARNING = love.audio.newSource('built/sounds/low-health-warning.wav', 'static'),
  ACTION_ERROR = love.audio.newSource('built/sounds/action-error.wav', 'static'),
  ENEMY_IMPACT = love.audio.newSource('built/sounds/attack-impact-1.wav', 'static'),
  ENERGY_BEAM = love.audio.newSource('built/sounds/energy-beam-1.wav', 'static')
}

return Sound
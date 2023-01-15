local anim8 = require 'libraries/anim8'

local Entity = {}
Entity.__index = Entity

function Entity.new (x, y)
    local e = {
        x = x,
        y = y,
        currentAnimation = 1, -- animations are indices
        animations = {}, -- entity-specific animation data for each animation
    }

    local g = anim8.newGrid(Config.CharacterSize, Config.CharacterSize, Config.Charactersheet:getWidth(), Config.Charactersheet:getHeight())
    for id,data in ipairs(Config.CharacterAnimations) do
        -- create animations which automatically pause at the end. NOTE: this
        -- is distinctly different than the method `animation:pauseAtEnd` which
        -- causes the animation to move to the last frame and then pause.
        local animation = anim8.newAnimation(g(data.range, data.row), data.speed, "pauseAtEnd")
        e.animations[id] = animation
    end

    return setmetatable(e, Entity)
end

function Entity:draw (Viewport)
    local x, y = Viewport:worldToScreen(self.x, self.y)
    local animation = self.animations[self.currentAnimation]
    animation:draw(Config.Charactersheet, x, y)
end

function Entity:update (dt)
    local animation = self.animations[self.currentAnimation]
    if animation.status == "paused" then
        -- increment & rollover the counter
        self.currentAnimation = (self.currentAnimation % #Config.CharacterAnimations) + 1
        animation = self.animations[self.currentAnimation]
        -- animation pauses at end, so reset the frame to start and unpause it
        animation:gotoFrame(1)
        animation:resume()
    end
    animation:update(dt)
end

return Entity

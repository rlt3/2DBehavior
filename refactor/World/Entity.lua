local Box = require("Utils/Box")
local anim8 = require("Libraries/anim8")

local Entity = {}
Entity.__index = Entity

Entity.Template = {
    { key = "box", type = "Box" },
    { key = "speed", type = "Number" },
    { key = "animation", type = "Animation" },
    { key = "path", type = "Path" },
    { key = "isIdle", type = "Boolean" },
}

function Entity.new (x, y)
    local e = {
        box = Box.new(x, y, Config.CharacterSize),
        speed = 3,
        animation = "walkDown", -- animations are keyed on string names
        path = nil, -- path information represented as an array of nodes
        isIdle = true,

        -- entity-specific animation data for each animation
        animationIdx = {},
        pathIndex = 1,
        pathDt = 0,
    }

    local g = anim8.newGrid(Config.CharacterSize, Config.CharacterSize, Config.Charactersheet:getWidth(), Config.Charactersheet:getHeight())
    for i,data in ipairs(Config.CharacterAnimations) do
        -- create animations which automatically pause at the end. NOTE: this
        -- is distinctly different than the method `animation:pauseAtEnd` which
        -- causes the animation to move to the last frame and then pause.
        local animation = anim8.newAnimation(g(data.range, data.row), data.speed, "pauseAtEnd")
        e.animationIdx[data.name] = animation
    end

    return setmetatable(e, Entity)
end

function Entity:__tostring ()
    return "Entity @ " .. tostring(self.box)
end

function Entity:draw (Viewport)
    local x, y = Viewport:worldToScreen(self.box):position()
    local animation = self.animationIdx[self.animation]
    animation:draw(Config.Charactersheet, x, y)
end

function Entity:updateAnimation (dt)
    local animation = self.animationIdx[self.animation]
    -- use the last animation's sprite with no animating when idle
    if self.isIdle then
        animation:pause()
        animation:gotoFrame(1)
    elseif animation.status == "paused" then
        -- TODO: not used for anything currently, but allows us to control
        -- animation locking and waiting for animations to end before doing
        -- something else
        animation:gotoFrame(1)
        animation:resume()
    end
    animation:update(dt)
end

function Entity:update (dt)
    self:updatePath(dt)
    self:updateAnimation(dt)
end

function lerp (from, to, t)
    local x1, y1 = from.box:position()
    local x2, y2 = to.box:position()
    return {
        x = (1 - t) * x1 + t * x2,
        y = (1 - t) * y1 + t * y2,
    }
end

function Entity:hasPath ()
    return self.path ~= nil
end

function Entity:givePath (path)
    self.path = path
    self.pathIndex = 1
    self.pathDt = 0
    self.isIdle = false

    if #self.path == 0 or #self.path == 1 then
        error("Given invalid path of length " .. #self.path)
    end

    -- generate direction and animation information for the path at each node.
    -- we stop at n-1 because each iteration processes n and n+1
    for i = 1, #path - 1 do
        local node = path[i]
        local next = path[i + 1]
        local x1, y1 = next.box:position()
        local x2, y2 = node.box:position()
        local dir = { x = x1 - x2, y = y1 - y2 }

        if dir.x ~= 0 and dir.y ~= 0 then
            error("Expected cardinal directions")
        end

        if dir.x > 0 then
            node.dir = { x = 1, y = 0 }
            node.animation = "walkRight"
        elseif dir.x < 0 then
            node.dir = { x = -1, y = 0 }
            node.animation = "walkLeft"
        elseif dir.y > 0 then
            node.dir = { x = 0, y = 1 }
            node.animation = "walkDown"
        elseif dir.y < 0 then
            node.dir = { x = 0, y = -1 }
            node.animation = "walkUp"
        end
    end

    -- seed the initial movement
    self.animation = self.path[1].animation
end

function Entity:updatePath (dt)
    if not self.path then return end

    local node = self.path[self.pathIndex]

    -- we've hit the dest node. get the next node
    if self.pathDt >= 1.0 then
        self.pathDt = 0
        self.pathIndex = self.pathIndex + 1

        -- this only works in-between nodes, e.g. paths[3] 1->2, 2->3
        if self.pathIndex == #self.path then
            self.path = nil
            self.isIdle = true
            return
        end

        node = self.path[self.pathIndex]
        self.animation = node.animation
    end

    local next = self.path[self.pathIndex + 1]
    self.pathDt = self.pathDt + (self.speed * dt)

    -- lerping only works using the original start & goal nodes regardless of
    -- the entity's current position
    local pos = lerp(node, next, self.pathDt)
    self.box:setPosition(pos)
end

return Entity

local Map = require("World/Map")
local Environment = require("World/Environment")

local World = {}
World.__index = World

function World:init ()
    self.Map = Map
    self.Environment = Environment

    Map:init()
    Environment:init()
end

function World:pause ()
end

function World:resume ()
end

function World:update (dt)
end

function World:draw (Viewport)
    Map:draw(Viewport)
    Environment:draw(Viewport)
end

return setmetatable(World, World)

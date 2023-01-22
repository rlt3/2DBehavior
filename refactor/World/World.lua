local Map = require("World/Map")

local World = {}
World.__index = World

function World:init ()
    self.Map = Map

    Map:init()
end

function World:pause ()
end

function World:resume ()
end

function World:update (dt)
end

function World:draw (Viewport)
    Map:draw(Viewport)
end

return setmetatable(World, World)

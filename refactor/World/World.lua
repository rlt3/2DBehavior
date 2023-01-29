local Map = require("World/Map")
local Environment = require("World/Environment")
require("libraries/astar")

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
    Environment:update(dt)
end

function World:findPath (startTile, goalTile)
    local validNeighbor = function(node, neighbor)
        if not neighbor.isTraversable then
            return false
        end
        if node.box:distance(neighbor.box) > Config.TileSize then
            return false
        end
        return true
    end

    return astar.path(startTile, goalTile, Map.Tiles, true, validNeighbor)
end

function World:draw (Viewport)
    Map:draw(Viewport)
    Environment:draw(Viewport)
end

return setmetatable(World, World)

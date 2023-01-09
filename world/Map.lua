local Serializer = require("Serializer")
local Viewport = require("Viewport")
local Tile = require("Tile")

local MAP_FILE = "map.tiles"
local TILE_SIZE = 50
local MAP_WIDTH = 50
local MAP_HEIGHT = 50
local LEFT_MOUSE = 1
local RIGHT_MOUSE = 2

local Map = {
    TilesLookup = {}, -- used to lookup tiles by x/y coordinates
    Tiles = {}, -- holds all current tiles
}
Map.__index = Map

function Map:load ()
    if love.filesystem.getInfo(MAP_FILE) then
    -- Read the map contents from the map save file
        local contents, size = love.filesystem.read(MAP_FILE)
        local tiles, lookup = Serializer.deserializeN(contents, 2)
        self.Tiles = tiles
        self.TilesLookup = lookup
    else
    -- Or initialize an MxN map of tiles
        local width = love.graphics.getWidth()
        local height = love.graphics.getHeight()
        local id = 1
        for x = 0, (MAP_WIDTH * TILE_SIZE) - TILE_SIZE, TILE_SIZE do
            if self.TilesLookup[x] == nil then
                self.TilesLookup[x] = {}
            end
            for y = 0, (MAP_HEIGHT * TILE_SIZE) - TILE_SIZE, TILE_SIZE do
                local n = Tile.new(id, x, y, TILE_SIZE)
                table.insert(self.Tiles, n)
                self.TilesLookup[x][y] = n
                id = id + 1
            end
        end
    end
end

function Map:save ()
    local data = Serializer.serialize(self.Tiles, self.TilesLookup)
    local success, message = love.filesystem.write(MAP_FILE, data)
    if not success then 
        error("Map data could not be saved! " .. message)
    end
end

function Map:draw ()
    for i, node in ipairs(self.Tiles) do
        node:draw(Viewport)
    end
end

function Map:lookupTile (x, y)
    x, y = Viewport:screenToWorld(x, y)
    x = x - (x % TILE_SIZE)
    y = y - (y % TILE_SIZE)

    local n = self.TilesLookup[x][y]
    if n then
        print(n.id)
    end
end

function Map:mousepressed (x, y, button)
    if button == RIGHT_MOUSE then
        Viewport:dragStart()
    end
    if button == LEFT_MOUSE then
        Map:lookupTile(x, y)
    end
end

function Map:mousereleased (x, y, button)
    if button == RIGHT_MOUSE then
        Viewport:dragEnd()
    end
end

function Map:mousemoved (x, y, dx, dy)
    Viewport:mousemoved(x, y, dx, dy)
end

return Map

local Box = require("Utils/Box")
local Vector = require("Utils/Vector")
local Tile = require("World/Tile")

local Map = {}
Map.__index = Map

function Map:init (saveData)
    -- Instead of declaring our state in an initialized table, we do it here
    -- so that the `init` method can be called more than once

    -- used to lookup tiles by x,y coordinates
    self.TilesLookup = {}
    -- holds all current tiles
    self.Tiles = {}
    -- Batch of quads for batched drawing
    self.TilesetBatch = nil
    self.TileQuads = {}

    -- create the initial tiles
    self:create()

    -- create a single source of tile quads to draw as a batch
    local sz = Config.TileSize
    local w = Config.Tilesheet:getWidth()
    local h = Config.Tilesheet:getHeight()
    for i,template in ipairs(Config.Tiles) do
        self.TileQuads[template.tile] = love.graphics.newQuad(template.x, template.y, sz, sz, w, h)
    end
    self.TilesetBatch = love.graphics.newSpriteBatch(Config.Tilesheet, Config.TileSize * Config.TileSize)
end

function Map:create ()
    for x = 0, (Config.MapWidth * Config.TileSize) - Config.TileSize, Config.TileSize do
        if self.TilesLookup[x] == nil then
            self.TilesLookup[x] = {}
        end
        for y = 0, (Config.MapHeight * Config.TileSize) - Config.TileSize, Config.TileSize do
            local n = Tile.new(x, y, Config.TileSize)
            table.insert(self.Tiles, n)
            self.TilesLookup[x][y] = n
        end
    end
end

-- Using the existing Tile objects, load in the saved data. The saved data is
-- in a specific order that's maintained
function Map:load (data)
    if #self.Tiles ~= #data then
        error("Invalid length for map save data!")
    end
    for i,tile in ipairs(self.Tiles) do
        tile:deserialize(data[i])
    end
end

-- Serialize the map data ordered using ipairs
function Map:serialize ()
    local data = {}
    for i,t in ipairs(self.Tiles) do
        table.insert(data, t:serialize())
    end
    return data
end

function Map:draw (Viewport)
    self.TilesetBatch:clear()
    for i, tile in ipairs(self.Tiles) do
        if Viewport:isTileVisible(tile) then
            tile:draw(Viewport, self.TilesetBatch, self.TileQuads)
        end
    end
    self.TilesetBatch:flush()
    love.graphics.draw(self.TilesetBatch)
end

-- tiles are integer indexed at their top-left corner
local function toTileCoords (x, y)
    return x - (x % Config.TileSize),
           y - (y % Config.TileSize)
end

-- select a single tile
function Map:lookupTile (x, y)
    x, y = toTileCoords(x, y)

    if self.TilesLookup[x] == nil then
        return nil
    end

    local n = self.TilesLookup[x][y]

    if n then
        return n
    end

    return nil
end

-- select all tiles within a rectangle bounded by the vector coordinates
function Map:selectTiles (topleft, botright)
    local x1, y1 = toTileCoords(topleft.x, topleft.y)
    local x2, y2 = toTileCoords(botright.x, botright.y)

    local tiles = {}
    for x = x1, x2, Config.TileSize do
        if not self.TilesLookup[x] then
            goto continue
        end
        for y = y1, y2, Config.TileSize do
            local t = self.TilesLookup[x][y]
            if t then
                table.insert(tiles, t)
            end
        end
        ::continue::
    end

    return tiles
end

return setmetatable(Map, Map)

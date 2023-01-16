require("Config")
local Viewport = require("Viewport")
local Tile = require("Tile")

local LEFT_MOUSE = 1
local RIGHT_MOUSE = 2

local Map = {
    TilesLookup = {}, -- used to lookup tiles by x/y coordinates
    Tiles = {}, -- holds all current tiles
    SelectedTile = nil, -- currently selected tile
    OldSelected = nil, -- book keep for tracking selection changes
    TilesetBatch = nil,
    TileQuads = nil
}
Map.__index = Map

function Map:init (saveData)
    -- create or load the initial tiles
    if saveData then
        self:load(saveData)
    else
        self:create()
    end

    -- create a single source of tile quads to draw as a batch
    self.TileQuads = {}
    local sz = Config.TileSize
    local w = Config.Tilesheet:getWidth()
    local h = Config.Tilesheet:getHeight()
    for i,tile in ipairs(Config.Tiles) do
        self.TileQuads[tile.id] = love.graphics.newQuad(tile.x, tile.y, sz, sz, w, h)
    end
    self.TilesetBatch = love.graphics.newSpriteBatch(Config.Tilesheet, Config.TileSize * Config.TileSize)
end

function Map:create ()
    local id = 1
    for x = 0, (Config.MapWidth * Config.TileSize) - Config.TileSize, Config.TileSize do
        if self.TilesLookup[x] == nil then
            self.TilesLookup[x] = {}
        end
        for y = 0, (Config.MapHeight * Config.TileSize) - Config.TileSize, Config.TileSize do
            local n = Tile.new(id, x, y, Config.TileSize)
            table.insert(self.Tiles, n)
            self.TilesLookup[x][y] = n
            id = id + 1
        end
    end
end

function Map:load (saveData)
    local id = 1
    for i,tile in ipairs(saveData) do
        if self.TilesLookup[tile.x] == nil then
            self.TilesLookup[tile.x] = {}
        end

        local n = Tile.new(id, tile.x, tile.y, tile.size, tile.tile)
        table.insert(self.Tiles, n)
        self.TilesLookup[n.x][n.y] = n
        id = id + 1
    end
end

function Map:serialize ()
    local tiles = {}
    -- ipairs ensures order so if `id' ever becomes important...
    for i,t in ipairs(self.Tiles) do
        table.insert(tiles, t:serialize())
    end
    return tiles
end

function Map:isSelectionNew ()
    return self.SelectedTile ~= self.OldSelected
end

function Map:hasSelection ()
    return self.SelectedTile ~= nil
end

function Map:clearSelection ()
    self.SelectedTile = nil
end

function Map:drawSelection ()
    if self.SelectedTile == nil then
        error("No selection to draw!")
    end
    love.graphics.setColor(1, 0, 0, 1)
    local x = Viewport.x + self.SelectedTile.x
    local y = Viewport.y + self.SelectedTile.y
    love.graphics.line(x, y, x, y + Config.TileSize)
    love.graphics.line(x, y, x + Config.TileSize, y)
    love.graphics.line(x + Config.TileSize, y, x + Config.TileSize, y + Config.TileSize)
    love.graphics.line(x, y + Config.TileSize, x + Config.TileSize, y + Config.TileSize)
    love.graphics.setColor(1, 1, 1, 1)
end

function Map:draw ()
    self.TilesetBatch:clear()
    for i, tile in ipairs(self.Tiles) do
        if Viewport:isTileVisible(tile) then
            tile:draw(self.TilesetBatch, self.TileQuads, Viewport)
        end
    end
    self.TilesetBatch:flush()
    love.graphics.draw(self.TilesetBatch)
end

function Map:lookupTile (x, y)
    x, y = Viewport:screenToWorld(x, y)
    x = x - (x % Config.TileSize)
    y = y - (y % Config.TileSize)

    local n = self.TilesLookup[x][y]
    if n then
        return n
    end
    return nil
end

function Map:mousepressed (x, y, button)
    if button == RIGHT_MOUSE then
        Viewport:dragStart()
    end
    if button == LEFT_MOUSE then
        local n = Map:lookupTile(x, y)
        if n then
            self.OldSelected = self.SelectedTile
            self.SelectedTile = n
        end
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

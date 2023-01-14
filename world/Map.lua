require("Config")
local Serializer = require("Serializer")
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

function Map:init ()
    if love.filesystem.getInfo(Config.MapFile) then
        Map:load()
    else
        self:create()
    end

    self.TileQuads = {}
    local sz = Config.TileSize
    local w = Config.Spritesheet:getWidth()
    local h = Config.Spritesheet:getHeight()
    for i,tile in ipairs(Config.Tiles) do
        self.TileQuads[tile.id] = love.graphics.newQuad(tile.x, tile.y, sz, sz, w, h)
    end

    self.TilesetBatch = love.graphics.newSpriteBatch(Config.Spritesheet, Config.TileSize * Config.TileSize)
end

function Map:load ()
    local contents, size = love.filesystem.read(Config.MapFile)
    local tiles, lookup = Serializer.deserializeN(contents, 2)
    self.Tiles = tiles
    self.TilesLookup = lookup
end

function Map:create ()
    print(Config.TileSize)
    local width = love.graphics.getWidth()
    local height = love.graphics.getHeight()
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

function Map:save ()
    -- NOTE: This serializer copies deeply. Meaning it copies functions, etc.
    -- Ideally, we only want data here, not implementation. For example, I've
    -- changed the 'Tile:draw' method and because it was serialized, I was not
    -- able to see changes to it without loading from a forced-saved.
    local data = Serializer.serialize(self.Tiles, self.TilesLookup)
    local success, message = love.filesystem.write(Config.MapFile, data)
    if not success then 
        error("Map data could not be saved! " .. message)
    end
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

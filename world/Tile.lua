local Tile = {}
Tile.__index = Tile

function Tile.new (id, x, y, size, tile)
    local n = {
        id = id,
        x = x,
        y = y,
        size = size,
        tile = tile, -- can be nil
    }
    n = setmetatable(n, Tile)
    return n
end

function Tile:serialize ()
    return { x = self.x, y = self.y, size = self.size, tile = self.tile }
end

function Tile:draw (TilesetBatch, TileQuads, Viewport)
    local x, y = Viewport:worldToScreen(self.x, self.y)

    if self.tile then
        TilesetBatch:add(TileQuads[self.tile], x, y)
    else
        local size = self.size
        love.graphics.line(x, y, x, y + size)
        love.graphics.line(x, y, x + size, y)
        love.graphics.print(self.id, x, y + (size / 2), 0, 0.7)
    end
end

return Tile

local Tile = {}
Tile.__index = Tile

function Tile.new (id, x, y, size)
    local n = {
        id = id,
        x = x,
        y = y,
        size = size,
        isWalkable = false,
        tile = nil,
    }
    n = setmetatable(n, Tile)
    return n
end

function Tile.deserialize (t)
    return setmetatable(t, Tile)
end

function Tile:serialize ()
    return { id = self.id, x = self.x, y = self.y, size = self.size, isWalkable = self.isWalkable, tile = self.tile }
end

function Tile:__tostring ()
    return self.x .. ", " .. self.y .. " (" .. self.id .. ")"
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

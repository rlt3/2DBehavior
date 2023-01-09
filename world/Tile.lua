local Tile = {}
Tile.__index = Tile

function Tile.new (id, x, y, size)
    local n = {
        id = id,
        x = x,
        y = y,
        size = size
    }
    n = setmetatable(n, Tile)
    return n
end

function Tile:draw (Viewport)
    -- draw from the viewport's origin
    local x = Viewport.x + self.x
    local y = Viewport.y + self.y

    local size = self.size
    love.graphics.line(x, y, x, y + size)
    love.graphics.line(x, y, x + size, y)
    love.graphics.print(self.id, x + (size / 2), y + (size / 2), 0, 0.7)
end

return Tile

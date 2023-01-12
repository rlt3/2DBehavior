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
    local x, y = Viewport:translateOrigin(self.x, self.y)
    local size = self.size
    love.graphics.line(x, y, x, y + size)
    love.graphics.line(x, y, x + size, y)
    love.graphics.print(self.id, x, y + (size / 2), 0, 0.7)
end

return Tile

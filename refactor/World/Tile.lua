local Box = require("Utils/Box")

local Tile = {}
Tile.__index = Tile

Tile.Template = {
    { key = "box", type = "Box" },
    { key = "isTraversable", type = "Boolean" },
    { key = "tile", type = "Tile" },
}

function Tile.new (x, y, w, h)
    if not h then h = w end

    local t = {
        box = Box.new(x, y, w, h),
        isTraversable = true,
        tile = "none"
    }

    return setmetatable(t, Tile)
end

function Tile:serialize ()
    local t = {}
    for i,p in ipairs(Tile.Template) do
        t[p.key] = self[p.key]
    end
end

function Tile:deserialize (t)
    for i,p in ipairs(Tile.Template) do
        self[p.key] = t[p.key]
    end
end

function Tile:__tostring ()
    return self.box:__tostring() .. " [" .. self.tile .. "]"
end

function Tile:draw (Viewport, Batch, Quads)
    local box = Viewport:worldToScreen(self.box)
    local quad = Quads[self.tile]

    if quad then
        Batch:add(quad, box:position())
    else
        box:draw()
    end
end

return Tile


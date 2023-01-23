local Box = require("Utils/Box")

local Tile = {}
Tile.__index = Tile

function Tile.new (x, y, w, h)
    if not h then h = w end
    local t = {
        box = Box.new(x, y, w, h),
        isTraversable = true,
        tile = "none",

        isCool = false,
        anotherBox = Box.new(y, x, h, w),
        string1 = "foo",
        string2 = "bar",
        string3 = "baz",
    }
    return setmetatable(t, Tile)
end

function Tile:deserialize (t)
    return setmetatable(t, Tile)
end

function Tile:serialize ()
    return { box = self.box, isTraversable = self.isTraversable, tile = self.tile }
end

function Tile:__tostring ()
    return self.box:__tostring() .. " [" .. self.tile .. "]"
end

function Tile:draw (Viewport, Batch, Quads)
    local box = Viewport:worldToScreen(self.box)

    if self.tile == "none" then
        box:draw()
    else
        Batch:add(Quads[self.tile], box:position())
    end
end

return Tile


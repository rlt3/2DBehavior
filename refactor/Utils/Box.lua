local Vector = require("Utils/Vector")
local Box = {}
Box.__index = Box

local function isBox (t)
    return getmetatable(t) == Box
end

function Box.new (x, y, w, h)
    if not h then h = w end
    local t = {
        pos = Vector.new(x, y),
        w = w,
        h = h
    }
    return setmetatable(t, Box)
end

function Box:copy ()
    return Box.new(self.pos.x, self.pos.y, self.w, self.h)
end

function Box:addPosition (dx, dy)
    self.pos.x = self.pos.x + dx
    self.pos.y = self.pos.y + dy
end

function Box:position ()
    return self.pos.x, self.pos.y
end

function Box:isPointInside (x, y)
    return self.pos.x <= x
       and self.pos.y <= y
       and self.pos.x + self.w >= x
       and self.pos.y + self.h >= y
end

function Box:intersects (other)
    assert(isBox(self) and isBox(other), "Type mismatch: Box expected.")
    return self.pos.x < other.pos.x + other.w
       and self.pos.x + self.w > other.pos.x
       and self.pos.y < other.pos.y + other.h
       and self.pos.y + self.h > other.pos.y
end

function Box:draw (Viewport)
    local x, y = Viewport:worldToScreen(self):position()
    local w, h = self.w, self.h
    love.graphics.line(x, y, x, y + h)
    love.graphics.line(x, y, x + w, y)
    love.graphics.line(x + w, y, x + w, y + h)
    love.graphics.line(x, y + h, x + w, y + h)
end

function Box:__tostring()
    return "Box("..self.pos.x..", "..self.pos.y..", "..self.w..", "..self.h..")"
end

return Box

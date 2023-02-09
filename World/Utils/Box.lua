local Vector = require("Utils/Vector")

local Box = {}
Box.__index = Box

function isBox (t)
    return type(t) == "table" and getmetatable(t) == Box
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

function Box:serialize ()
    return { x = self.pos.x, y = self.pos.y, w = self.w, h = self.h }
end

function Box:copy ()
    return Box.new(self.pos.x, self.pos.y, self.w, self.h)
end

function Box:setPosition (pos)
    self.pos.x = pos.x
    self.pos.y = pos.y
end

function Box:position ()
    return self.pos.x, self.pos.y
end

function Box:rect ()
    return {
        x1 = self.pos.x,
        y1 = self.pos.y,
        x2 = self.pos.x + self.w,
        y2 = self.pos.y + self.h,
    }
end

function Box:isPointInside (x, y)
    local r = self:rect()
    return r.x1 <= x
       and r.y1 <= y
       and r.x2 >= x
       and r.y2 >= y
end

function Box:distance (other)
    return Vector.distance(self.pos, other.pos)
end

function Box:intersects (other)
    assert(isBox(self) and isBox(other), "Type mismatch: Box expected.")

    local a = self:rect()
    local b = other:rect()

    return a.x1 < b.x2
       and a.x2 > b.x1
       and a.y1 < b.y2
       and a.y2 > b.y1
end

function Box:draw (x, y)
    local r = self:rect()
    love.graphics.polygon("line", r.x1,r.y1, r.x2,r.y1, r.x2,r.y2, r.x1,r.y2)
end

function Box:__tostring ()
    return "Box("..self.pos.x..", "..self.pos.y..", "..self.pos.x + self.w..", "..self.pos.y + self.h..")"
end

return Box

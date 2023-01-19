local Bounds = {}
Bounds.__index = Bounds

function Bounds.new (x, y, w, h)
    if not h then h = w end
    return setmetatable({
        x = x,
        y = y,
        w = w,
        h = h,
    }, Bounds)
end

function Bounds:setPosition (pos)
    self.x = pos.x
    self.y = pos.y
end

function Bounds:position ()
    return self.x, self.y
end

function Bounds:isPointInside (x, y)
    return self.x <= x
       and self.y <= y
       and self.x + self.w >= x
       and self.y + self.h >= y
end

function Bounds:draw (Viewport)
    local x, y = Viewport:worldToScreen(self:position())
    local w, h = self.w, self.h
    love.graphics.line(x, y, x, y + h)
    love.graphics.line(x, y, x + w, y)
    love.graphics.line(x + w, y, x + w, y + h)
    love.graphics.line(x, y + h, x + w, y + h)
    love.graphics.setColor(1, 1, 1, 1)
end

return Bounds

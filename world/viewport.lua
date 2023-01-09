-- The viewport initially has its origin at 0,0. Dragging the viewport is
-- simply a matter of changing the origin and thus drawing all drawables at
-- an offset

local Viewport = {
    x = 0,
    y = 0,
    width = love.graphics.getWidth(),
    height = love.graphics.getHeight(),
    isDragging = false
}
Viewport.__index = Viewport

function Viewport:dragStart ()
    self.isDragging = true
end

function Viewport:dragEnd ()
    self.isDragging = false
end

-- Convert screen coordinates to world coordinates
function Viewport:screenToWorld (x, y)
    return x - Viewport.x, y - Viewport.y
end

function Viewport:mousemoved (x, y, dx, dy)
    if self.isDragging then
        self.x = self.x + dx
        self.y = self.y + dy
    end
end

function Viewport:resize ()
    error("TODO: Viewport:resize")
end

return Viewport

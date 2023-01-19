local Vector = require("Utils/Vector")
local Box = require("Utils/Box")

-- The viewport initially has its origin at 0,0. Dragging the viewport is
-- simply a matter of changing the origin and thus drawing all drawables at
-- an offset

local function resetScreenBox ()
    return Box.new(0, 0, love.graphics.getWidth(), love.graphics.getHeight())
end

local Viewport = {
    origin = Vector.new(0, 0),
    screen = resetScreenBox(),
    isDragging = false,
}
Viewport.__index = Viewport

function Viewport:resize ()
    self.screen = resetScreenBox()
end

function Viewport:dragStart ()
    self.isDragging = true
end

function Viewport:dragEnd ()
    self.isDragging = false
end

function Viewport:screenToWorld (box)
    local origin = self.origin
    local x, y = box:position()
    return Box.new(x - origin.x, y - origin.y, box.w, box.h)
end

function Viewport:worldToScreen (box)
    local origin = self.origin
    local x, y = box:position()
    return Box.new(origin.x + x, origin.y + y, box.w, box.h)
end

function Viewport:isTileVisible (tile)
    local box = self:worldToScreen(tile.box)
    local r = box:intersects(self.screen)
    if not r then
        print(box, self.screen)
    end
    return r
    --return box:intersects(self.screen)
end

function Viewport:mousemoved (x, y, dx, dy)
    if self.isDragging then
        self.origin.x = self.origin.x + dx
        self.origin.y = self.origin.y + dy
    end
end

return Viewport

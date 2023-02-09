--
-- Viewport owns a vector which is the new origin from which the World's
-- drawables will be drawn. Middle-clicking allows the user to move this origin
-- around to see different parts of the World.
--
-- The Viewport also owns a Box which is the size of the screen. Using
-- coordinates from the new origin, World objects are checked whether their Box
-- and the screen's Box intersect and should be drawn.
--

local Vector = require("Utils/Vector")
local Box = require("Utils/Box")

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
    return Box.new(x + origin.x, y + origin.y, box.w, box.h)
end

function Viewport:isTileVisible (tile)
    local box = self:worldToScreen(tile.box)
    return self.screen:intersects(box)
end

function Viewport:mousemoved (x, y, dx, dy)
    if self.isDragging then
        self.origin.x = self.origin.x + dx
        self.origin.y = self.origin.y + dy
    end
end

return Viewport

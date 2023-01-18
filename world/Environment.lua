local Viewport = require("Viewport")

local Environment = {}
Environment.__index = Environment

function Environment:init ()
    self.Entities = {}
    self.selected = nil
end

function Environment:hasSelection ()
    return self.selected ~= nil
end

function Environment:drawSelection (Viewport)
    self.selected.bounds:draw(Viewport)
end

function Environment:clearSelection ()
    self.selected = nil
end

function Environment:add (entity)
    table.insert(self.Entities, entity)
end

function Environment:mousepressed (x, y, button)
    if button ~= 1 then return end
    local x, y = Viewport:screenToWorld(x, y) 
    for i,e in ipairs(self.Entities) do
        if e.bounds:isPointInside(x, y) then
            self.selected = e
        end
    end
    print(self.selected)
end

function Environment:mousereleased (x, y, button)
    if button == 1 then
        self.selected = nil
    end
end

function Environment:draw (Viewport)
    for i,entity in ipairs(self.Entities) do
        entity:draw(Viewport)
    end
end

function Environment:update (dt)
    for i,entity in ipairs(self.Entities) do
        entity:update(dt)
    end
end

return Environment

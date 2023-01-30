local Environment = {}
Environment.__index = Environment

function Environment:init ()
    self.Entities = {}
end

function Environment:add (entity)
    table.insert(self.Entities, entity)
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

function Environment:lookupEntity (x, y)
    for i,entity in ipairs(self.Entities) do
        if entity.box:isPointInside(x, y) then
            return entity
        end
    end
    return nil
end

return Environment

local Entity = require("World/Entity")

local Environment = {}
Environment.__index = Environment

function Environment:init ()
    self.Entities = {}
end

-- create base Entities and then load the data into them
function Environment:load (data)
    for i,d in ipairs(data) do
        local entity = Entity.new(0, 0)
        entity:deserialize(d)
        table.insert(self.Entities, entity)
    end
end

function Environment:serialize ()
    local data = {}
    for i,e in ipairs(self.Entities) do
        table.insert(data, e:serialize())
    end
    return data
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

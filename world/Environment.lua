local Environment = {
    Entities = {}
}
Environment.__index = Environment

function Environment:init ()
end

function Environment:map ()
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

return Environment

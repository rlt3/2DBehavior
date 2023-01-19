local World = {}
World.__index = World

function World:pause ()
end

function World:resume ()
end

function World:update (dt)
end

return setmetatable(World, World)

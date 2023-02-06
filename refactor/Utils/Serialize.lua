--
-- Different from the serialization library, this simply provides utility
-- functions for serializing/deserializing common pieces of data in this
-- application.
--

local Box = require("Utils/Box")

function Serialize (obj, template)
    local data = {}
    for i,p in ipairs(template) do
        if p.type == "Box" then
            data[p.key] = obj[p.key]:serialize()
        else
            data[p.key] = obj[p.key]
        end
    end
    return data
end

function Deserialize (obj, data, template)
    for i,p in ipairs(template) do
        if p.type == "Box" then
            local b = data[p.key]
            obj[p.key] = Box.new(b.x, b.y, b.w, b.h)
        else
            obj[p.key] = data[p.key]
        end
    end
end

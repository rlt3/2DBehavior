local nativefs = require("libraries/nativefs")

-- 
-- Persists a small Lua table of values which can change during the program's
-- runtime. These values are customizations and comfort choices, thus the
-- reason they are automatically handled.
--

local ini = {
    state = {
        -- TODO: ideally this would be a relative path from getSaveDirectory
        -- or perhaps getWorkingDirectory
        SaveFile = love.filesystem.getSaveDirectory() .. "/world.save",
    },
    name = "persist",
    file = love.filesystem.getSaveDirectory() .. "/persist.lua",
}
ini.__index = ini

function ini:__index (key)
    return self.state[key]
end

function ini:__newindex (key, v)
    self.state[key] = v
end

function ini:exists ()
    return nativefs.getInfo(self.file)
end

function ini:save ()
    local data = self:serialize()
    print(data)
    success, message = nativefs.write(self.file, data)
    if not success then
        error("ini.lua was not saved! " .. message)
    end
end

-- serializes as a lua table
function ini:serialize ()
    local s = "return {\n"
    for k,v in pairs(self.state) do
        if type(v) ~= "string" then
            error("Only string values are allowed in the ini file")
        end
        -- because this is a path, we must escape properly
        local value = string.gsub(v, "\\", "\\\\")
        s = s .. "    " .. k .. " = \"" .. value .. "\",\n"
    end
    local s = s .. "}"
    return s
end

-- reloading is as simple as interpreting that lua table
function ini:reload ()
    print("Loading the ini values from: " .. self.file)
    self.state = require(self.name)
end


return setmetatable(ini, ini)

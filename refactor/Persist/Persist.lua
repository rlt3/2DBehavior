local binser = require("libraries/binser")
local nativefs = require("libraries/nativefs")

local Persist = {
}
Persist.__index = Persist

function Persist:save (World)
    ---- NOTE: This serializer copies deeply. Meaning it copies functions, etc.
    ---- We only want data here, not implementation. This is why each component
    ---- has a `serialize` method.
    local data = binser.serialize(World.Map:serialize(), World.Environment:serialize())
    local success, message = nativefs.write(Config.SaveFile, data)
    if not success then
        error("Save data was not saved! " .. message)
    end
end

function Persist:load (World)
    if nativefs.getInfo(Config.SaveFile) then
        print("Loading world data from: " .. Config.SaveFile)
        local data, size = nativefs.read(Config.SaveFile)
        -- read data back in the same order we wrote it
        local mapdata, envdata = binser.deserializeN(data, 2)
        World.Map:load(mapdata)
        World.Environment:load(envdata)
    else
        print("Could not find save data at: " .. Config.SaveFile)
    end
end

return Persist

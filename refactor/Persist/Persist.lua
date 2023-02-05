local binser = require("libraries/binser")
local nativefs = require("libraries/nativefs")

local Persist = {
}
Persist.__index = Persist

function Persist:save (World)
    ---- NOTE: This serializer copies deeply. Meaning it copies functions, etc.
    ---- We only want data here, not implementation. This is why each component
    ---- has a `serialize` method.
    local data = binser.serialize(World.Map:serialize())
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
        World.Map:load(binser.deserializeN(data, 1))
    end
end

return Persist

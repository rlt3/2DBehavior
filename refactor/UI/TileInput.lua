local StringInput = require('UI/StringInput')

local ffi = require('ffi')

local STRLEN = 64
local TileInput = {
    buf = ffi.new("char[?]", STRLEN),
}
TileInput.__index = TileInput

function TileInput:draw (selected, allowInput, k, v)
    StringInput:draw(selected, allowInput, k, v)

    --imgui.NewLine()
    --if imgui.Button("Clear") then
    --    selected.tile = "none"
    --end
end

return setmetatable(TileInput, TileInput)

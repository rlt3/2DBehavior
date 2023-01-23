local ffi = require('ffi')

local BooleanMenuInput = {}
BooleanMenuInput.__index = BooleanMenuInput

function BooleanMenuInput.new ()
    return setmetatable({
        selected = ffi.new("bool[1]", false),
    }, BooleanMenuInput)
end


function BooleanMenuInput:draw (selected, k, v)
    self.selected[0] = v
    if imgui.Checkbox(k, self.selected) then
        selected[k] = not v
    end
end

return BooleanMenuInput


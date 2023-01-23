local ffi = require('ffi')

local BooleanMenuInput = {}
BooleanMenuInput.__index = BooleanMenuInput

function BooleanMenuInput.new ()
    local t = {
        buf = ffi.new("bool[1]", false)
    }
    return setmetatable(t, BooleanMenuInput)
end

function BooleanMenuInput:draw (selected, k, v)
    self.buf[0] = v
    if imgui.Checkbox(k, self.buf) then
        selected[k] = not v
    end
end

return BooleanMenuInput


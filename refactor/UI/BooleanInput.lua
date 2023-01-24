local ffi = require('ffi')

local BooleanInput = {
    buf = ffi.new("bool[1]", false)
}
BooleanInput.__index = BooleanInput

function BooleanInput:draw (selected, k, v)
    self.buf[0] = v
    if imgui.Checkbox(k, self.buf) then
        selected[k] = not v
    end
end

return setmetatable(BooleanInput, BooleanInput)


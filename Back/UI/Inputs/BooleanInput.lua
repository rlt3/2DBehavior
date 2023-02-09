local ffi = require('ffi')

local BooleanInput = {
    buf = ffi.new("bool[1]", false)
}
BooleanInput.__index = BooleanInput

function BooleanInput:draw (selected, allowInput, k, v)
    self.buf[0] = v
    if imgui.Checkbox(k, self.buf) then
        if allowInput then
            selected[k] = not v
        end
    end
end

return setmetatable(BooleanInput, BooleanInput)


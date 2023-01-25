local ffi = require("ffi")

local MAXSTRLEN = 64
local StringInput = {
    buf = ffi.new("char[?]", MAXSTRLEN) -- zero initialized
}
StringInput.__index = StringInput

function StringInput:draw (selected, allowInput, k, v)
    local flags = imgui.ImGuiInputTextFlags_AutoSelectAll

    ffi.copy(self.buf, v, MAXSTRLEN)
    if imgui.InputText(k, self.buf, MAXSTRLEN, flags) then
        if allowInput then
            selected[k] = ffi.string(self.buf)
        end
    end
end

return setmetatable(StringInput, StringInput)

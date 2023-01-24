local ffi = require("ffi")

local MAXSTRLEN = 64
local StringInput = {
    buf = ffi.new("char[?]", MAXSTRLEN) -- zero initialized
}
StringInput.__index = StringInput

function StringInput:draw (selected, k, v)
    local flags = imgui.ImGuiInputTextFlags_AutoSelectAll
    local callback = ffi.cast("ImGuiInputTextCallback", allowInteger)

    ffi.copy(self.buf, v, MAXSTRLEN)
    if imgui.InputText(k, self.buf, MAXSTRLEN, flags) then
        selected[k] = ffi.string(self.buf)
    end
end

return setmetatable(StringInput, StringInput)

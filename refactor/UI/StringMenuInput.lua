local ffi = require("ffi")

local StringMenuInput = {}
StringMenuInput.__index = StringMenuInput

local MAXSTRLEN = 64

function StringMenuInput.new ()
    local t = {
        buf = ffi.new("char[?]", MAXSTRLEN) -- zero initialized
    }
    return setmetatable(t, StringMenuInput)
end

function StringMenuInput:draw (selected, k, v)
    local flags = imgui.ImGuiInputTextFlags_AutoSelectAll
    local callback = ffi.cast("ImGuiInputTextCallback", allowInteger)

    ffi.copy(self.buf, v, MAXSTRLEN)
    if imgui.InputText(k, self.buf, MAXSTRLEN, flags) then
        selected[k] = ffi.string(self.buf)
    end
end

return StringMenuInput

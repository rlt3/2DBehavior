local Box = require('Utils/Box')
local ffi = require('ffi')

local NUMBYTES = 8
local BoxInput = {
    xbuf = ffi.new("char[?]", NUMBYTES),
    ybuf = ffi.new("char[?]", NUMBYTES)
}
BoxInput.__index = BoxInput

-- expects that ImGuiInputTextFlags_CharsDecimal has been passed
local function allowInteger (data)
    local c = string.char(data.EventChar)

    --
    -- TODO: handle negative values
    --

    local filter = {
        '.', '+', '/', '*'
    }
    for i,bad in ipairs(filter) do
        if c == bad then
            return 1
        end
    end

    return 0
end

local function updateSelected (selected, k, v, coord, value)
    if not value then return end
    selected[k].pos[coord] = value
end

function BoxInput:draw (selected, k, v)
    local flags = imgui.ImGuiInputTextFlags_CallbackCharFilter
                + imgui.ImGuiInputTextFlags_CharsDecimal
                + imgui.ImGuiInputTextFlags_AutoSelectAll
                + imgui.ImGuiInputTextFlags_CharsNoBlank

    --
    -- TODO: Moving a Box's position doesn't update the Map's lookup table.
    --

    local callback = ffi.cast("ImGuiInputTextCallback", allowInteger)
    ffi.copy(self.xbuf, tostring(selected[k].pos.x))
    ffi.copy(self.ybuf, tostring(selected[k].pos.y))
    if imgui.InputText(k..".pos.x", self.xbuf, NUMBYTES, flags, callback) then
        updateSelected(selected, k, v, "x", tonumber(ffi.string(self.xbuf)))
    end
    if imgui.InputText(k..".pos.y", self.ybuf, NUMBYTES, flags, callback) then
        updateSelected(selected, k, v, "y", tonumber(ffi.string(self.ybuf)))
    end
    callback:free()
end

return setmetatable(BoxInput, BoxInput)

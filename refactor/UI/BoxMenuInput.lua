local Box = require('Utils/Box')
local ffi = require('ffi')

local BoxMenuInput = {}
BoxMenuInput.__index = BoxMenuInput

local NUMBYTES = 8

-- expects that ImGuiInputTextFlags_CharsDecimal has been passed
local function allowInteger (data)
    local c = string.char(data.EventChar)
    local buf = ffi.cast("char*", data.UserData)
    local str = ffi.string(buf)

    -- TODO: handle negative values

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

function BoxMenuInput.new ()
    return setmetatable({
        -- both are zero-initialized
        xbuf = ffi.new("char[?]", NUMBYTES),
        ybuf = ffi.new("char[?]", NUMBYTES)
    }, BoxMenuInput)
end

local function updateSelected (buf, selected, key, value)
    if not value then return end
    selected.box.pos[key] = value
end

function BoxMenuInput:draw (selected)
    imgui.Text("Box:")
    imgui.NewLine()
    local flags = imgui.ImGuiInputTextFlags_CallbackCharFilter
                + imgui.ImGuiInputTextFlags_CharsDecimal
                + imgui.ImGuiInputTextFlags_AutoSelectAll
                + imgui.ImGuiInputTextFlags_CharsNoBlank
    local callback = ffi.cast("ImGuiInputTextCallback", allowInteger)

    ffi.copy(self.xbuf, tostring(selected.box.pos.x))
    ffi.copy(self.ybuf, tostring(selected.box.pos.y))

    if imgui.InputText("x", self.xbuf, NUMBYTES, flags, callback, self.xbuf) then
        updateSelected(self.xbuf, selected, "x", tonumber(ffi.string(self.xbuf)))
    end

    if imgui.InputText("y", self.ybuf, NUMBYTES, flags, callback, self.ybuf) then
        updateSelected(self.ybuf, selected, "y", tonumber(ffi.string(self.ybuf)))
    end

    callback:free()
end

return BoxMenuInput

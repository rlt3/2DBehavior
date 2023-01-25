local StringInput = require('UI/Inputs/StringInput')

local ffi = require('ffi')

local STRLEN = 64
local TileInput = {
    buf = ffi.new("char[?]", STRLEN),
}
TileInput.__index = TileInput

function TileInput:draw (selected, allowInput, k, v)
    local isUpdated = false

    StringInput:draw(selected, allowInput, k, v)

    local red = imgui.ImVec4_Float(0, 1, 0, 1)
    local black = imgui.ImVec4_Float(0, 0, 0, 0)
    local green = imgui.ImVec4_Float(0, 1, 0, 1)
    local white = imgui.ImVec4_Float(1, 1, 1, 1)
    local dim = imgui.ImVec2_Float(Config.Tilesheet:getDimensions())

    for i, tile in ipairs(Config.Tiles) do
        -- size of the button
        local size = imgui.ImVec2_Float(Config.TileSize, Config.TileSize)
        -- top-left coordinates, divided by dimensions to force range [0, 1]
        local uv0 = imgui.ImVec2_Float(tile.x / dim.x, tile.y / dim.y)
        -- bot-right coordinates, divided, again, to force range into [0, 1]
        local uv1 = imgui.ImVec2_Float((tile.x + Config.TileSize) / dim.x, (tile.y + Config.TileSize) / dim.y)
        -- Black background
        local bg_col = imgui.ImVec4_Float(0, 0, 0, 1)
        -- No tint
        local tint_col = imgui.ImVec4_Float(1, 1, 1, 1)

        imgui.PushID_Str(tile.id)
        if tile.id == selected.tile then
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, green)
        else
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, black)
        end
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonActive, green)
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonHovered, white)

        if imgui.ImageButton(tile.id, Config.Tilesheet, size, uv0, uv1, bg_col, tint_col) then
            if allowInput then
                isUpdated = true
                selected[k] = tile.id
                --
                -- TODO: not using k,v pair here
                --
                selected.isTraversable = tile.isTraversable
            end
        end

        imgui.PopStyleColor(3)
        imgui.PopID()
        imgui.SameLine()
    end

    imgui.NewLine()
    if imgui.Button("Clear Tile") then
        isUpdated = true
        selected.tile = "none"
        selected.isTraversable = true
    end

    return isUpdated
end

return setmetatable(TileInput, TileInput)

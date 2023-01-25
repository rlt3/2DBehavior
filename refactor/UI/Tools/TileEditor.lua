local Vector = require("Utils/Vector")
local Tile = require("World/Tile")
local TileInput = require("UI/Inputs/TileInput")

local TileEditor = {
    name = "Tile Editor",
}
TileEditor.__index = TileEditor

-- holds the master values applied to sets of tiles
local master = {
    tile = "none"
}

function drawMenu ()
    local pos  = imgui.ImVec2_Float(0, 0)
    local size = imgui.ImVec2_Float(400, 300)
    -- allow the window to be moved wherever and have it remember that position
    -- but always set the size and it cannot be resized
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_FirstUseEver)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Tile Editor Menu", nil, flags)

    TileInput:draw(master, true, "tile", master.tile)

    imgui.NewLine()
    if imgui.Button("Select & Fill Mode") then
        print("fill")
    end

    if imgui.Button("Paintbrush Mode") then
        print("paintbrush")
    end

    imgui.End()
end

local initial = nil

function drawSelectionBox ()
    if imgui.love.GetWantCaptureMouse() then return end

    if imgui.IsMouseClicked(imgui.ImGuiMouseButton_Left) then
        -- we must create a copy of the values here because it seems the
        -- object from GetMousePos is a reference that gets corrupted/updated
        local pos = imgui.GetMousePos()
        initial = imgui.ImVec2_Float(pos.x, pos.y)
    end
    if initial and imgui.IsMouseDown(imgui.ImGuiMouseButton_Left) then
        local a = initial
        local b = imgui.GetMousePos()

        drawList = imgui.GetBackgroundDrawList_Nil()
        drawList:AddRect(a, b, imgui.GetColorU32_Vec4(imgui.ImVec4_Float(0, 0.51, 0.84, 1.0)))
        drawList:AddRectFilled(a, b, imgui.GetColorU32_Vec4(imgui.ImVec4_Float(0, 0.51, 0.84, 0.20)))
    end
    if imgui.IsMouseReleased(imgui.ImGuiMouseButton_Left) then
        initial = nil
    end
end

function TileEditor:draw ()
    drawSelectionBox()
    drawMenu()
end

return setmetatable(TileEditor, TileEditor)

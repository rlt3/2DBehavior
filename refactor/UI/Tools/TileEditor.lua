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

function TileEditor:draw ()
    drawMenu()
end

return setmetatable(TileEditor, TileEditor)

local ffi = require('ffi')

local TilesMenu = {
    isOpen = ffi.new("bool[1]", true),
    selected = "grass1",
}
TilesMenu.__index = TilesMenu

local function beginWindow (imgui)
    local pos  = imgui.ImVec2_Float(0, 0)
    local size = imgui.ImVec2_Float(400, 300)
    -- allow the window to be moved wherever and have it remember that position
    -- but always set the size and it cannot be resized
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_Once)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Tile Menu", TilesMenu.isOpen, flags)
end

local function endWindow (imgui)
    imgui.End()
end

local selection = "none"

function TilesMenu:draw (imgui)
    beginWindow(imgui)

    local red = imgui.ImVec4_Float(0, 1, 0, 1)
    local black = imgui.ImVec4_Float(0, 0, 0, 0)
    local green = imgui.ImVec4_Float(0, 1, 0, 1)
    local white = imgui.ImVec4_Float(1, 1, 1, 1)
    local dim = imgui.ImVec2_Float(Config.Tilesheet:getDimensions())

    -- TODO: Just hard-code the data that needs to be displayed and how to
    -- update it. tile.name, tile.box, tile.isTraversable, etc.
    --
    -- In future, can create a template for serialization between saves, UI,
    -- and the living object itself which can have custom types:
    --  tile.tile -> Tile
    --  tile.box -> Box
    --  tile.isTraversable -> Bool
    --
    -- Right now, we can just hard-code the data-driven parts. So, create
    -- functions for `Tile` and `Box` data on the UI side versus the World
    -- side.
    --
    -- What's wrong with simply traversing the key,value pairs of an object
    -- and picking the correct 'menu item' for the type of value?

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
        if tile.id == TilesMenu.selected then
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, green)
        else
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, black)
        end
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonActive, green)
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonHovered, white)

        if imgui.ImageButton("btn", Config.Tilesheet, size, uv0, uv1, bg_col, tint_col) then
            TilesMenu.selected = tile.id

            --selectedTile.tile = tile.id
            --selectedTile.isWalkable = tile.isWalkable
        end

        imgui.PopStyleColor(3)
        imgui.PopID()
        imgui.SameLine()
    end

    imgui.NewLine()
    if imgui.Button("Clear") then
        --selectedTile.tile = nil
    end

    endWindow(imgui)
end

return TilesMenu


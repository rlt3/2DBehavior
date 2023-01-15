require("Config")
local Map = require("Map")
local Entity = require("Entity")
local Viewport = require("Viewport")

local lib_path = love.filesystem.getWorkingDirectory() .. "libraries/"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "libraries/cimgui"
local ffi = require 'ffi'

local character

function love.load ()
    character = Entity.new(196, 196)

    Map:init()
    imgui.love.Init()
end

function love.quit ()
    Map:save()
    return imgui.love.Shutdown()
end

TilesMenu = {
    isOpen = ffi.new("bool[1]", true),
    selected = "grass1",
}

function DrawTilesMenu (selectedTile, isNewSelection)
    -- TODO: The title bar color changes if we move the menu before pressing
    -- close
    if isNewSelection then
        TilesMenu.selected = selectedTile.tile
    end

    local flags = imgui.ImGuiWindowFlags_None
                + imgui.ImGuiWindowFlags_NoResize
                + imgui.ImGuiWindowFlags_NoScrollbar
                + imgui.ImGuiWindowFlags_NoCollapse
                + imgui.ImGuiWindowFlags_NoNav
                --+ imgui.ImGuiWindowFlags_NoTitleBar

    -- draw the menu at the selected tile
    local pos  = imgui.ImVec2_Float(Viewport:worldToScreen(selectedTile.x + selectedTile.size, selectedTile.y))
    local size = imgui.ImVec2_Float(400, 300)
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_Always)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Tile Menu", TilesMenu.isOpen, flags)

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
        if tile.id == TilesMenu.selected then
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, green)
        else
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, black)
        end
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonActive, green)
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonHovered, white)

        if imgui.ImageButton("btn", Config.Tilesheet, size, uv0, uv1, bg_col, tint_col) then
            TilesMenu.selected = tile.id
            selectedTile.tile = tile.id
        end

        imgui.PopStyleColor(3)
        imgui.PopID()
        imgui.SameLine()
    end

    imgui.NewLine()
    if imgui.Button("Clear") then
        selectedTile.tile = nil
    end

    imgui.End()

    local shouldClose = not TilesMenu.isOpen[0]
    if shouldClose then
        TilesMenu.isOpen[0] = true
    end
    return shouldClose
end

function love.draw ()
    -- Map is the base layer
    -- Map controls tiles and thus should control what is navigable or not
    Map:draw(Viewport)
    if Map:hasSelection() then
        Map:drawSelection(Viewport)
        if DrawTilesMenu(Map.SelectedTile, Map:isSelectionNew()) then
            Map:clearSelection()
        end
    end

    -- Next comes our entities. This includes characters and interactables,
    -- such as chests, farmable land, doors, etc.
    character:draw(Viewport)

    -- Finally, the UI comes last as we expect that to be on top
    imgui.Render()
    imgui.love.RenderDrawLists()
end

function love.update (dt)
    character:update(dt)

    imgui.love.Update(dt)
    imgui.NewFrame()
end

function love.mousepressed(x, y, button)
    imgui.love.MousePressed(button)
    if not imgui.love.GetWantCaptureMouse() then
        Map:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    imgui.love.MouseReleased(button)
    if not imgui.love.GetWantCaptureMouse() then
        Map:mousereleased(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy)
    imgui.love.MouseMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        Map:mousemoved(x, y, dx, dy)
    end
end

function love.wheelmoved (x, y)
    imgui.love.WheelMoved(x, y)
    if not imgui.love.GetWantCaptureMouse() then
        -- your code here 
    end
end

function love.keypressed (key, ...)
    imgui.love.KeyPressed(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        if key == "escape" or key == "q" then
            love.event.quit()
        end
    end
end

function love.keyreleased (key, ...)
    imgui.love.KeyReleased(key)
    if not imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

function love.textinput (t)
    imgui.love.TextInput(t)
    if imgui.love.GetWantCaptureKeyboard() then
        -- your code here 
    end
end

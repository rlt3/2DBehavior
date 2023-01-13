require("Config")

local Map = require("Map")
local Viewport = require("Viewport")

local lib_path = love.filesystem.getWorkingDirectory()
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "cimgui"

function love.load ()
    Map:init()
    imgui.love.Init()
end

function love.quit ()
    Map:save()
    return imgui.love.Shutdown()
end

TilesMenu = {
    selected = "grass1",
}

function DrawTileMenu (selectedTile, isNewSelection)
    if isNewSelection then
        TilesMenu.selected = selectedTile.tile
    end

    local dim = imgui.ImVec2_Float(Config.Spritesheet:getDimensions())

    local red = imgui.ImVec4_Float(0, 1, 0, 1)
    local black = imgui.ImVec4_Float(0, 0, 0, 0)
    local green = imgui.ImVec4_Float(0, 1, 0, 1)
    local white = imgui.ImVec4_Float(1, 1, 1, 1)

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

        if imgui.ImageButton("btn", Config.Spritesheet, size, uv0, uv1, bg_col, tint_col) then
            TilesMenu.selected = tile.id
            selectedTile.tile = tile.id
            print(tile.id)
        end

        imgui.PopStyleColor(3)
        imgui.PopID()
        imgui.SameLine()
    end
end

function DrawEntityWindow (tile, isNewSelection)
    local flags = imgui.ImGuiWindowFlags_None
                + imgui.ImGuiWindowFlags_NoResize
                + imgui.ImGuiWindowFlags_NoScrollbar
                + imgui.ImGuiWindowFlags_NoTitleBar
                + imgui.ImGuiWindowFlags_NoCollapse
                + imgui.ImGuiWindowFlags_NoNav

    -- attempt to draw the menu at the selected tile
    local pos  = imgui.ImVec2_Float(Viewport:worldToScreen(tile.x + tile.size, tile.y))
    local size = imgui.ImVec2_Float(Viewport:worldToScreen(400, 300))

    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_Always)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Entity Menu", nil, flags)

    DrawTileMenu(tile, isNewSelection)
    
    imgui.End()
end

function love.draw ()
    Map:draw()

    --imgui.ShowDemoWindow()
    if Map:hasSelection() then
        Map:drawSelection()
        DrawEntityWindow(Map.SelectedTile, Map:isSelectionNew())
    end

    imgui.Render()
    imgui.love.RenderDrawLists()
end

function love.update (dt)
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

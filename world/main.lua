require("Config")

local Map = require("Map")

local lib_path = love.filesystem.getWorkingDirectory()
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "cimgui"


local SPRITESHEET = nil

function love.load ()
    Map:init()
    imgui.love.Init()

    SPRITESHEET = love.graphics.newImage("assets/terrain_atlas.png")
end

function love.quit ()
    Map:save()
    return imgui.love.Shutdown()
end

Tiles = {
    selected = "grass1",
    data = {
        { id = "grass1", x =  0, y = 800 },
        { id = "grass2", x = 32, y = 800 },
        { id = "grass3", x = 64, y = 800 },
        { id = "grass4", x = 96, y = 800 },
    }
}

function DrawTileSelection ()
    local dim = imgui.ImVec2_Float(SPRITESHEET:getDimensions())

    for i, tile in ipairs(Tiles.data) do
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
        if tile.id == Tiles.selected then
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, imgui.ImVec4_Float(0, 1, 0, 1))
        else
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, imgui.ImVec4_Float(0, 0, 0, 0))
        end
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonActive, imgui.ImVec4_Float(0, 1, 0, 1))
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonHovered, imgui.ImVec4_Float(1, 1, 1, 1))

        if imgui.ImageButton("btn", SPRITESHEET, size, uv0, uv1, bg_col, tint_col) then
            Tiles.selected = tile.id
            print(tile.id)
        end

        imgui.PopStyleColor(3)
        imgui.PopID()
        imgui.SameLine()
    end
end

function DrawEntityWindow ()
    local flags = imgui.ImGuiWindowFlags_None
                + imgui.ImGuiWindowFlags_NoResize
                + imgui.ImGuiWindowFlags_NoScrollbar
                + imgui.ImGuiWindowFlags_NoTitleBar
                + imgui.ImGuiWindowFlags_NoCollapse
                + imgui.ImGuiWindowFlags_NoNav
    imgui.SetNextWindowPos(imgui.ImVec2_Float(0, 0), imgui.ImGuiCond_Once)
    imgui.SetNextWindowSize(imgui.ImVec2_Float(400, 600), imgui.ImGuiCond_Once)

    imgui.Begin("Entity Menu", nil, flags)

    -- TODO: should be a specific sprite loaded & handled by some data-driven
    -- config, e.g. Tile["grass"]
    DrawTileSelection()
    
    imgui.End()
end

function love.draw ()
    Map:draw()

    --imgui.ShowDemoWindow()
    DrawEntityWindow()

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

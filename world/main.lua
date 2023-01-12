require("Config")

local Map = require("Map")

local lib_path = love.filesystem.getWorkingDirectory()
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "cimgui"


local IMG = nil

function love.load ()
    Map:init()
    imgui.love.Init()

    IMG = love.graphics.newImage("assets/terrain_atlas.png")
end

function love.quit ()
    Map:save()
    return imgui.love.Shutdown()
end

function DrawTileButton (spritesheet, x, y)
    local dim = imgui.ImVec2_Float(spritesheet:getDimensions())

    -- size of the button
	local size = imgui.ImVec2_Float(Config.TileSize, Config.TileSize)
    -- top-left coordinates, divided by dimensions to force range [0, 1]
	local uv0 = imgui.ImVec2_Float(x / dim.x, y / dim.y)
    -- bot-right coordinates, divided, again, to force range into [0, 1]
	local uv1 = imgui.ImVec2_Float((x + Config.TileSize) / dim.x, (y + Config.TileSize) / dim.y)
    -- Black background
	local bg_col = imgui.ImVec4_Float(0, 0, 0, 1)
    -- No tint
	local tint_col = imgui.ImVec4_Float(1, 1, 1, 1)

    imgui.ImageButton("btn", IMG, size, uv0, uv1, bg_col, tint_col)
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
    DrawTileButton(IMG, 0, 800)
    DrawTileButton(IMG, 32, 800)
    DrawTileButton(IMG, 64, 800)
    DrawTileButton(IMG, 96, 800)
    
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

local lib_path = love.filesystem.getWorkingDirectory() .. "libraries/"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)

imgui = require("Libraries/cimgui")
local nativefs = require("Libraries/nativefs")
local ffi = require('ffi')

local Viewport = require("UI/Viewport")
local MainMenu = require("UI/MainMenu")
local TilesMenu = require("UI/TilesMenu")

local UI = {}
UI.__index = UI

function UI:init (World)
    imgui.love.Init()

    self.Viewport = Viewport
    self.World = World

    TilesMenu:init(World.Map)
end

function UI:quit ()
    return imgui.love.Shutdown()
end

function UI:draw ()
    imgui.ShowDemoWindow()

    if TilesMenu:hasSelection() then
        TilesMenu:drawSelection(Viewport)
    end

    MainMenu:draw(imgui)
    TilesMenu:draw()

    imgui.Render()
    imgui.love.RenderDrawLists()
end

function UI:update (dt)
    imgui.love.Update(dt)
    imgui.NewFrame()
end

function UI:mousepressed (x, y, button)
    imgui.love.MousePressed(button)
    local canUseEvent = not imgui.love.GetWantCaptureMouse()
    if canUseEvent then
        if button == 3 then
            Viewport:dragStart()
        end
        if button == 1 then
            TilesMenu:mousepressed(Viewport, x, y, dx, dy)
        end
    end
    return canUseEvent
end

function UI:mousereleased (x, y, button)
    imgui.love.MouseReleased(button)
    local canUseEvent = not imgui.love.GetWantCaptureMouse()
    if canUseEvent then
        if button == 3 then
            Viewport:dragEnd()
        end
        if button == 1 then
            TilesMenu:mousereleased(Viewport, x, y, dx, dy)
        end
    end
    return canUseEvent
end

function UI:mousemoved (x, y, dx, dy)
    imgui.love.MouseMoved(x, y)
    local canUseEvent = not imgui.love.GetWantCaptureMouse()
    if canUseEvent then
        Viewport:mousemoved(x, y, dx, dy)
    end
    return canUseEvent
end

function UI:wheelmoved (x, y)
    imgui.love.WheelMoved(x, y)
    return not imgui.love.GetWantCaptureMouse()
end

function UI:keypressed (key, ...)
    imgui.love.KeyPressed(key)
    return not imgui.love.GetWantCaptureKeyboard()
end

function UI:keyreleased (key, ...)
    imgui.love.KeyReleased(key)
    return not imgui.love.GetWantCaptureKeyboard()
end

function UI:textinput (t)
    imgui.love.TextInput(t)
    return imgui.love.GetWantTextInput()
end

return setmetatable(UI, UI)

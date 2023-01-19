local ffi = require 'ffi'
local nativefs = require("Libraries/nativefs")

local lib_path = love.filesystem.getWorkingDirectory() .. "libraries/"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "Libraries/cimgui"

local UI = {}
UI.__index = UI

function UI:init ()
    imgui.love.Init()
end

function UI:quit ()
    return imgui.love.Shutdown()
end

function UI:draw ()
    imgui.ShowDemoWindow()
    imgui.Render()
    imgui.love.RenderDrawLists()
end

function UI:update (dt)
    imgui.love.Update(dt)
    imgui.NewFrame()
end

function UI:mousepressed (x, y, button)
    imgui.love.MousePressed(button)
    return not imgui.love.GetWantCaptureMouse()
end

function UI:mousereleased (x, y, button)
    imgui.love.MouseReleased(button)
    return not imgui.love.GetWantCaptureMouse()
end

function UI:mousemoved (x, y, dx, dy)
    imgui.love.MouseMoved(x, y)
    return not imgui.love.GetWantCaptureMouse()
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
    return imgui.love.GetWantCaptureKeyboard()
end

return setmetatable(UI, UI)
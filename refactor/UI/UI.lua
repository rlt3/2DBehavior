local lib_path = love.filesystem.getWorkingDirectory() .. "libraries/"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)

imgui = require("Libraries/cimgui")
local nativefs = require("Libraries/nativefs")
local ffi = require('ffi')

local Viewport = require("UI/Viewport")
local MainMenu = require("UI/MainMenu")
local TilesMenu = require("UI/TilesMenu")
local EntityMenu = require("UI/EntityMenu")

local TileEditor = require("UI/Tools/TileEditor")

local UI = {}
UI.__index = UI

function UI:init (World)
    imgui.love.Init()

    self.Viewport = Viewport
    self.World = World

    self.Tools = {
        TileEditor,
    }

    TilesMenu:init(World.Map)
    EntityMenu:init(World.Environment)
end

-- TODO: had to make this a local var rather than a member I think because I'm
-- allowing nil, not 100% sure. get a loop while indexing UI
local activeTool = nil

function UI:quit ()
    return imgui.love.Shutdown()
end

function UI:draw ()
    --imgui.ShowDemoWindow()

    -- Because our tools totally take over the UI while that tool is running,
    -- we check on each frame whether or not to use the active tool or draw
    -- the main UI
    if not activeTool then
        activeTool = MainMenu:draw(self.Tools, activeTool)

        -- We draw one menu at a time, based on selection and order of
        -- importance, to keep the number of menus at a minimum.
        if EntityMenu:hasSelection() then
            EntityMenu:drawSelection(Viewport)
            EntityMenu:draw()
        elseif TilesMenu:hasSelection() then
            TilesMenu:drawSelection(Viewport)
            TilesMenu:draw()
        end
    else
        activeTool:draw(Viewport, self.World.Map)
        activeTool = MainMenu:draw(self.Tools, activeTool)
    end

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
            EntityMenu:mousepressed(Viewport, x, y, dx, dy)
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

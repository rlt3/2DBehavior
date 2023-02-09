local lib_path = love.filesystem.getWorkingDirectory() .. "libraries/"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)

imgui = require("Libraries/cimgui")
local nativefs = require("Libraries/nativefs")
local ffi = require('ffi')

local Box = require("Utils/Box")
local Entity = require('World/Entity')
local Tile = require('World/Tile')

local Viewport = require("UI/Viewport")
local MainMenu = require("UI/MainMenu")

local BoxInput = require('UI/Inputs/BoxInput')
local BooleanInput = require('UI/Inputs/BooleanInput')
local TileInput = require('UI/Inputs/TileInput')
local PathInput = require('UI/Inputs/PathInput')

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
    self.activeTool = nil

    self.selection = nil
    self.isSelectionNew = false
end

function UI:quit ()
    return imgui.love.Shutdown()
end

function UI:drawSelection ()
    love.graphics.setColor(1, 0, 0, 1)
    Viewport:worldToScreen(self.selection.box):draw()
    love.graphics.setColor(1, 1, 1, 1)
end

function UI:selectionIsType (t)
    return type(self.selection) == "table" and getmetatable(self.selection) == t
end

function UI:handleSelection (x, y)
    local click = Viewport:screenToWorld(Box.new(x, y, 1))
    local selected

    self.selection = self.World.Environment:lookupEntity(click:position())
    if self.selection then return end
    self.selection = self.World.Map:lookupTile(click:position())
end

function UI:drawSelectionMenu (template)
    local pos  = imgui.ImVec2_Float(0, 0)
    local size = imgui.ImVec2_Float(400, 300)
    -- allow the window to be moved wherever and have it remember that position
    -- but always set the size and it cannot be resized
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_FirstUseEver)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)
    imgui.Begin("Selection Menu", nil, 0)

    local allowInput = not self.isSelectionNew
    self.isSelectionNew = false

    for i,p in ipairs(template) do
        local k = p.key
        local v = self.selection[k]
        if p.type == "Box" then
            BoxInput:draw(self.selection, allowInput, k, v)
        elseif p.type == "Boolean" then
            BooleanInput:draw(self.selection, allowInput, k, v)
        elseif p.type == "Tile" then
            TileInput:draw(self.selection, allowInput, k, v)
        elseif p.type == "Path" then
            PathInput:draw(self, self.selection, allowInput, k, v)
        else
            --error("Unrecognized template pair: `" .. p.key .. "' -> `" .. p.type .. "'")
        end
    end

    imgui.End()
end

function UI:draw ()
    imgui.ShowDemoWindow()

    -- Because our tools totally take over the UI while that tool is running,
    -- we check on each frame whether or not to use the active tool or draw
    -- the main UI
    if not self.activeTool then
        self.activeTool = MainMenu:draw(self.Tools, self.activeTool)

        if self.selection then
            self:drawSelection()
            if self:selectionIsType(Entity) then
                self:drawSelectionMenu(Entity.Template)
            elseif self:selectionIsType(Tile) then
                self:drawSelectionMenu(Tile.Template)
            end
        end
    else
        self.activeTool:draw(Viewport, self.World.Map)
        self.activeTool = MainMenu:draw(self.Tools, self.activeTool)
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
            self:handleSelection(x, y)
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

return UI

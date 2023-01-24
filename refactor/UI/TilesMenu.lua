local ffi = require('ffi')
local Box = require('Utils/Box')
local Tile = require('World/Tile')

local BoxInput = require('UI/BoxInput')
local BooleanInput = require('UI/BooleanInput')
local TileInput = require('UI/TileInput')

local TilesMenu = {}
TilesMenu.__index = TilesMenu

local isOpen = ffi.new("bool[1]", true)
local lastSelected = nil
local newSelection = false

-- references created at :init
local Map

function TilesMenu:init (_Map)
    Map = _Map
    selected = Map:lookupTile(0, 0)
end

local function beginWindow ()
    local pos  = imgui.ImVec2_Float(0, 0)
    local size = imgui.ImVec2_Float(400, 300)
    -- allow the window to be moved wherever and have it remember that position
    -- but always set the size and it cannot be resized
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_Once)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Tile Menu", TilesMenu.isOpen, flags)
end

local function endWindow ()
    imgui.End()
end

function TilesMenu:draw ()
    if not selected then return end

    -- we only allow inputs, i.e. actually changing the selection's values,
    -- when there's not just been a new selection. if the user highlights an
    -- input box but then selects a new tile, the highlighted input will
    -- trigger imgui's input procedure to return true, telling our functions
    -- to update values. we stop that with this simple check.
    local allowInput = not newSelection
    newSelection = false

    beginWindow(imgui)

    for i,p in ipairs(Tile.Template) do
        local k = p.key
        local v = selected[k]
        if p.type == "Box" then
            BoxInput:draw(selected, allowInput, k, v)
        elseif p.type == "Boolean" then
            BooleanInput:draw(selected, allowInput, k, v)
        elseif p.type == "Tile" then
            TileInput:draw(selected, allowInput, k, v)
        else
            error("Unrecognized template pair: `" .. p.key .. "' -> `" .. p.type .. "'")
        end
    end

    endWindow()
end

function TilesMenu:hasSelection ()
    return (selected ~= nil)
end

function TilesMenu:drawSelection (Viewport)
    love.graphics.setColor(0, 0, 1, 1)
    local b = Viewport:worldToScreen(selected.box)
    b:draw(Viewport)
    love.graphics.setColor(1, 1, 1, 1)
end

function TilesMenu:mousepressed (Viewport, x, y, button)
    local click = Viewport:screenToWorld(Box.new(x, y, 1))
    selected = Map:lookupTile(click:position())
    newSelection = true
end

function TilesMenu:mousereleased (Viewport, x, y, button)
end

return TilesMenu


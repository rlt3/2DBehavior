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

local function DrawInput_Tile ()
    --for i, tile in ipairs(Config.Tiles) do
    --    -- size of the button
    --    local size = imgui.ImVec2_Float(Config.TileSize, Config.TileSize)
    --    -- top-left coordinates, divided by dimensions to force range [0, 1]
    --    local uv0 = imgui.ImVec2_Float(tile.x / dim.x, tile.y / dim.y)
    --    -- bot-right coordinates, divided, again, to force range into [0, 1]
    --    local uv1 = imgui.ImVec2_Float((tile.x + Config.TileSize) / dim.x, (tile.y + Config.TileSize) / dim.y)
    --    -- Black background
    --    local bg_col = imgui.ImVec4_Float(0, 0, 0, 1)
    --    -- No tint
    --    local tint_col = imgui.ImVec4_Float(1, 1, 1, 1)

    --    imgui.PushID_Str(tile.id)
    --    if tile.id == TilesMenu.selected then
    --        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, green)
    --    else
    --        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, black)
    --    end
    --    imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonActive, green)
    --    imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonHovered, white)

    --    if imgui.ImageButton("btn", Config.Tilesheet, size, uv0, uv1, bg_col, tint_col) then
    --        TilesMenu.selected = tile.id

    --        --selectedTile.tile = tile.id
    --        --selectedTile.isWalkable = tile.isWalkable
    --    end

    --    imgui.PopStyleColor(3)
    --    imgui.PopID()
    --    imgui.SameLine()
    --end
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


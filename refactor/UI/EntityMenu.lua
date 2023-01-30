local Box = require('Utils/Box')
local Entity = require('World/Entity')

local BoxInput = require('UI/Inputs/BoxInput')
local BooleanInput = require('UI/Inputs/BooleanInput')

local EntityMenu = {}
EntityMenu.__index = EntityMenu

local selected = nil
local newSelection = false

local Environment
function EntityMenu:init (_Environment)
    Environment = _Environment
end

local function beginWindow ()
    local pos  = imgui.ImVec2_Float(0, 0)
    local size = imgui.ImVec2_Float(400, 300)
    -- allow the window to be moved wherever and have it remember that position
    -- but always set the size and it cannot be resized
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_FirstUseEver)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Entity Menu", nil, 0)
end

local function endWindow ()
    imgui.End()
end

function EntityMenu:draw ()
    if not selected then return end

    beginWindow()

    for i,p in ipairs(Entity.Template) do
        local k = p.key
        local v = selected[k]
        if p.type == "Box" then
            BoxInput:draw(selected, allowInput, k, v)
        elseif p.type == "Boolean" then
            BooleanInput:draw(selected, allowInput, k, v)
        else
            --print("Unhandled type: `" .. p.key .. "' -> `" .. p.type .. "'")
            --error("Unrecognized template pair: `" .. p.key .. "' -> `" .. p.type .. "'")
        end
    end

    endWindow()
end

function EntityMenu:hasSelection ()
    return (selected ~= nil)
end

function EntityMenu:drawSelection (Viewport)
    love.graphics.setColor(1, 0, 0, 1)
    Viewport:worldToScreen(selected.box):draw()
    love.graphics.setColor(1, 1, 1, 1)
end

function EntityMenu:mousepressed (Viewport, x, y)
    local click = Viewport:screenToWorld(Box.new(x, y, 1))
    selected = Environment:lookupEntity(click:position())
    if selected then
        newSelection = true
    end
end

return EntityMenu

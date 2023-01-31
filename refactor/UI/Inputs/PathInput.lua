local Box = require("Utils/Box")
local ffi = require("ffi")
local STRLEN = 64

local PathInput = {
    buf = ffi.new("char[?]", STRLEN),
}
PathInput.__index = PathInput

local goal = nil
function PathInput:draw (UI, selected, allowInput, k, v)
    local World = UI.World
    local Map = World.Map
    local Viewport = UI.Viewport

    imgui.Button("Click & Drag to Select")
    if imgui.BeginDragDropSource(imgui.ImGuiDragDropFlags_None) then
        -- use dragging and dropping to find a goal
        local pos = imgui.GetMousePos()
        local cursor = Box.new(pos.x, pos.y, 1)
        local x, y = Viewport:screenToWorld(cursor):position()

        goal = Map:lookupTile(x, y)
        if goal then
            imgui.Text(tostring(goal))
        else
            imgui.Text("No selection")
        end

        imgui.EndDragDropSource()
    elseif goal then
        -- if not dragging-and-dropping right now, but a goal was selected
        local start = Map:lookupTile(selected.box:position())
        local path = World:findPath(start, goal)
        if path then
            selected:givePath(path)
        end
        goal = nil
    end

    imgui.SameLine()
    imgui.Text("Path Goal")
end

return PathInput

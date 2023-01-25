local Box = require("Utils/Box")
local Vector = require("Utils/Vector")
local Tile = require("World/Tile")
local TileInput = require("UI/Inputs/TileInput")

local TileEditor = {
    name = "Tile Editor",
}
TileEditor.__index = TileEditor

local Rect = {}
Rect.__index = Rect

function Rect.new ()
    return setmetatable({}, Rect)
end

function Rect:setAnchor (x, y)
    self.anchor = Vector.new(x, y)
end

function Rect:setReach (x, y)
    self.reach = Vector.new(x, y)
end

function Rect:topleft ()
    if self.anchor.x < self.reach.x then
        if self.anchor.y < self.reach.y then
            -- anchor is topleft
            return imgui.ImVec2_Float(self.anchor.x, self.anchor.y)
        else
            -- anchor is botleft
            return imgui.ImVec2_Float(self.anchor.x, self.reach.y)
        end
    else
        if self.anchor.y < self.reach.y then
            -- anchor is topright
            return imgui.ImVec2_Float(self.reach.x, self.anchor.y)
        else
            -- anchor is botright
            return imgui.ImVec2_Float(self.reach.x, self.reach.y)
        end
    end
    return imgui.ImVec2_Float(self.anchor.x, self.anchor.y)
end

function Rect:botright ()
    if self.anchor.x < self.reach.x then
        if self.anchor.y < self.reach.y then
            -- reach is botright
            return imgui.ImVec2_Float(self.reach.x, self.reach.y)
        else
            -- reach is topright
            return imgui.ImVec2_Float(self.reach.x, self.anchor.y)
        end
    else
        if self.anchor.y < self.reach.y then
            -- reach is botleft
            return imgui.ImVec2_Float(self.anchor.x, self.reach.y)
        else
            -- reach is topleft
            return imgui.ImVec2_Float(self.anchor.x, self.anchor.y)
        end
    end
    return imgui.ImVec2_Float(self.reach.x, self.reach.y)
end

local COLOR_BORDER = imgui.ImVec4_Float(0, 0.51, 0.84, 1.0)
local COLOR_BACKGROUND = imgui.ImVec4_Float(0, 0.51, 0.84, 0.20)

local selectionRect = nil
local tilesSelected = nil

-- keeps a selection
function drawSelectionRect ()
    if imgui.love.GetWantCaptureMouse() then return false end

    if imgui.IsMouseClicked(imgui.ImGuiMouseButton_Left) then
        -- reset the selection on a click
        tilesSelected = nil
        selectionRect = Rect.new()

        -- we must create a copy of the values here because it seems the
        -- object from GetMousePos is a reference that gets corrupted/updated
        local pos = imgui.GetMousePos()
        selectionRect:setAnchor(pos.x, pos.y)
    end

    if selectionRect and imgui.IsMouseDown(imgui.ImGuiMouseButton_Left) then
        local border = imgui.GetColorU32_Vec4(COLOR_BORDER)
        local background = imgui.GetColorU32_Vec4(COLOR_BACKGROUND)

        local pos = imgui.GetMousePos()
        selectionRect:setReach(pos.x, pos.y)

        drawList = imgui.GetBackgroundDrawList_Nil()
        drawList:AddRect(selectionRect:topleft(), selectionRect:botright(), border)
        drawList:AddRectFilled(selectionRect:topleft(), selectionRect:botright(), background)
    end

    if imgui.IsMouseReleased(imgui.ImGuiMouseButton_Left) then
        return true
    end

    return false
end

-- holds the master values applied to sets of tiles
local master = {
    tile = "none"
}

function drawMenu ()
    local pos  = imgui.ImVec2_Float(0, 0)
    local size = imgui.ImVec2_Float(400, 300)
    -- allow the window to be moved wherever and have it remember that position
    -- but always set the size and it cannot be resized
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_FirstUseEver)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Tile Editor Menu", nil, flags)

    if TileInput:draw(master, true, "tile", master.tile) then
        if tilesSelected then
            for i,tile in ipairs(tilesSelected) do
                tile.tile = master.tile
            end
        end
    end

    imgui.NewLine()
    if imgui.Button("Select & Fill Mode") then
        print("fill")
    end

    if imgui.Button("Paintbrush Mode") then
        print("paintbrush")
    end

    imgui.End()
end

function TileEditor:draw (Viewport, Map)
    local isDone = drawSelectionRect()

    -- draw the selection rectangle while also updating the tiles selection
    if selectionRect then
        -- translate the rectangle via the Viewport for the initial selection
        local tl = selectionRect:topleft()
        local br = selectionRect:botright()
        tl = Viewport:screenToWorld(Box.new(tl.x, tl.y, Config.TileSize))
        br = Viewport:screenToWorld(Box.new(br.x, br.y, Config.TileSize))
        tilesSelected = Map:selectTiles(tl.pos, br.pos)

        -- when we've fully selected (user has let go of the mouse), then stop
        -- drawing the selection rect
        if isDone then
            selectionRect = nil
        end
    end

    if tilesSelected then
        for i,tile in ipairs(tilesSelected) do
            love.graphics.setColor(1, 0, 0, 1)
            Viewport:worldToScreen(tile.box):draw()
            love.graphics.setColor(1, 1, 1, 1)
        end
    end

    drawMenu()
end

return setmetatable(TileEditor, TileEditor)

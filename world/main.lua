require("Config")
local Map = require("Map")
local Viewport = require("Viewport")
local Entity = require("Entity")
local Environment = require("Environment")

local lib_path = love.filesystem.getWorkingDirectory() .. "libraries/"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "libraries/cimgui"

local Serializer = require("libraries/Serializer")
local nativefs = require("libraries/nativefs")
local ffi = require 'ffi'

local calledOnce = false
function love.load ()
    -- cannot trust that these libraries have multi-time initialization
    if not calledOnce then
        imgui.love.Init()
        calledOnce = true
    end

    if Config.ini:exists() then
        Config.ini:reload()
    end

    local mapData = nil
    if nativefs.getInfo(Config.ini["SaveFile"]) then
        print("Loading world data from: " .. Config.ini["SaveFile"])
        local data, size = nativefs.read(Config.ini["SaveFile"])
        -- read data back in the same order we wrote it
        mapData = Serializer.deserializeN(data, 1)
    end

    Map:init(mapData)
    Environment:init()

    Environment:add(Entity.new(196, 196))
    local start = Map:lookupTile(196, 196)
    local goal = Map:lookupTile(0, 0)
    local path = Map:findPath(start, goal)
    --print(path)
end

function love.quit ()
    -- NOTE: This serializer copies deeply. Meaning it copies functions, etc.
    -- We only want data here, not implementation. This is why each component
    -- has a `serialize` method.
    local data = Serializer.serialize(Map:serialize())
    local success, message = nativefs.write(Config.ini["SaveFile"], data)
    if not success then
        error("Save data was not saved! " .. message)
    end

    Config.ini:save()

    return imgui.love.Shutdown()
end

FileSystemDialog = {
    cwd = nativefs.getWorkingDirectory(),
    selected = nil,

    Yield = 0,
    Ok = 1,
    Cancel = -1,

    reset = function (self)
    end
}

function DrawFileSystemDialog (title, message, okButton, cancelButton)
    local flags = imgui.ImGuiWindowFlags_None
                + imgui.ImGuiWindowFlags_NoResize
                + imgui.ImGuiWindowFlags_NoScrollbar
                + imgui.ImGuiWindowFlags_NoCollapse
                --+ imgui.ImGuiWindowFlags_NoNav
                --+ imgui.ImGuiWindowFlags_NoTitleBar

    local windowSize = imgui.ImVec2_Float(300, 550)
    local windowPos  = imgui.ImVec2_Float((love.graphics.getWidth() / 2) - windowSize.x, (love.graphics.getHeight() / 2) - windowSize.y)
    imgui.SetNextWindowPos(windowPos, imgui.ImGuiCond_Always)
    imgui.SetNextWindowSize(windowSize, imgui.ImGuiCond_Always)
    imgui.Begin(title, nil, flags)

    -- separate directories and files because one is for traveling and the
    -- other is for selecting. also remember to seed the list with a way to
    -- travel backwards
    local directories = {}
    local files = {}
    table.insert(directories, { name = "..", type == "directory" })
    local dirinfo = nativefs.getDirectoryItemsInfo(FileSystemDialog.cwd)
    for i,file in ipairs(dirinfo) do
        if file.type == "directory" then
            table.insert(directories, file)
        else
            table.insert(files, file)
        end
    end

    -- static height for the filepicker. it has scrollbars if needed
    local maxHeight = 25 * imgui.GetTextLineHeightWithSpacing()
    local listboxSize = imgui.ImVec2_Float(-imgui.FLT_MIN, maxHeight)

    local status = FileSystemDialog.Yield
    if imgui.BeginListBox("file picker", listboxSize) then
        for i,dir in ipairs(directories) do
            local isSelected = (FileSystemDialog.selected == dir.name)
            -- TODO: Windows versus linux paths, etc.
            -- nativefs.GetWorkingDirectory returns a path with no appended
            -- "\\". Therefore, every concatenation should be glued together
            -- by a "\\"
            if imgui.Selectable_Bool("\\" .. dir.name, isSelected) then
                FileSystemDialog.cwd = FileSystemDialog.cwd .. "\\" .. dir.name
                FileSystemDialog.selected = nil
            end
            if is_selected then
                imgui.SetItemDefaultFocus()
            end
        end
        for i,file in ipairs(files) do
            local isSelected = (FileSystemDialog.selected == file.name)
            if imgui.Selectable_Bool(file.name, isSelected) then
                FileSystemDialog.selected = file.name
            end
            if is_selected then
                imgui.SetItemDefaultFocus()
            end
        end
        imgui.EndListBox()
    end

    imgui.NewLine()
    imgui.Text(message)
    imgui.SameLine()
    if FileSystemDialog.selected == nil then
        imgui.TextColored(imgui.ImVec4_Float(0.4, 0.4, 0.4, 0.6), "none")
    else
        imgui.Text(FileSystemDialog.selected)
    end

    imgui.NewLine()
    if FileSystemDialog.selected == nil then
        imgui.BeginDisabled()
    end
    if imgui.Button(okButton) then
        status = FileSystemDialog.Ok
    end
    if FileSystemDialog.selected == nil then
        imgui.EndDisabled()
    end

    imgui.SameLine()
    if imgui.Button(cancelButton) then
        status = FileSystemDialog.Cancel
    end

    imgui.End()
    return status
end

TopMenu = {
    state = "inactive",
}

function DrawTopMenu ()
    local flags = imgui.ImGuiWindowFlags_None
                + imgui.ImGuiWindowFlags_NoResize
                + imgui.ImGuiWindowFlags_NoScrollbar
                + imgui.ImGuiWindowFlags_NoCollapse
                --+ imgui.ImGuiWindowFlags_NoNav
                + imgui.ImGuiWindowFlags_NoTitleBar

    -- top corner with minimal height so that the menu is always menu-height
    local pos  = imgui.ImVec2_Float(0, 0)
    local size = imgui.ImVec2_Float(love.graphics:getWidth(), 0)
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_Always)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    -- remove minimums and add some nice padding
    imgui.PushStyleVar_Vec2(imgui.ImGuiStyleVar_WindowMinSize, imgui.ImVec2_Float(0, 0))
    --imgui.PushStyleVar_Vec2(imgui.ImGuiStyleVar_FramePadding, imgui.ImVec2_Float(10, 10))

    imgui.Begin("Main Menu", nil, flags)

    -- handle specific interactions for each button
    if TopMenu.state == "open" then
        local status = DrawFileSystemDialog("Select the file to open", "File selected:", "Open", "Cancel")
        if status == FileSystemDialog.Ok then
            Config.ini["SaveFile"] = FileSystemDialog.cwd .. "\\" .. FileSystemDialog.selected
            TopMenu.state = "inactive"
            love.load() -- reload EVERYTHING using this new save file
        elseif status == FileSystemDialog.Cancel then
            TopMenu.state = "inactive"
        end
    end

    -- draw the main menu. while there's work being done, disable this menu
    if TopMenu.state ~= "inactive" then
        imgui.BeginDisabled()
    end
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("File") then
            if imgui.MenuItem_Bool("New") then
            end
            if imgui.MenuItem_Bool("Open", "Ctrl+O") then
                TopMenu.state = "open"
            end
        end
    end
    if TopMenu.state ~= "inactive" then
        imgui.EndDisabled()
    end

    imgui.PopStyleVar(1)
    imgui.End()
end

TilesMenu = {
    isOpen = ffi.new("bool[1]", true),
    selected = "grass1",
}

function DrawTilesMenu (selectedTile, isNewSelection)
    -- TODO: The title bar color changes if we move the menu before pressing
    -- close
    if isNewSelection then
        TilesMenu.selected = selectedTile.tile
    end

    local flags = imgui.ImGuiWindowFlags_None
                + imgui.ImGuiWindowFlags_NoResize
                + imgui.ImGuiWindowFlags_NoScrollbar
                + imgui.ImGuiWindowFlags_NoCollapse
                + imgui.ImGuiWindowFlags_NoNav
                --+ imgui.ImGuiWindowFlags_NoTitleBar

    -- draw the menu at the selected tile
    local pos  = imgui.ImVec2_Float(Viewport:worldToScreen(selectedTile.x + selectedTile.size, selectedTile.y))
    local size = imgui.ImVec2_Float(400, 300)
    -- allow the window to be moved wherever and have it remember that position
    -- but always set the size and it cannot be resized
    imgui.SetNextWindowPos(pos, imgui.ImGuiCond_Once)
    imgui.SetNextWindowSize(size, imgui.ImGuiCond_Always)

    imgui.Begin("Tile Menu", TilesMenu.isOpen, flags)

    local red = imgui.ImVec4_Float(0, 1, 0, 1)
    local black = imgui.ImVec4_Float(0, 0, 0, 0)
    local green = imgui.ImVec4_Float(0, 1, 0, 1)
    local white = imgui.ImVec4_Float(1, 1, 1, 1)
    local dim = imgui.ImVec2_Float(Config.Tilesheet:getDimensions())

    for i, tile in ipairs(Config.Tiles) do
        -- size of the button
        local size = imgui.ImVec2_Float(Config.TileSize, Config.TileSize)
        -- top-left coordinates, divided by dimensions to force range [0, 1]
        local uv0 = imgui.ImVec2_Float(tile.x / dim.x, tile.y / dim.y)
        -- bot-right coordinates, divided, again, to force range into [0, 1]
        local uv1 = imgui.ImVec2_Float((tile.x + Config.TileSize) / dim.x, (tile.y + Config.TileSize) / dim.y)
        -- Black background
        local bg_col = imgui.ImVec4_Float(0, 0, 0, 1)
        -- No tint
        local tint_col = imgui.ImVec4_Float(1, 1, 1, 1)

        imgui.PushID_Str(tile.id)
        if tile.id == TilesMenu.selected then
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, green)
        else
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, black)
        end
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonActive, green)
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonHovered, white)

        if imgui.ImageButton("btn", Config.Tilesheet, size, uv0, uv1, bg_col, tint_col) then
            TilesMenu.selected = tile.id

            selectedTile.tile = tile.id
            selectedTile.isWalkable = tile.isWalkable
        end

        imgui.PopStyleColor(3)
        imgui.PopID()
        imgui.SameLine()
    end

    imgui.NewLine()
    if imgui.Button("Clear") then
        selectedTile.tile = nil
    end

    imgui.End()

    local shouldClose = not TilesMenu.isOpen[0]
    if shouldClose then
        TilesMenu.isOpen[0] = true
    end
    return shouldClose
end

function love.draw ()
    -- Map is the base layer
    -- Map controls tiles and thus should control what is navigable or not
    Map:draw(Viewport)

    -- Next comes our entities. This includes characters and interactables,
    -- such as chests, farmable land, doors, etc.
    Environment:draw(Viewport)

    -- Finally, the UI comes last as we expect that to be on top
    --imgui.ShowDemoWindow()
    DrawTopMenu()

    if Map:hasSelection() then
        Map:drawSelection(Viewport)
        if DrawTilesMenu(Map.SelectedTile, Map:isSelectionNew()) then
            Map:clearSelection()
        end
    end

    imgui.Render()
    imgui.love.RenderDrawLists()
end

function love.update (dt)
    Environment:update(dt)

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

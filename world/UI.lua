local ffi = require 'ffi'
local nativefs = require("libraries/nativefs")

local lib_path = love.filesystem.getWorkingDirectory() .. "libraries/"
local extension = jit.os == "Windows" and "dll" or jit.os == "Linux" and "so" or jit.os == "OSX" and "dylib"
package.cpath = string.format("%s;%s/?.%s", package.cpath, lib_path, extension)
local imgui = require "libraries/cimgui"

local UI = {
    TopMenu = {
        state = "inactive",
    },
    ToolMenu = {
        selected = "none",
        tools = {
            { name = "Tiles Tool" },
            { name = "Entity Tool" },
        },
    },
    TilesMenu = {
        isOpen = ffi.new("bool[1]", true),
        selected = "grass1",
    },
    FileSystemDialog = {
        cwd = nativefs.getWorkingDirectory(),
        selected = nil,

        Yield = 0,
        Ok = 1,
        Cancel = -1,

        reset = function (self)
        end
    },
}
UI.__index = UI

function UI:DrawFileSystemDialog (title, message, okButton, cancelButton)
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
    local dirinfo = nativefs.getDirectoryItemsInfo(self.FileSystemDialog.cwd)
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

    local status = self.FileSystemDialog.Yield
    if imgui.BeginListBox("file picker", listboxSize) then
        for i,dir in ipairs(directories) do
            local isSelected = (self.FileSystemDialog.selected == dir.name)
            -- TODO: Windows versus linux paths, etc.
            -- nativefs.GetWorkingDirectory returns a path with no appended
            -- "\\". Therefore, every concatenation should be glued together
            -- by a "\\"
            if imgui.Selectable_Bool("\\" .. dir.name, isSelected) then
                self.FileSystemDialog.cwd = self.FileSystemDialog.cwd .. "\\" .. dir.name
                self.FileSystemDialog.selected = nil
            end
            if is_selected then
                imgui.SetItemDefaultFocus()
            end
        end
        for i,file in ipairs(files) do
            local isSelected = (self.FileSystemDialog.selected == file.name)
            if imgui.Selectable_Bool(file.name, isSelected) then
                self.FileSystemDialog.selected = file.name
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
    if self.FileSystemDialog.selected == nil then
        imgui.TextColored(imgui.ImVec4_Float(0.4, 0.4, 0.4, 0.6), "none")
    else
        imgui.Text(self.FileSystemDialog.selected)
    end

    imgui.NewLine()
    if self.FileSystemDialog.selected == nil then
        imgui.BeginDisabled()
    end
    if imgui.Button(okButton) then
        status = self.FileSystemDialog.Ok
    end
    if self.FileSystemDialog.selected == nil then
        imgui.EndDisabled()
    end

    imgui.SameLine()
    if imgui.Button(cancelButton) then
        status = self.FileSystemDialog.Cancel
    end

    imgui.End()
    return status
end

function UI:DrawTopMenu ()
    local isDisabled = false
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
    if self.TopMenu.state == "open" then
        local status = self:DrawFileSystemDialog("Select the file to open", "File selected:", "Open", "Cancel")
        if status == self.FileSystemDialog.Ok then
            Config.ini["SaveFile"] = self.FileSystemDialog.cwd .. "\\" .. self.FileSystemDialog.selected
            self.TopMenu.state = "inactive"
            love.load() -- reload EVERYTHING using this new save file
        elseif status == self.FileSystemDialog.Cancel then
            self.TopMenu.state = "inactive"
        end
    end

    -- draw the main menu. while there's work being done, disable this menu
    if self.TopMenu.state ~= "inactive" then
        isDisabled = true
        imgui.BeginDisabled()
    end
    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("File") then
            if imgui.MenuItem_Bool("New") then
            end
            if imgui.MenuItem_Bool("Open", "Ctrl+O") then
                self.TopMenu.state = "open"
            end
            imgui.EndMenu()
        end
        if imgui.BeginMenu("Tools") then
            for i,tool in ipairs(self.ToolMenu.tools) do
                local isSelected = (self.ToolMenu.selected == tool.name)
                if imgui.MenuItem_Bool(tool.name, nil, isSelected) then
                    if isSelected then
                        self.ToolMenu.selected = "none"
                    else
                        self.ToolMenu.selected = tool.name
                    end
                end
            end
            imgui.EndMenu()
        end
        imgui.EndMenu()
    end
    if self.TopMenu.state ~= "inactive" then
        imgui.EndDisabled()
    end

    imgui.PopStyleVar(1)
    imgui.End()

    return isDisabled
end

function UI:DrawTilesMenu (Viewport, selectedTile, isNewSelection)
    -- TODO: The title bar color changes if we move the menu before pressing
    -- close
    if isNewSelection then
        self.TilesMenu.selected = selectedTile.tile
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

    imgui.Begin("Tile Menu", self.TilesMenu.isOpen, flags)

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
        if tile.id == self.TilesMenu.selected then
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, green)
        else
            imgui.PushStyleColor_Vec4(imgui.ImGuiCol_Button, black)
        end
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonActive, green)
        imgui.PushStyleColor_Vec4(imgui.ImGuiCol_ButtonHovered, white)

        if imgui.ImageButton("btn", Config.Tilesheet, size, uv0, uv1, bg_col, tint_col) then
            self.TilesMenu.selected = tile.id

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

    local shouldClose = not self.TilesMenu.isOpen[0]
    if shouldClose then
        self.TilesMenu.isOpen[0] = true
    end
    return shouldClose
end

function UI:init ()
    imgui.love.Init()
end

function UI:quit ()
    return imgui.love.Shutdown()
end

function UI:draw (Map, Environment, Viewport)
    --imgui.ShowDemoWindow()
    local disabled = self:DrawTopMenu()

    if disabled then
        imgui.BeginDisabled()
    end

    if Map:hasSelection() then
        Map:drawSelection(Viewport)
        if self:DrawTilesMenu(Viewport, Map.SelectedTile, Map:isSelectionNew()) then
            Map:clearSelection()
        end
    end
    if Environment:hasSelection() then
        print("here")
        Environment:drawSelection(Viewport)
    end
    if disabled then
        imgui.EndDisabled()
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

return UI
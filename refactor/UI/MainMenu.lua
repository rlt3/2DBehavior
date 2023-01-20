local MainMenu = {}
MainMenu.__index = MainMenu

local function beginWindow (imgui)
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
end

local function endWindow (imgui)
    imgui.PopStyleVar(1)
    imgui.End()
end

local tools = {
    { name = "Map Editor" },
    { name = "Entity Editor" }
}

local selection = "none"

function MainMenu:draw (imgui)
    beginWindow(imgui)

    if imgui.BeginMainMenuBar() then
        if imgui.BeginMenu("File") then
            if imgui.MenuItem_Bool("New") then
            end
            if imgui.MenuItem_Bool("Open", "Ctrl+O") then
            end
            imgui.EndMenu()
        end
        if imgui.BeginMenu("Tools") then
            for i,tool in ipairs(tools) do
                local isSelected = (selection == tool.name)
                if imgui.MenuItem_Bool(tool.name, nil, isSelected) then
                    if isSelected then
                        selection = "none"
                    else
                        selection = tool.name
                    end
                end
            end
            imgui.EndMenu()
        end
        imgui.EndMenu()
    end

    endWindow(imgui)
end

return MainMenu

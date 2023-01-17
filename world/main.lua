require("Config")
local Map = require("Map")
local Viewport = require("Viewport")
local Entity = require("Entity")
local Environment = require("Environment")
local UI = require("UI")

local Serializer = require("libraries/Serializer")
local nativefs = require("libraries/nativefs")

local calledOnce = false
function love.load ()
    -- cannot trust that these libraries have multi-time initialization
    if not calledOnce then
        UI:init()
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

    local e = Entity.new(196, 196)
    local start = Map:lookupTile(196, 196)
    local goal = Map:lookupTile(0, 0)
    local path = Map:findPath(start, goal)

    e:givePath(path)
    Environment:add(e)
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

    return UI:quit()
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
    UI:draw(Map, Viewport)
end

function love.update (dt)
    Environment:update(dt)
    UI:update(dt)
end

function love.mousepressed(x, y, button)
    -- TODO: this could be better written to express the control flow
    if UI:mousepressed(x, y, button) then
        Map:mousepressed(x, y, button)
    end
end

function love.mousereleased(x, y, button)
    if UI:mousereleased(x, y, button) then
        Map:mousereleased(x, y, button)
    end
end

function love.mousemoved(x, y, dx, dy)
    if UI:mousemoved(x, y) then
        Map:mousemoved(x, y, dx, dy)
    end
end

function love.wheelmoved (x, y)
    if UI:wheelmoved(x, y) then
        -- your code here 
    end
end

function love.keypressed (key, ...)
    if UI:keypressed(key) then
        if key == "escape" or key == "q" then
            love.event.quit()
        end
    end
end

function love.keyreleased (key, ...)
    if UI:keyreleased(key) then
        -- your code here 
    end
end

function love.textinput (t)
    if UI:textinput(t) then
        -- your code here 
    end
end

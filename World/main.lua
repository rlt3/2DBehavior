require("Config")
local UI = require("UI/UI")
local World = require("World/World")
local Persist = require("Persist/Persist")

local Entity = require("World/Entity")

function love.load ()
    World:init()
    UI:init(World)

    Persist:load(World)

    -- just set a sane default color early
    love.graphics.setColor(1, 1, 1, 1)
end

function love.quit ()
    Persist:save(World)
    UI:quit()
end

function love.draw ()
    World:draw(UI.Viewport)
    UI:draw()
end

function love.update (dt)
    World:update(dt)
    UI:update(dt)
end

function love.mousepressed (x, y, button)
    -- TODO: this could be better written to express the control flow
    if UI:mousepressed(x, y, button) then
    end
end

function love.mousereleased (x, y, button)
    if UI:mousereleased(x, y, button) then
    end
end

function love.mousemoved (x, y, dx, dy)
    if UI:mousemoved(x, y, dx, dy) then
    end
end

function love.wheelmoved (x, y)
    if UI:wheelmoved(x, y, dx, dy) then
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
    end
end

function love.textinput (t)
    if UI:textinput(t) then
    end
end

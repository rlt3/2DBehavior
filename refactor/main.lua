require("Config")
local UI = require("UI/UI")
local Map = require("World/Map")

function love.load ()
    UI:init()
    Map:init()

    -- just set a sane default color early
    love.graphics.setColor(1, 1, 1, 1)
end

function love.quit ()
    UI:quit()
end

function love.draw ()
    Map:draw(UI.Viewport)
    UI:draw()
end

function love.update (dt)
    UI:update(dt)
end

function love.mousepressed (x, y, button)
    -- TODO: this could be better written to express the control flow
    if UI:mousepressed(x, y, button) then
        if button == 3 then
            UI.Viewport:dragStart()
        end
    end
end

function love.mousereleased (x, y, button)
    if UI:mousereleased(x, y, button) then
        if button == 3 then
            UI.Viewport:dragEnd()
        end
    end
end

function love.mousemoved (x, y, dx, dy)
    if UI:mousemoved(x, y) then
        UI.Viewport:mousemoved(x, y, dx, dy)
    end
end

function love.wheelmoved (x, y)
    if UI:wheelmoved(x, y) then
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

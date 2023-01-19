local UI = require("UI/UI")

function love.load ()
    UI:init()
end

function love.quit ()
    UI:quit()
end

function love.draw ()
    UI:draw()
end

function love.update (dt)
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
    if UI:mousemoved(x, y) then
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

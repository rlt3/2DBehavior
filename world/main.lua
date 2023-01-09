local Map = require("Map")

function love.load ()
end

function love.keypressed (key)
    if key == "escape" or key == "q" then
        Map:save()
        love.event.quit()
    end
end

function love.draw ()
    Map:draw()
end

function love.update (dt)
end

function love.mousepressed(x, y, button)
    Map:mousepressed(x, y, button)
end

function love.mousereleased(x, y, button)
    Map:mousereleased(x, y, button)
end

function love.mousemoved(x, y, dx, dy)
    Map:mousemoved(x, y, dx, dy)
end

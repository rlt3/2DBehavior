function love.conf(t)
    -- Disable controller support which makes startup times unbearable
    t.modules.joystick = false
    -- Enables text output to the console
    t.console = true
end

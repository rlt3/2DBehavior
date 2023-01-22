local State = {}
State.__index = State

local function is_state (t)
    return getmetatable(t) == State
end

function State.new (t)
    return setmetatable(t, State)
end

return State

local State = {}
State.__index = State

Template = {
    {
        key = "box",
        type = "Box",
        default = Box.new(0, 0, Config.TileSize),
    },
    {
        key = "isTraversable",
        type = "Boolean",
        default = false
    },
    {
        key = "tile",
        type = "Tile",
        default = "none",
        update = function (self, other)
            self["tile"] = other["tile"]
            self["isTraversable"] = other["isTraversable"]
        end,
    },
}

local function is_state (t)
    return getmetatable(t) == State
end

function State:__index (k)
    return self.state[k].value
end

function State:__newindex (k, v)
    self.state[k].value = v
end

function State.new (template)
    local s = {}

    for i,field in ipairs(template) do
        local f = {}
        f.key = field.key
        f.type = field.type
        f.update = field.update
        f.value = field.default
        s[field.key] = f
    end

    return setmetatable({ state = s }, State)
end

function State:update (k, v)
    local field = self.state[k]

    if not field then
        error("Cannot update state with nil key `" .. k .. "'")
    end

    if field.update then
        field:update(v)
    else
        field.value = v
    end
end

function State:get (k)
    local field = self.state[k]

    if not field then
        error("Cannot get nil state with key `" .. k .. "'")
    end

    return field.value
end

return State

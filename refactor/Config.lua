--local ini = require("ini")

Config = {
    --ini = ini,
    MapWidth = 100,
    MapHeight = 100,
    SaveFile = love.filesystem.getSaveDirectory() .. "/world.save",
    Charactersheet = love.graphics.newImage("Assets/character.png"),
    CharacterSize = 64,
    CharacterAnimations = {
        { name = "attackUp",    range = "1-8", row = 5, speed = 0.1 },
        { name = "attackLeft",  range = "1-8", row = 6, speed = 0.1 },
        { name = "attackDown",  range = "1-8", row = 7, speed = 0.1 },
        { name = "attackRight", range = "1-8", row = 8, speed = 0.1 },

        { name = "walkUp",    range = "1-9", row =  9, speed = 0.1 },
        { name = "walkLeft",  range = "1-9", row = 10, speed = 0.1 },
        { name = "walkDown",  range = "1-9", row = 11, speed = 0.1 },
        { name = "walkRight", range = "1-9", row = 12, speed = 0.1 },

        { name = "death",     range = "1-6", row = 21, speed = 0.1 },
    },
    Tilesheet = love.graphics.newImage("Assets/terrain_atlas.png"),
    TileSize = 32,
    Tiles = {
        { tile = "grass1", x =   0, y = 800, isTraversable = true },
        { tile = "grass2", x =  32, y = 800, isTraversable = true },
        { tile = "grass3", x =  64, y = 800, isTraversable = true },
        { tile = "grass4", x =  96, y = 800, isTraversable = true },

        { tile = "rock1",  x = 672, y = 672, isTraversable = false },
    },
}
return Config

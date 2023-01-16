Config = {
    SaveFile = "world.save",
    MapWidth = 100,
    MapHeight = 100,
    Charactersheet = love.graphics.newImage("assets/character.png"),
    CharacterSize = 64,
    CharacterAnimations = {
        { id = "attackUp",    range = "1-8", row = 5, speed = 0.1 },
        { id = "attackLeft",  range = "1-8", row = 6, speed = 0.1 },
        { id = "attackDown",  range = "1-8", row = 7, speed = 0.1 },
        { id = "attackRight", range = "1-8", row = 8, speed = 0.1 },

        { id = "walkUp",    range = "1-9", row =  9, speed = 0.1 },
        { id = "walkLeft",  range = "1-9", row = 10, speed = 0.1 },
        { id = "walkDown",  range = "1-9", row = 11, speed = 0.1 },
        { id = "walkRight", range = "1-9", row = 12, speed = 0.1 },

        { id = "death",     range = "1-6", row = 21, speed = 0.1 },
    },
    Tilesheet = love.graphics.newImage("assets/terrain_atlas.png"),
    TileSize = 32,
    Tiles = {
        { id = "grass1", x =  0, y = 800 },
        { id = "grass2", x = 32, y = 800 },
        { id = "grass3", x = 64, y = 800 },
        { id = "grass4", x = 96, y = 800 },
    },
}
return Config

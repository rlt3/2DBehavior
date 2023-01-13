Config = {
    MapFile = "map.tiles",
    MapWidth = 100,
    MapHeight = 100,
    Spritesheet = love.graphics.newImage("assets/terrain_atlas.png"),
    TileSize = 32,
    Tiles = {
        { id = "grass1", x =  0, y = 800 },
        { id = "grass2", x = 32, y = 800 },
        { id = "grass3", x = 64, y = 800 },
        { id = "grass4", x = 96, y = 800 },
    },
}
return Config

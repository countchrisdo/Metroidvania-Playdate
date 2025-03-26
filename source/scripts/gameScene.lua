local pd = playdate
local gfx = pd.graphics

TAGS = {
    Player = 1,
    Enemy = X,
    Wall = X,
}

Z_INDEXES = {
    Player = 100,
    Enemy = 200,
    Wall = 300,
}

local ldtk <const> = LDtk

ldtk.load("levels/world.ldtk", false)

class('GameScene').extends()

function GameScene:init()
    self:goToLevel("Level_0")
    self.spawnX = 12 * 16
    self.spawnY = 5 * 16
    -- (12, 5) are grid coordinates. 16 is the tile sizes to get the pixel coordinates.

    -- Creating player
    -- assigning player to a player property in the game scene
    -- We pass in "self" to the player so that the player can access the game scene
    self.player = Player(self.spawnX, self.spawnY, self)
end

function GameScene:enterRoom(direction)
-- enterRoom() is a method that calls goToLevel() with the level name of the neighbour in the specified direction.
-- It then moves the player to the spawn point of the new level without creating a new player object, keeping player information.
-- ARGS: direction is a string that can be "north", "south", "east", "west"
    local level = ldtk.get_neighbours(self.levelName, direction)[1]
    self:goToLevel(level)
    -- when we call goToLevel we remove all sprites including the player
    self.player:add()
    local spawnX, spawnY
    if direction == "north" then
        spawnX, spawnY = self.player.x, 240
    elseif direction == "south" then
        spawnX, spawnY = self.player.x, 0
    elseif direction == "east" then
        spawnX, spawnY = 0, self.player.y
    elseif direction == "west" then
        spawnX, spawnY = 400, self.player.y
    end
    self.player:moveTo(spawnX, spawnY)
    -- saving spawn location for respawning
    self.spawnX, self.spawnY = spawnX, spawnY

end
function GameScene:goToLevel(level_name)
-- goToLevel() is a method that changes the level of the game scene. It removes all sprites from the game scene and creates a new tilemap for the new level.
-- ARGS: level_name is a string from the LDtk file that represents the level name.

    gfx.sprite.removeAll()
    print("GameScene:goToLevel("..level_name..")")

    -- local layerstb = ldtk.get_layers(level_name)
    -- print("printing layers:")
    -- printTable(layerstb)

    self.levelName = level_name
    for layer_name, layer in pairs(ldtk.get_layers(level_name)) do
        if layer.tiles then
            print("Creating tilemap for layer: "..layer_name)
            local tilemap = ldtk.create_tilemap(level_name, layer_name)

            local layerSprite = gfx.sprite.new()
            layerSprite:setTilemap(tilemap)
            layerSprite:setCenter(0, 0)
            layerSprite:moveTo(0, 0)
            layerSprite:setZIndex(layer.zIndex)
            layerSprite:add()

            -- Getting every empty tile ie. everything not Solid. Solid is an enum we created in LDtk
            local emptyTiles = ldtk.get_empty_tileIDs(level_name, "Solid", layer_name)
            if emptyTiles then
                gfx.sprite.addWallSprites(tilemap, emptyTiles)
            end

        end
    end
end

function printTable(t, indent)
    indent = indent or 0
    for k, v in pairs(t) do
        local formatting = string.rep("  ", indent) .. k .. ": "
        if type(v) == "table" then
            print(formatting)
            printTable(v, indent + 1)
        else
            print(formatting .. tostring(v))
        end
    end
end
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
    self.player = Player(self.spawnX, self.spawnY)
end

function GameScene:goToLevel(level_name)

    gfx.sprite.removeAll()
    print("GameScene:goToLevel("..level_name..")")

    -- local layerstb = ldtk.get_layers(level_name)
    -- print("printing layers:")
    -- printTable(layerstb)

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
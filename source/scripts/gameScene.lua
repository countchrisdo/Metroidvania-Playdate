local pd = playdate
local gfx = pd.graphics

local ldtk <const> = LDtk

ldtk.load("levels/world.ldtk", false)

class('GameScene').extends()

function GameScene:init()
    print("GameScene:init()")
    self:goToLevel("Level_0")
end

function GameScene:goToLevel(level_name)
    gfx.sprite.removeAll()
    print("GameScene:goToLevel("..level_name..")")
    for layer_name, layer in pairs(ldtk.get_layers(level_name)) do
        if layer.tiles then
            print("Creating tilemap for layer: "..layer_name)
            print("Layer_count - layer_index = layer.zindex")
            -- print("Layer_count: "..layer_count)
            -- print("Layer_index: "..layer_index)
            local tilemap = ldtk.create_tilemap(level_name, layer_name)

            local layerSprite = gfx.sprite.new()
            layerSprite:setTilemap(tilemap)
            layerSprite:setCenter(0, 0)
            layerSprite:moveTo(0, 0)
            if layer.zindex then
                layerSprite:setZIndex(layer.zindex)
            else
                layerSprite:setZIndex(0) -- Default to 0 if zindex is nil
            end
            layerSprite:add()

            -- Getting every empty tile ie everything not "Solid". Solid is an enum we created in LDtk
            local emptyTiles = ldtk.get_empty_tileIDs(level_name, "Solid", layer_name)
            if emptyTiles then
                gfx.sprite.addWallSprites(tilemap, emptyTiles)
            end

        end
    end
end
-- CoreLibs
import "CoreLibs/object"
import "CoreLibs/graphics"
import "CoreLibs/sprites"
import "CoreLibs/timer"

-- Libraries
import "scripts/libraries/AnimatedSprite.lua"
import "scripts/libraries/LDtk.lua"

-- Game
import "scripts/gameScene"
import "scripts/player"

GameScene()

local pd = playdate
local gfx = pd.graphics

function pd.update()
    gfx.sprite.update()
    pd.timer.updateTimers()
end
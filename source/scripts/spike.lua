local gfx <const> = playdate.graphics

local spikeImage <const> = gfx.image.new("images/spike")

class('Spike').extends(gfx.sprite)

function Spike:init(x, y)
-- init() method that inits objects
-- ARGS: x, y are the pixel coordinates of the spike
    self:setZIndex(Z_INDEXES.Hazard)
    self:setImage(spikeImage)
    self:setCenter(0, 0) -- This matches LDtk
    self:moveTo(x, y)
    self:add()

    -- Tags are for collision detection
    self:setTag(TAGS.Hazard)
    self:setCollideRect(2, 9, 12, 7)
end
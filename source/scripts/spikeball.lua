local gfx <const> = playdate.graphics

local spikeballImage <const> = gfx.image.new("images/spikeball")

class('Spikeball').extends(gfx.sprite)

function Spikeball:init(x, y, entity)
-- init() method that inits objects
-- ARGS: x, y chords / entity (LDtk library) gives information about the entity
    self:setZIndex(Z_INDEXES.Hazard)
    self:setImage(spikeballImage)
    self:setCenter(0, 0) -- This matches LDtk
    self:moveTo(x, y)
    self:add()

    -- Tags are for collision detection
    self:setTag(TAGS.Hazard)
    self:setCollideRect(4, 4, 8, 8)

    local fields = entity.fields
    self.xVelocity = fields.xVelocity or 0
    self.yVelocity = fields.yVelocity or 0
end

function Spikeball:collisionResponse(other)
-- collisionResponse() is a method that is called when a collision occurs.
-- ARGS: other is the other object that the spikeball collided with
    if other:getTag() == TAGS.Player then
        return gfx.sprite.kCollisionTypeOverlap
    end
    return gfx.sprite.kCollisionTypeBounce
end

function Spikeball:update()
-- update() method: runs every frame, updates spikeball's position, checks for collisions.
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)
    local hitWall = false
    for i=1, length do
        local collision = collisions[i]
        if collision.other:getTag() ~= TAGS.Player then
            hitWall = true
        end
    end

    -- if you hit a wall, reverse the direction
    if hitWall then
        self.xVelocity *= -1
        self.yVelocity *= -1
    end

end
local gfx <const> = playdate.graphics

class('Ability').extends(gfx.sprite)

function Ability:init(x, y, entity)
    self.fields = entity.fields
    if self.fields.pickedUp then
        return
    end

    -- I had to change the name from Ability to Abilities for some reason
    -- look into this
    self.abilityName = self.fields.Abilities
    print("Ability name: " ..self.abilityName)
    local abilityImage = gfx.image.new("images/" ..self.abilityName)
    assert(abilityImage, "Ability image not found: " ..self.abilityName)
    self:setImage(abilityImage)
    self:setZIndex(Z_INDEXES.Pickup)
    self:setCenter(0, 0)
    self:moveTo(x, y)
    self:add()

    self:setTag(TAGS.Pickup)
    self:setCollideRect(0, 0, self:getSize())
end

function Ability:pickUp(player)
-- ARGS: Player: When the player calls this method, they can pass themselves in
    if self.abilityName == "DoubleJump" then
        player.doubleJumpAbility = true
    elseif self.abilityName == "Dash" then
        player.dashAbility = true
    end
    -- Set the pickedUp field to true so that the ability is not picked up again
    -- entities information persists between levels. So we can keep track of what has been picked up
    self.fields.pickedUp = true
    self:remove()
    
end
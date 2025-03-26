local gfx <const> = playdate.graphics

class('Ability').extends(gfx.sprite)

function Ability:init(x, y, entity)
    print("Ability is being created")
    printTable(entity)
    self.fields = entity.fields

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
    self:remove()
    
end
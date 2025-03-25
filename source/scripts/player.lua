local pd = playdate
local gfx = pd.graphics

class('Player').extends(AnimatedSprite)
-- AnimatedSprite library implements a state machine for sprites
-- A state machine is a way to organize code that changes the behavior of an object 

function Player:init(x,y)
    -- State Machine
    local playerImageTable = gfx.imagetable.new("images/player-table-16-16")
    -- -- super.init calls initialization method of the parent class
    Player.super.init(self, playerImageTable)

    -- Creating states
    self:addState("idle", 1, 1)
    self:addState("run", 1, 3, {tickStep = 4})
    -- -- tickStep is speed of the animation (default value = 1). It is the amount of frames (fps) between changing sprites
    self:addState("jump", 4, 4)
    self:playAnimation()

    -- Sprite Properties
    self:moveTo(x, y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player)
    self:setCollideRect(3, 3, 10, 13)
    -- --  Setting collision for player, collision using pd sdk library.

    -- Physics Properties
    self.xVelocity = 0
    self.yVelocity = 0
    self.gravity = 1.0
    self.maxSpeed = 2.0
    self.jumpVelocity = -6
    self.drag = 0.1
    self.minimumAirSpeed = 0.5

    -- Player State
    self.touchingGround = false
    self.touchingCeiling = false
    self.touchingWall = false
end

-- Overwrite collisionResponse method
function Player:collisionResponse()
    return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
    self:updateAnimation()
    -- -- UpdateAnimation is a method from AnimatedSprite library
    self:handleState()
    -- print("Current State" .. self.currentState)
    self:handleMovementAndCollisions()
end

function Player:handleState()
    if self.currentState == "idle" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "run" then
        self:applyGravity()
        self:handleGroundInput()
    elseif self.currentState == "jump" then
        if self.touchingGround then
            self:changeToIdleState()
        end
        self:applyGravity()
        self:applyDrag(self.drag)
        self:handleAirInput()

    end
end

function Player:handleMovementAndCollisions()
    -- moves player by the x and y velocity and gets collisions arr
    local _, _, collisions, length = self:moveWithCollisions(self.x + self.xVelocity, self.y + self.yVelocity)
    -- collisions is an array of all the collisions that happened
    -- setting default values
    self.touchingGround = false
    self.touchingCeiling = false
    self.touchingWall = false
    
    for i=1, length do
        local collision = collisions[i]
        if collision.normal.y == -1 then
        -- a normal is a vector that is perpendicular to the surface player is colliding with
        -- if the collision normal is -1, it means the player is touching the ground.
            self.touchingGround = true
        elseif collision.normal.y == 1 then
            self.touchingCeiling = true
        end

        -- if you're touching a wall, the x collision normal will be either 1 or -1 because collision normal is a vector that is perpendicular to the surface player is colliding with. So we can just check if the x collision normal is not 0. 
        if collision.normal.x ~= 0 then
            self.touchingWall = true
            self.xVelocity = 0
        end
    end
    -- print("Touching Ground: " .. tostring(self.touchingGround))

    -- Flip sprite based on velocity
    if self.xVelocity < 0 then
        self.globalFlip = gfx.kImageFlippedX
    elseif self.xVelocity > 0 then
        self.globalFlip = gfx.kImageUnflipped
    end
end

-- Input Helper Functions
function Player:handleGroundInput()
    -- using buttonIsPressed instead of buttonJustPressed because it's like a cheap way to add buffering to the inputs by changing states. Using buttonJustPressed for jumping because jumping is a one time action.
    if pd.buttonJustPressed(pd.kButtonA) then
        self:changeToJumpState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToRunState("right")
    else
        self:changeToIdleState()
    end
end

function Player:handleAirInput()
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.maxSpeed
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.maxSpeed
    end  
end

-- State transitions
function Player:changeToIdleState()
    self.xVelocity = 0
    self:changeState("idle")
end

function Player:changeToRunState(direction)
    if direction == "left" then
        self.xVelocity = -self.maxSpeed
        self.globalFlip = gfx.kImageFlippedX
    elseif direction == "right" then
        self.xVelocity = self.maxSpeed
        self.globalFlip = gfx.kImageUnflipped
    end
    self:changeState("run")
end

function Player:changeToJumpState()
    self.yVelocity = self.jumpVelocity
    self:changeState("jump")
end

-- Physics Helper Functions
function Player:applyGravity()
    self.yVelocity += self.gravity
    -- print("Applying Gravity")
    -- print("Y Velocity: " .. self.yVelocity)
    if self.touchingGround or self.touchingCeiling then
        self.yVelocity = 0
    end
end

function Player:applyDrag(amount)
    if self.xVelocity > 0 then
        self.xVelocity -= amount
    elseif self.xVelocity < 0 then
        self.xVelocity += amount
    end

    if math.abs(self.xVelocity) < self.minimumAirSpeed or self.touchingWall then
        self.xVelocity = 0
    end
end
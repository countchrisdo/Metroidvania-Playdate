local pd = playdate
local gfx = pd.graphics

class('Player').extends(AnimatedSprite)
-- AnimatedSprite library implements a state machine for sprites
-- A state machine is a way to organize code that changes the behavior of an object 

function Player:init(x,y, gameManager)
-- init() method: inits objects
-- ARGS: x, y are the pixel coordinates of the player / gameManager is the game manager object
    -- Storing Game manager as property
    self.gameManager = gameManager
    local playerImageTable = gfx.imagetable.new("images/player-table-16-16")
    Player.super.init(self, playerImageTable) -- super.init calls init method of parent class (AnimatedSprite)

    -- State Machine
    -- Creating states
    self:addState("idle", 1, 1)
    self:addState("run", 1, 3, {tickStep = 4})
    self:addState("jump", 4, 4)
    self:addState("dash", 4, 4)
    self:playAnimation()

    -- Sprite Properties
    self:moveTo(x, y)
    self:setZIndex(Z_INDEXES.Player)
    self:setTag(TAGS.Player)
    self:setCollideRect(3, 3, 10, 13) -- Standard Playdate SDK collision method

    -- Physics Properties
    self.xVelocity = 0
    self.yVelocity = 0
    self.gravity = 1.0
    self.maxSpeed = 2.0
    self.jumpVelocity = -6
    self.drag = 0.1
    self.minimumAirSpeed = 0.5

    -- Abilities
    self.doubleJumpAbility = false
    self.dashAbility = false

    -- Double Jump
    self.doubleJumpAvailable = true
    
    -- Dash
    self.dashAvailable = true
    self.dashSpeed = 8
    self.dashMinimumSpeed = 3
    self.dashDrag = 0.8

    -- Player States
    self.touchingGround = false
    self.touchingCeiling = false
    self.touchingWall = false
    self.dead = false
end

function Player:collisionResponse(other)
-- Overwriting built in collisionResponse method
    local tag = other:getTag()
    if tag == TAGS.Hazard or tag == TAGS.Pickup then
        return gfx.sprite.kCollisionTypeOverlap
    end
    return gfx.sprite.kCollisionTypeSlide
end

function Player:update()
    if self.dead then
        return
    end

    self:updateAnimation() -- method from AnimatedSprite library
    self:handleState()
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
    elseif self.currentState == "dash" then
        self:applyDrag(self.dashDrag)
        if math.abs(self.xVelocity) <= self.dashMinimumSpeed then
            self:changeToFallState()
        end
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
    local died = false -- died =/ dead | died = action that happens when player dies. dead = state/boolean value.
    
    for i=1, length do
        local collision = collisions[i]
        local collisionType = collision.type
        local collisionObject = collision.other
        local collisionTag = collisionObject:getTag()
        if collisionType == gfx.sprite.kCollisionTypeSlide then
            if collision.normal.y == -1 then
            -- a normal is a vector that is perpendicular to the surface player is colliding with. If the collision normal is -1, it means the player is touching the ground.
                self.touchingGround = true
                self.doubleJumpAvailable = true
                self.dashAvailable = true
            elseif collision.normal.y == 1 then
                self.touchingCeiling = true
            end
            -- if you're touching a wall, the x collision normal will be either 1 or -1 because collision normal is a vector that is perpendicular to the surface player is colliding with. So we can just check if the x collision normal is not 0. 
            if collision.normal.x ~= 0 then
                self.touchingWall = true
                self.xVelocity = 0
            end

        end
        if collisionTag == TAGS.Hazard then
            print("Collision Tag = Hazard | Setting Died = True")
            died = true
        elseif collisionTag == TAGS.Pickup then
            print("Collision Tag = Pickup | Picking up ability")
            collisionObject:pickUp(self) -- passing in self so that the ability can access the player
        end
    end
    -- print("Touching Ground: " .. tostring(self.touchingGround))

    -- Flip sprite based on velocity
    if self.xVelocity < 0 then
        self.globalFlip = gfx.kImageFlippedX
    elseif self.xVelocity > 0 then
        self.globalFlip = gfx.kImageUnflipped
    end

    -- Entering new room based on player position
    if self.x < 0 then
        self.gameManager:enterRoom("west")
    elseif self.x > 400 then
        self.gameManager:enterRoom("east")
    elseif self.y < 0 then
        self.gameManager:enterRoom("north")
    elseif self.y > 240 then
        self.gameManager:enterRoom("south")
    end

    if died then
        self:die()
    end
end

function Player:die()
    -- die() method: stops player, set's dead to true, delays, then sets dead to false and resets the player
    -- to respawn the player we need the gameScene (gameManager) bc it stores where the player spawned
    self.xVelocity = 0
    self.yVelocity = 0
    self.dead = true
    self:setCollisionsEnabled(false)
    pd.timer.performAfterDelay(200, function()
        self:setCollisionsEnabled(true)
        self.gameManager:resetPlayer()
        self.dead = false
    end)
end

-- Input Helper Functions
function Player:handleGroundInput()
    -- using buttonIsPressed instead of buttonJustPressed because it's like a cheap way to add buffering to the inputs by changing states. Using buttonJustPressed for jumping because jumping is a one time action.
    if pd.buttonJustPressed(pd.kButtonA) then
        self:changeToJumpState()
    elseif pd.buttonJustPressed(pd.kButtonB) and self.dashAbility and self.dashAvailable then
        self:changeToDashState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
        self:changeToRunState("left")
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self:changeToRunState("right")
    else
        self:changeToIdleState()
    end
end

function Player:handleAirInput()
    if pd.buttonJustPressed(pd.kButtonA) and self.doubleJumpAvailable and self.doubleJumpAbility then
        self.doubleJumpAvailable = false
        self:changeToJumpState()
    elseif pd.buttonJustPressed(pd.kButtonB) and self.dashAbility and self.dashAvailable then
        self:changeToDashState()
    elseif pd.buttonIsPressed(pd.kButtonLeft) then
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
    print("Changing to run state")
    if direction == "left" then
        self.xVelocity = -self.maxSpeed
        self.globalFlip = gfx.kImageFlippedX
    elseif direction == "right" then
        self.xVelocity = self.maxSpeed
        self.globalFlip = gfx.kImageUnflipped
    end
    self:changeState("run")
    print("Current State: " .. self.currentState)
end

function Player:changeToJumpState()
    print("Changing to jump state")
    self.yVelocity = self.jumpVelocity
    self:changeState("jump")
    print("Current State: " .. self.currentState)
end

function Player:changeToFallState()
    print("Changing to fall state")
    -- Fall state is the same as jump state but without the jump velocity
    self:changeState("jump")
    print("Current State: " .. self.currentState)
end

function Player:changeToDashState()
    print("Changing to dash state")
    self.dashAvailable = false
    self.yVelocity = 0
    if pd.buttonIsPressed(pd.kButtonLeft) then
        self.xVelocity = -self.dashSpeed
    elseif pd.buttonIsPressed(pd.kButtonRight) then
        self.xVelocity = self.dashSpeed
    else
        -- If no direction is pressed, dash in the direction the player is facing using globalFlip
        if self.globalFlip == gfx.kImageFlippedX then
            self.xVelocity = -self.dashSpeed
        else
            self.xVelocity = self.dashSpeed
        end
    end
    self:changeState("dash")
    print("Current State: " .. self.currentState)
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
local scheduler = require("framework.scheduler")

local MainScene = class("MainScene", function()
    return display.newScene("MainScene")
end)

local GRAVITY         = -200
local WALL_THICKNESS  = 64
local WALL_FRICTION   = 1.0
local WALL_ELASTICITY = 0.5

local FRUITS = 
{
    "watermelon",
    "strawberry",
    "pineapple",
    "grapes",
}

function MainScene:ctor()
    -- create physics world
    self.world = CCPhysicsWorld:create(0, GRAVITY)
    -- add world to scene
    self:addChild(self.world)

    local scaleFactor = 1
    self.fruitsPhysics = require("fruitsPhysicsData").physicsData(scaleFactor)

    -- add static body
    local leftWallSprite = display.newSprite("#Wall.png")
    leftWallSprite:setScaleY(display.height / WALL_THICKNESS)
    self:addChild(leftWallSprite)
    local leftWallBody = self.world:createBoxBody(0, WALL_THICKNESS, display.height)
    leftWallBody:setFriction(WALL_FRICTION)
    leftWallBody:setElasticity(WALL_ELASTICITY)
    leftWallBody:bind(leftWallSprite)
    leftWallBody:setPosition(display.left + WALL_THICKNESS / 2, display.cy + WALL_THICKNESS)

    local rightWallSprite = display.newSprite("#Wall.png")
    rightWallSprite:setScaleY(display.height / WALL_THICKNESS)
    self:addChild(rightWallSprite)
    local rightWallBody = self.world:createBoxBody(0, WALL_THICKNESS, display.height)
    rightWallBody:setFriction(WALL_FRICTION)
    rightWallBody:setElasticity(WALL_ELASTICITY)
    rightWallBody:bind(rightWallSprite)
    rightWallBody:setPosition(display.right - WALL_THICKNESS / 2, display.cy + WALL_THICKNESS)

    local bottomWallSprite = display.newSprite("#Wall.png")
    bottomWallSprite:setScaleX(display.width / WALL_THICKNESS)
    self:addChild(bottomWallSprite)
    local bottomWallBody = self.world:createBoxBody(0, display.width, WALL_THICKNESS)
    bottomWallBody:setFriction(WALL_FRICTION)
    bottomWallBody:setElasticity(WALL_ELASTICITY)
    bottomWallBody:bind(bottomWallSprite)
    bottomWallBody:setPosition(display.cx, display.bottom + WALL_THICKNESS / 2)

    -- add debug node
    self.worldDebug = self.world:createDebugNode()
    self:addChild(self.worldDebug)
end

function MainScene:createFruit()
    local fruitName = FRUITS[math.random(1, #FRUITS)]

    local fruitBody = nil
    local physicsData = self.fruitsPhysics:get(fruitName)
    for i, shape in ipairs(physicsData.shapes) do
        local polygons = shape.polygons

        for n, v in ipairs(polygons) do
            local vertexes = CCPointArray:create(#v / 2)
            for j = 1, #v, 2 do
                vertexes:add(cc.p(v[j], v[j+1]))
            end

            if not fruitBody then
                fruitBody = self.world:createPolygonBody(shape.mass, vertexes)
            else
                fruitBody:addPolygonShape(vertexes)
            end
        end
        fruitBody:setFriction(shape.friction)
        fruitBody:setElasticity(shape.elasticity)
        fruitBody:setCollisionType(shape.collision_type)
    end


    local fruitResName = fruitName .. ".png"
    local fruit = display.newSprite(fruitResName)
    self:addChild(fruit)

    fruitBody:bind(fruit)
    fruitBody:setPosition(math.random(display.width-100) + 50, display.height+100)
end

function MainScene:onCollisionListener(phase, event)
    if phase == "begin" then
        print("collision begin")
        local body1 = event:getBody1()
        local body2 = event:getBody2()
        body1:getNode():removeFromParentAndCleanup(true)
        body2:getNode():removeFromParentAndCleanup(true)
        self.world:removeBody(body1, true)
        self.world:removeBody(body2, true)
    elseif phase == "preSolve" then
        print("collision preSolve")
    elseif phase == "postSolve" then
        print("collision postSolve")
    elseif phase == "separate" then
        print("collision separate")
    end

end

function MainScene:onEnter()
    self.world:start()
    scheduler.scheduleGlobal(function()
        self:createFruit()
    end, 1.0)
    self.world:addCollisionScriptListener(handler(self, self.onCollisionListener), 1, 2)
end

function MainScene:onExit()
    self.world:removeAllCollisionListeners()
end

return MainScene

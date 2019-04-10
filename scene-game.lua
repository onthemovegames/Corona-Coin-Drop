local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )
local physics = require( "physics" )
physics.start()
--physics.setDrawMode("hybrid")

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- These values are set for easier access later on.
local acw = display.actualContentWidth
local ach = display.actualContentHeight
local cx = display.contentCenterX
local cy = display.contentCenterY
local top = display.screenOriginY
local left = display.screenOriginX
local right = display.viewableContentWidth - left
local bottom = display.viewableContentHeight - display.screenOriginY

local onTilt, dropCoins, onMenuTouch, onGlobalCollision -- forward declares for functions
local tmr_startGame, tmr_dropCoins -- forward declares for our timers
local player, playerScore -- forward declares for our player and player score
local playerScoreCounter = 0 -- a counter to keep track of player points
local coins = {} -- a table to store the coin objects
local coinCounter = 1 -- a counter to track the number of coins
local sensitivity = 2000 -- adjust this value to make the player more slower or quicker
-- -----------------------------------------------------------------------------------
-- Scene event functions

-- This function will move the player based on x axis tilt.
onTilt = function(event)
    player:setLinearVelocity( sensitivity * event.xGravity, 0 )        
    return true
end

-- Create the coins that will drop from the sky for the player to catch.
dropCoins = function()
  coins[coinCounter] = display.newImageRect("images/coin.png", 110, 110)
    coins[coinCounter].x = math.random(left, right)
    coins[coinCounter].y = top - 60
    physics.addBody(coins[coinCounter], {radius=55})
    coins[coinCounter].myName = "coins"

  coinCounter = coinCounter + 1 
end

-- Return the player to the menu and stop the game from running. We'll also run through the coins table to remove all coins. 
onMenuTouch = function(event)
  if(event.phase == "began") then 
    Runtime:removeEventListener("accelerometer", onTilt )
    Runtime:removeEventListener( "collision", onGlobalCollision )
    timer.cancel(tmr_dropCoins)

    for i=1,coinCounter do
      if(coins[i]) then 
        display.remove(coins[i])
      end
    end

    composer.gotoScene("scene-menu", "fade")
  end
end

-- Our global collision detector to detect colliding objects between player/coin and coin/floor. The player score will then go up or down accordingly.
onGlobalCollision = function(event)

    local obj1 = event.object1 -- store the first object
    local obj2 = event.object2 -- store the second object

    local function decrementScore() -- decrease player score
      playerScoreCounter = playerScoreCounter - 1
      playerScore.text = "Score: "..playerScoreCounter
    end

    local function fadeObject(obj) -- fade the coins out when they hit the floor
      obj.myName = "lostCoin"
      decrementScore()
      transition.to(obj, {alpha = 0, onComplete=function(self) display.remove(self); end})
    end

    local function incrementScore(obj) -- increase the player score
      obj.myName = "grabbedCoin"
      transition.to(obj, {alpha = 0, onComplete=function(self) display.remove(self); end})
      playerScoreCounter = playerScoreCounter + 1
      playerScore.text = "Score: "..playerScoreCounter
    end

    if ( event.phase == "began" ) then
      if(obj1.myName == "coins" and obj2.myName == "floor") then -- listen for coins/floor collision   
        timer.performWithDelay(1, function() fadeObject(obj1); end, 1) -- don't ever remove an object in the middle of collision detection. Wait until the collision is over
      end
      if(obj1.myName == "floor" and obj2.myName == "coins") then -- listen for floor/coins collision
        timer.performWithDelay(1, function() fadeObject(obj2); end, 1)
      end

      if(obj1.myName == "player" and obj2.myName == "coins") then -- listen for player/coins collision
        timer.performWithDelay(1, function() incrementScore(obj2); end, 1)
      end
      if(obj1.myName == "coins" and obj2.myName == "player") then -- listen for coins/player collision
        timer.performWithDelay(1, function() incrementScore(obj1); end, 1)
      end
    end
end

-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  local background = display.newImageRect(sceneGroup, "images/background.png", acw, ach)
  	background.x = cx
  	background.y = cy

  -- Add in a graphic for our floor. This is the visual piece only
  local floor = display.newImageRect(sceneGroup, "images/floor.png", 900, 210)
    floor.x = cx
    floor.y = bottom - 100

  -- I want the player to look like they are 'standing' on the floor so I create a rectangle that acts as the floor. The player will stand on this object. 
  local floorPhysics = display.newRect(sceneGroup, 0, 0, acw, 50)
    floorPhysics.x = cx
    floorPhysics.y = floor.y + 30
    floorPhysics:setFillColor(0,0,0,0.01)
    floorPhysics.myName = "floor"
    physics.addBody(floorPhysics, "static")

  -- Create a left/right wall boundary. These objects are static and do not respond to gravity.
  local leftWall = display.newRect(sceneGroup, 0, 0, 40, ach)
    leftWall.x = left - 25
    leftWall.y = cy
    leftWall.myName = "wall"
    physics.addBody(leftWall, "static")

  local rightWall = display.newRect(sceneGroup, 0, 0, 40, ach)
    rightWall.x = right + 25
    rightWall.y = cy
    rightWall.myName = "wall"
    physics.addBody(rightWall, "static")

  -- Create two obstacles to give our game some flair
  local obstacle1 = display.newImageRect(sceneGroup, "images/obstacle1.png", 180, 180)
    obstacle1.x = math.random(200,300)
    obstacle1.y = 300
    obstacle1.myName = "obstacle"
    obstacle1.rotation = 10
    physics.addBody(obstacle1, "static")

  local obstacle2 = display.newImageRect(sceneGroup, "images/obstacle2.png", 100, 100)
    obstacle2.x = math.random(500,600)
    obstacle2.y = 625
    obstacle2.myName = "obstacle"
    obstacle2.rotation = -10
    physics.addBody(obstacle2, "static")

  -- Create a menu button to allow the player to go back to the menu
  local btn_menu = widget.newButton({
      left = 100,
      top = 200,
      width = 120,
      height = 120,
      defaultFile = "images/btn_menu.png",
      overFile = "images/btn_menu_over.png",      
      onEvent = onMenuTouch
    }
  )
  btn_menu.x = left + 70
  btn_menu.y = top + 70
  sceneGroup:insert(btn_menu)

  -- A visual indicator of the player score
  playerScore = display.newText(sceneGroup, "Score: 0", 0, 0, native.systemFontBold, 64)
    playerScore.anchorX = 1
    playerScore.anchorY = 0
    playerScore.x = right - 10
    playerScore.y = top + 10

  -- Add the player!
  player = display.newImageRect(sceneGroup, "images/player.png", 315, 332)
    player.x = cx
    player.y = floor.y - 275
    physics.addBody(player)
    player.myName = "player"
    player.isFixedRotation = true

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
      -- Code here runs when the scene is entirely on screen
      local function startGame()
        Runtime:addEventListener("accelerometer", onTilt ) -- start up the accelerometer listener
      end
      tmr_startGame = timer.performWithDelay(1250, startGame, 1) -- allow the player to move shortly after the game has started
      tmr_dropCoins = timer.performWithDelay(1400, dropCoins, 0) -- start dropping coins!
      Runtime:addEventListener( "collision", onGlobalCollision ) -- add an event listener to detect collisions
      
    end
end


-- hide()
function scene:hide( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      -- Code here runs when the scene is on screen (but is about to go off screen)

    elseif ( phase == "did" ) then
      -- Code here runs immediately after the scene goes entirely off screen

    end
end


-- destroy()
function scene:destroy( event )

    local sceneGroup = self.view
    -- Code here runs prior to the removal of scene's view

end


-- -----------------------------------------------------------------------------------
-- Scene event function listeners
-- -----------------------------------------------------------------------------------
scene:addEventListener( "create", scene )
scene:addEventListener( "show", scene )
scene:addEventListener( "hide", scene )
scene:addEventListener( "destroy", scene )
-- -----------------------------------------------------------------------------------

return scene
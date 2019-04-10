local composer = require( "composer" )
local scene = composer.newScene()
local widget = require( "widget" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------
-- These values are set for easier access later on.
local acw = display.actualContentWidth
local ach = display.actualContentHeight
local cx = display.contentCenterX
local cy = display.contentCenterY
local bottom = display.viewableContentHeight - display.screenOriginY

-- -----------------------------------------------------------------------------------
-- Scene event functions

-- This function will send the player to the game scene
local function onPlayTouch(event)
  if(event.phase == "ended") then 
    composer.gotoScene("scene-game", "fade")
  end
end
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

  local sceneGroup = self.view
  -- Code here runs when the scene is first created but has not yet appeared on screen
  local background = display.newImageRect(sceneGroup, "images/title-background.png", acw, ach) -- I make the background larger than the width/height specified in config.lua. This allows the entire device screen to be filled up with the background graphic without stretching it.
  	background.x = cx
  	background.y = cy
	
	-- Create a start playing button. When touched, trigger the onPlayTouch function
	local btn_play = widget.newButton({
      left = 100,
      top = 200,
      label = "Play",
      fontSize = 70,
      labelYOffset = -10,
      labelColor = { default={ 1, 1, 1 }, over={ 0, 0, 0, 0.5 } },
      defaultFile = "images/btn_start.png",
      overFile = "images/btn_start_over.png",      
      onEvent = onPlayTouch
    }
	)
	btn_play.x = cx
	btn_play.y = cy + 450
	sceneGroup:insert(btn_play)

end


-- show()
function scene:show( event )

    local sceneGroup = self.view
    local phase = event.phase

    if ( phase == "will" ) then
      -- Code here runs when the scene is still off screen (but is about to come on screen)

    elseif ( phase == "did" ) then
      -- Code here runs when the scene is entirely on screen

      -- This will remove the game scene when available. This is important to allow the game scene to reset itself.
      local prevScene = composer.getSceneName( "previous" )
      if(prevScene) then 
      	composer.removeScene( prevScene )
      end
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
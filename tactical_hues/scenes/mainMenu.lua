
local composer = require( "composer" )

local scene = composer.newScene()

require( "lib.relativePositioning" )
require( "lib.colorEffects" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local function gotoGame( event )
  composer.gotoScene( "scenes.game", { time = 400, effect = "crossFade", params = event.target.params } )
end

local function gotoHowToPlay( event )
  composer.gotoScene( "scenes.howToPlay", { time = 400, effect = "crossFade" } )
end

-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on LaunchScreen


  local background = display.newRect( sceneGroup, display.contentCenterX, display.contentCenterY, display.contentWidth * 2, display.contentHeight * 2 )
  setRadialGradient( background, getColorTable( "a56e17" ), getColorTable( "ffab24" ), {0.25, 0.05}, {0.5, 0.55} )

  local title = display.newText( sceneGroup, "Tactical Hues", display.contentCenterX, getAbsY( 0.2 ), native.systemFont, getAbsY( 0.08 ) )


  -- buttons
  local play1PlayerButton = display.newText( sceneGroup, "1 player", display.contentCenterX, getAbsY( 0.5 ), native.systemFont, getAbsY( 0.045 ) )
  play1PlayerButton.params = { gamemode = "pvc" }

  local play2PlayersButton = display.newText( sceneGroup, "2 players", display.contentCenterX, getAbsY( 0.6 ), native.systemFont, getAbsY( 0.045 ) )
  play1PlayerButton.params = { gamemode = "pvp" }

  local howToPlay = display.newText( sceneGroup, "How to play", display.contentCenterX, getAbsY( 0.7 ), native.systemFont, getAbsY( 0.045 ) )


  -- events
  --------------------------------------------------
  
  --play1PlayerButton:addEventListener( "tap", gotoGame )
  play1PlayerButton:setFillColor( 0.7, 0.7, 0.7 )

  --------------------------------------------------

  play2PlayersButton:addEventListener( "tap", gotoGame )

  --------------------------------------------------

  howToPlay:addEventListener( "tap", gotoHowToPlay )
  -- howToPlay:setFillColor( 0.7, 0.7, 0.7 )

  --------------------------------------------------

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen

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

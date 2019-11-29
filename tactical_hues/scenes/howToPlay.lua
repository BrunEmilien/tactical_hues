
local composer = require( "composer" )

local scene = composer.newScene()

local Item = require "src.Item"

require( "lib.relativePositioning" )

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local backGroup
local mainGroup



local onBack = "exit"

local maxScroll = 0

local sets = {}

local imageSheetOptions = {
	width = 350,
  height = 350,
  numFrames = 3,

  sheetContentWidth = 1050,
  sheetContentHeight = 350
}
local gridImageSheet = graphics.newImageSheet( "assets/gui/grid.png", imageSheetOptions )

local imageSheetOptions = {
	width = 167,
  height = 168,
  numFrames = 3,

  sheetContentWidth = 501,
  sheetContentHeight = 168
}
local actionsImageSheet = graphics.newImageSheet( "assets/gui/pawnsActions.png", imageSheetOptions )

local imageSheetOptions = {
	frames = {
		{ x = 0, y = 0, width = 335, height = 251 },
		{ x = 335, y = 0, width = 335, height = 251 },
		{ x = 335 * 2, y = 0, width = 335, height = 251 },
		{ x = 0, y = 251, width = 335, height = 251 },
		{ x = 335, y = 251, width = 335, height = 251 },
		{ x = 335 * 2, y = 251, width = 335, height = 251 },
		{ x = 0, y = 251 * 2, width = 335, height = 251 },
		{ x = 335, y = 251 * 2, width = 335, height = 251 },
		{ x = 335 * 2, y = 251 * 2, width = 335, height = 251 },
		{ x = 0, y = 251 * 3, width = 335, height = 251 },
		{ x = 335, y = 251 * 3, width = 335, height = 251 },
		{ x = 335 * 2, y = 251 * 3, width = 335, height = 251 },
		{ x = 0, y = 251 * 4, width = 335, height = 251 },
		{ x = 335, y = 251 * 4, width = 335, height = 251 }
	},

  sheetContentWidth = 1005,
  sheetContentHeight = 1255
}
local battlesImageSheet = graphics.newImageSheet( "assets/gui/pawnsBattles.png", imageSheetOptions )

local imageSheetOptions = {
	frames = {
		{ x = 0, y = 0, width = 335, height = 251 },
		{ x = 335, y = 0, width = 335, height = 251 },
		{ x = 0, y = 251, width = 335, height = 251 },
		{ x = 335, y = 251, width = 335, height = 251 },
		{ x = 335 * 2, y = 251, width = 335, height = 251 },
		{ x = 335 * 3, y = 251, width = 335, height = 251 }
	},

  sheetContentWidth = 1340,
  sheetContentHeight = 502
}
local movesImageSheet = graphics.newImageSheet( "assets/gui/pawnsMoves.png", imageSheetOptions )



local function gotoMainMenu( event )
	composer.gotoScene( "scenes.mainMenu", { time = 400, effect = "crossFade" } )
end



local function setVisibilityTo( set, visible )
	if ( set ~= nil ) then
		for i,v in ipairs( set ) do
			if ( v.display ~= nil and v.display.name == "item" ) then
				v.display:setVisible( visible )

			elseif ( visible ) then
				v.alpha = 1.0

			else
				v.alpha = 0.0
			end
		end

		if ( visible ) then
			onBack = set.onBack
		end
	end
end

local function giveVisibilityTo( set )
	for i,t in ipairs( sets ) do
		setVisibilityTo( t, false )
	end

	if ( set ~= nil ) then
		setVisibilityTo( set, true )
	end

	maxScroll = set.maxScroll
	mainGroup.y = 0
end

local function onBackKey()
	if ( onBack == "exit" ) then
		gotoMainMenu()

	elseif ( onBack == "backToSet1" ) then
		giveVisibilityTo( sets[1] )

	elseif ( onBack == "backToSet2" ) then
		giveVisibilityTo( sets[2] )
	end
end

local function onKeyEvent( event )
	if ( event.phase == "up" ) then
		if ( event.keyName == "back" ) then
			onBackKey()
			return true
		end
	end

	return false
end



local function newSet()
	local set = {}
	set.onBack = "exit"
	set.maxScroll = 0

	return set
end

local function addTextToSet( set, text, fontSize )
	fontSize = fontSize or 60

	local y = ITEM_SPACING

	if (#set > 0 and set[#set].display ~= nil and set[#set].display.name == "item") then
		y = y + set[#set].display:getY() + set[#set].display:getHeight() / 2
	else
		y = y + set[#set].y + set[#set].height / 2
	end

	local options = {
		parent = mainGroup,
		text = text,
		x = getAbsX( 0.5 ),
		y = y,
		width = getAbsX( 0.9 ),
		font = native.systemFont,
		fontSize = fontSize
	}
	local text = display.newText( options )

	text.y = text.y + text.height / 2

	table.insert( set, text )
end

-- local function addImageToSet( set, path )
-- 	local fontSize = 60
-- 	local y = ITEM_SPACING + fontSize / 2
--
-- 	if (#set > 0) then
-- 		y = y + set[#set].y + set[#set].height / 2
-- 	end
--
-- 	local image = display.newImageRect( mainGroup, path, )
-- end

local function addImageToSet( set, imageSheet, frame, relWidth )
	relWidth = relWidth or 0.9
	local fontSize = 60
	local y = ITEM_SPACING + fontSize / 2

	if (#set > 0) then
		y = y + set[#set].y + set[#set].height / 2
	end

	local image = display.newImage( mainGroup, imageSheet, frame, getAbsX( 0.5 ), y )

	local ratio = getAbsX( relWidth ) / image.width

	image.width = image.width * ratio
	image.height = image.height * ratio

	image.y = image.y + image.height / 2

	table.insert( set, image )
end



local function onScroll( event )
	local target = event.target
  local phase = event.phase

	if ( "began" == phase ) then
    display.currentStage:setFocus( target )
    mainGroup.touchOffsetY = event.y - mainGroup.y

	elseif ( "moved" == phase ) then
    mainGroup.y = math.min( 0, math.max( -maxScroll, event.y - mainGroup.touchOffsetY ) )

	elseif ( "ended" == phase or "cancelled" == phase ) then
    display.currentStage:setFocus( nil )
	end

	return true
end

local function onItemTap( event )
	if ( event.target.name == "itemHitbox" ) then
		local selection = event.target.item

		if ( sets[selection.setIndex][selection.index].data ~= nil ) then
			giveVisibilityTo( sets[selection.setIndex][selection.index].data )
		end

		return true
	end
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on LaunchScreen

	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )

	mainGroup = display.newGroup()
	sceneGroup:insert( mainGroup )



	local backMask = display.newRect( backGroup, getAbsX( 0.5 ), getAbsY( 0.5 ), getAbsX( 2.0 ), getAbsY( 2.0 ) )
	backMask.alpha = 0.0
	backMask.isHitTestable = true


	local info = {
		{ "Game flow", "Pawns actions", "Pawns specificities" },
		{ "Amber", "Blue", "Crimson", "Guardian", "Rusher" }
	}

	for i,t in ipairs( info ) do
		sets[i] = newSet()

		for j,v in ipairs( t ) do
			table.insert( sets[i], { display = Item( mainGroup, i, j, v, onItemTap ), data = nil } )
		end

		table.insert( sets[i], { display = Item( mainGroup, i, #sets[i] + 1, "Return", onBackKey ), data = nil } )
		sets[i].maxScroll = sets[i][#sets[i]].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[1][3].data = sets[2]
	sets[2].onBack = "backToSet" .. 1

	-- Game flow
	local set = newSet()
	table.insert( set, { display = Item( mainGroup, 3, 1, "Return", onBackKey ), data = nil } )
	addTextToSet( set, "In Tactical Hues you play against another player in a chess like game." )
	addTextToSet( set, "You will place and move your 5 pawns on a 6 by 6 squares grid.\nThe goal is to move a pawn to the last row and make it act to win.\n" )
	addTextToSet( set, "First you will place your pawns one by one on any square you want, as long as that square belong to one of the two first rows." )
	addImageToSet( set, gridImageSheet, 1, 0.7 )
	addTextToSet( set, "You will have to place 5 unique pawns." )
	addImageToSet( set, gridImageSheet, 2, 0.7 )
	addTextToSet( set, "Then the game start. On each one of your turns you can act twice (see \"Pawns actions\")." )
	addTextToSet( set, "When the white team's turn ends, the black team's turn starts, and so on until someone wins." )
	addImageToSet( set, gridImageSheet, 3, 0.7 )

	if ( set[#set].display ~= nil and set[#set].display.name == "item" ) then
		set.maxScroll = set[#set].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	else
		set.maxScroll = set[#set].y + set[#set].height / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[3] = set
	sets[1][1].data = set
	set.onBack = "backToSet" .. 1

	-- Pawns actions
	local set = newSet()
	table.insert( set, { display = Item( mainGroup, 3, 1, "Return", onBackKey ), data = nil } )
	addTextToSet( set, "Each pawn is unique and has specificities.\nThe type of the pawns is hidden to the other player until an action reveal it." )
	addTextToSet( set, "On each turn you can act twice." )
	addTextToSet( set, "That means you can use a pawn to move, attack or win twice." )
	addTextToSet( set, "Most of the pawns can only act once in a turn.\n" )
	addTextToSet( set, "If a pawn has not acted yet: then you can move it to a free contiguous square." )
	addImageToSet( set, actionsImageSheet, 1, 0.5 )
	addTextToSet( set, "If a foe pawn is contiguous to your pawn: you can attack it." )
	addImageToSet( set, actionsImageSheet, 3, 0.5 )
	addTextToSet( set, "If your pawn is in the last row: you will win the game on the next action of the pawn." )
	addImageToSet( set, actionsImageSheet, 2, 0.5 )
	addTextToSet( set, "Note that if a pawn attacks or has been attacked it will be revealed to the other player." )

	if ( set[#set].display ~= nil and set[#set].display.name == "item" ) then
		set.maxScroll = set[#set].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	else
		set.maxScroll = set[#set].y + set[#set].height / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[4] = set
	sets[1][2].data = set
	set.onBack = "backToSet" .. 1

	-- Amber
	local set = newSet()
	table.insert( set, { display = Item( mainGroup, 3, 1, "Return", onBackKey ), data = nil } )
	addTextToSet( set, "\"Amber\" is a basic pawn marked with letter A." )
	addTextToSet( set, "It can destroy \"Blue\" and \"Rusher\".\nBut it loses to \"Crimson\"." )
	addImageToSet( set, battlesImageSheet, 1, 0.5 )
	addImageToSet( set, battlesImageSheet, 2, 0.5 )
	addImageToSet( set, battlesImageSheet, 3, 0.5 )

	if ( set[#set].display ~= nil and set[#set].display.name == "item" ) then
		set.maxScroll = set[#set].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	else
		set.maxScroll = set[#set].y + set[#set].height / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[5] = set
	sets[2][1].data = set
	set.onBack = "backToSet" .. 2

	-- Blue
	local set = newSet()
	table.insert( set, { display = Item( mainGroup, 3, 1, "Return", onBackKey ), data = nil } )
	addTextToSet( set, "\"Blue\" is a basic pawn marked with letter B." )
	addTextToSet( set, "It can destroy \"Crimson\" and \"Rusher\".\nBut it loses to \"Amber\"." )
	addImageToSet( set, battlesImageSheet, 4, 0.5 )
	addImageToSet( set, battlesImageSheet, 5, 0.5 )
	addImageToSet( set, battlesImageSheet, 6, 0.5 )

	if ( set[#set].display ~= nil and set[#set].display.name == "item" ) then
		set.maxScroll = set[#set].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	else
		set.maxScroll = set[#set].y + set[#set].height / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[6] = set
	sets[2][2].data = set
	set.onBack = "backToSet" .. 2

	-- Crimson
	local set = newSet()
	table.insert( set, { display = Item( mainGroup, 3, 1, "Return", onBackKey ), data = nil } )
	addTextToSet( set, "\"Crimson\" is a basic pawn marked with letter C." )
	addTextToSet( set, "It can destroy \"Amber\" and \"Rusher\".\nBut it loses to \"Blue\"." )
	addImageToSet( set, battlesImageSheet, 7, 0.5 )
	addImageToSet( set, battlesImageSheet, 8, 0.5 )
	addImageToSet( set, battlesImageSheet, 9, 0.5 )

	if ( set[#set].display ~= nil and set[#set].display.name == "item" ) then
		set.maxScroll = set[#set].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	else
		set.maxScroll = set[#set].y + set[#set].height / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[7] = set
	sets[2][3].data = set
	set.onBack = "backToSet" .. 2

	-- Guardian
	local set = newSet()
	table.insert( set, { display = Item( mainGroup, 3, 1, "Return", onBackKey ), data = nil } )
	addTextToSet( set, "\"Guardian\" is a special pawn marked with letter G." )
	addTextToSet( set, "It destroys every pawn but also dies if it attacks." )
	addTextToSet( set, "Because the \"Guardian\" is basically invincible it can not grant you victory." )
	addImageToSet( set, battlesImageSheet, 13, 0.5 )
	addImageToSet( set, battlesImageSheet, 14, 0.5 )

	if ( set[#set].display ~= nil and set[#set].display.name == "item" ) then
		set.maxScroll = set[#set].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	else
		set.maxScroll = set[#set].y + set[#set].height / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[8] = set
	sets[2][4].data = set
	set.onBack = "backToSet" .. 2

	-- Rusher
	local set = newSet()
	table.insert( set, { display = Item( mainGroup, 3, 1, "Return", onBackKey ), data = nil } )
	addTextToSet( set, "\"Rusher\" is a special pawn marked with letter R." )
	addTextToSet( set, "This pawn can act twice on the same turn instead of one." )
	addTextToSet( set, "It loses to every pawn but destroys \"Rusher\" when it is attacking." )
	addImageToSet( set, battlesImageSheet, 10, 0.5 )
	addImageToSet( set, battlesImageSheet, 11, 0.5 )
	addImageToSet( set, battlesImageSheet, 12, 0.5 )

	if ( set[#set].display ~= nil and set[#set].display.name == "item" ) then
		set.maxScroll = set[#set].display:getY() + ITEM_HEIGHT / 2 + ITEM_SPACING - getAbsY( 1.0 )
	else
		set.maxScroll = set[#set].y + set[#set].height / 2 + ITEM_SPACING - getAbsY( 1.0 )
	end

	sets[9] = set
	sets[2][5].data = set
	set.onBack = "backToSet" .. 2



	giveVisibilityTo( sets[1] )


	-- buttons



	-- events
	backMask:addEventListener( "touch", onScroll )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)

	elseif ( phase == "did" ) then
		-- Code here runs when the scene is entirely on screen
		Runtime:addEventListener( "key", onKeyEvent )

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
		Runtime:removeEventListener( "key", onKeyEvent )

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

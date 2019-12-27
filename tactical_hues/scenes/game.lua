
local composer = require( "composer" )
composer.recycleOnSceneChange = true

local scene = composer.newScene()

local Grid = require "src.Grid"
local Square = require "src.Square"
local Pawn = require "src.Pawn"

require "lib.relativePositioning"
require "lib.colorEffects"
require "lib.mathPlus"
require "lib.popup"

require "src.globalParameters"

-- -----------------------------------------------------------------------------------
-- Code outside of the scene event functions below will only be executed ONCE unless
-- the scene is removed entirely (not recycled) via "composer.removeScene()"
-- -----------------------------------------------------------------------------------

local gamemode
local faceToFaceMode = false


local backGroup
local mainGroup = { back, middle, middle, middleNoFlip, front, frontNoFlip }
local uiGroup = { back, middle, front }

local popup = {}
local mask
local showButton
local skipButton
local hud

local onBack = "exit"



local pawnGrid

local pawnsTeam1 = {}
local pawnsTeam2 = {}

local selection = nil
local possibleTargets = {}
local target = nil

local setupSquaresTeam1 = {}
local setupSquaresTeam2 = {}

local playingTeam

local actionCount = 0



local function gotoMainMenu( event )
	composer.gotoScene( "scenes.mainMenu" )
end

local function onBackKey()
	if ( onBack == "exit" ) then
		onBack = nil

		if ( popup ~= nil and popup.name == "popup" ) then
			popup = removePopup( popup )
		end
		popup = newPopup( uiGroup.middle, "Return to menu", "Do you want to return to menu?", { "Yes", "No" }, onExitPopup )
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

local function flipGroup( group )
	group.xScale = -1.0
	group.yScale = -1.0
	group.x = getAbsX( 1.0 )
	group.y = getAbsY( 1.0 )
end

local function unflipGroup( group )
	group.xScale = 1.0
	group.yScale = 1.0
	group.x = getAbsX( 0.0 )
	group.y = getAbsY( 0.0 )
end

local function flipPawnsInto( group )
	for k,p in pairs( pawnsTeam1 ) do
		if ( p:getParent() == group ) then
			p:rotate( 180 )
		end
	end

	for k,p in pairs( pawnsTeam2 ) do
		if ( p:getParent() == group ) then
			p:rotate( 180 )
		end
	end
end

local function unflipPawnsInto( group )
	for k,p in pairs( pawnsTeam1 ) do
		if ( p:getParent() == group ) then
			p:setRotation( 0 )
		end
	end

	for k,p in pairs( pawnsTeam2 ) do
		if ( p:getParent() == group ) then
			p:setRotation( 0 )
		end
	end
end



function start()
	pawnGrid = Grid( mainGroup.middleNoFlip )

	init( pawnsTeam1, 1 )
	init( pawnsTeam2, 2 )

	setup( setupSquaresTeam1, pawnsTeam1 )
	setup( setupSquaresTeam2, pawnsTeam2 )

	pawnGrid:addEventListenerToSquares( onGridSquareSetupTap )

	testForSetupTurnEnd( true )
end

function testForSetupTurnEnd( start )
	start = start or false

	local setupFinished = true

	for i,s in ipairs( setupSquaresTeam1 ) do
		if ( s.pawn.name == "pawn" ) then
			setupFinished = false
			break
		end
	end

	if ( setupFinished ) then
		for i,s in ipairs( setupSquaresTeam2 ) do
			if ( s.pawn.name == "pawn" ) then
				setupFinished = false
				break
			end
		end
	end

	if ( setupFinished ) then
		for i,s in ipairs( setupSquaresTeam1 ) do
			s:setHighlight( nil )
		end
		for i,s in ipairs( setupSquaresTeam2 ) do
			s:setHighlight( nil )
		end

		playingTeam = 1

		pawnGrid:removeEventListenerToSquares( onGridSquareSetupTap )
		pawnGrid:addEventListenerToSquares( onGridSquareTap )

		newTurnBegin( false )

	elseif ( start ) then
		playingTeam = 1
		setupTurn( setupSquaresTeam1, pawnsTeam1, setupSquaresTeam2 )

	else
		if ( playingTeam == 1 ) then
			playingTeam = 2
			setupTurn( setupSquaresTeam2, pawnsTeam2, setupSquaresTeam1 )

		else
			playingTeam = 1
			setupTurn( setupSquaresTeam1, pawnsTeam1, setupSquaresTeam2 )
		end
	end
end

function init( teamPawns, team )
	teamPawns.amber = Pawn( mainGroup.front, "amber", team, 1, 1, true, { attacking = { "blue", "rusher" }, defending = { "blue", "guardian", "rusher" } } )
	teamPawns.blue = Pawn( mainGroup.front, "blue", team, 2, 1, true, { attacking = { "crimson", "rusher" }, defending = { "crimson", "guardian", "rusher" } } )
	teamPawns.crimson = Pawn( mainGroup.front, "crimson", team, 3, 1, true, { attacking = { "amber", "rusher" }, defending = { "amber", "guardian", "rusher" } } )
	teamPawns.guardian = Pawn( mainGroup.front, "guardian", team, 4, 1, false, { attacking = { "amber", "blue", "crimson", "guardian", "rusher" }, defending = { "amber", "blue", "crimson", "guardian", "rusher" } } )
	teamPawns.rusher = Pawn( mainGroup.front, "rusher", team, 5, 2, true, { attacking = { "rusher" }, defending = { "guardian" } } )
end

function setup( teamSetupSquares, teamPawns )
	local width = math.min( DEFAULT_PAWN_WIDTH, getAbsX( 1 / 6 ) )
	local y = getAbsY( 0.5 ) + getAbsX( ( BOARD_WIDTH / 2 ) + BOARD_OFFSET ) + width / 2

	table.insert( teamSetupSquares, Square( mainGroup.back, getAbsX( 1.0 * ( 0.5 / 5 ) ), y, width, width ) )
	table.insert( teamSetupSquares, Square( mainGroup.back, getAbsX( 1.0 * ( 1.5 / 5 ) ), y, width, width ) )
	table.insert( teamSetupSquares, Square( mainGroup.back, getAbsX( 1.0 * ( 2.5 / 5 ) ), y, width, width ) )
	table.insert( teamSetupSquares, Square( mainGroup.back, getAbsX( 1.0 * ( 3.5 / 5 ) ), y, width, width ) )
	table.insert( teamSetupSquares, Square( mainGroup.back, getAbsX( 1.0 * ( 4.5 / 5 ) ), y, width, width ) )

	for i,s in ipairs( teamSetupSquares ) do
		s:setHighlight( HIGHLIGHT_COLOR_MOVE )
		s:addEventListener( onSetupSquareTap )
	end

	local n = 5
	for k,p in pairs( teamPawns ) do
		local i = math.random( n )

		local square = teamSetupSquares[i]
		while ( square.pawn.name == "pawn" and i < 5 ) do
			i = i + 1
			square = teamSetupSquares[i]
		end
		n = n - 1

		p:moves( square, true )
	end
end

function setupTurn( playingTeamSetupSquares, playingTeamPawns, otherTeamSetup )
	if ( faceToFaceMode and playingTeam == 1 ) then
		unflipGroup( mainGroup.back )
		unflipGroup( mainGroup.middle )
		unflipGroup( mainGroup.front )
		unflipGroup( uiGroup.back )
		unflipGroup( uiGroup.middle )
		unflipGroup( uiGroup.front )

		unflipPawnsInto( mainGroup.frontNoFlip )

	elseif ( faceToFaceMode ) then
		flipGroup( mainGroup.back )
		flipGroup( mainGroup.middle )
		flipGroup( mainGroup.front )
		flipGroup( uiGroup.back )
		flipGroup( uiGroup.middle )
		flipGroup( uiGroup.front )

		flipPawnsInto( mainGroup.frontNoFlip )
	end

	for i,s in ipairs( otherTeamSetup ) do
		s:setHighlight( false )

		if ( s.pawn.name == "pawn" ) then
			s.pawn:setVisibility( false )
		end
	end

	for i,s in ipairs( playingTeamSetupSquares ) do
		if ( s.pawn.name == "pawn" ) then
			s:setHighlight( HIGHLIGHT_COLOR_MOVE )
		end
	end

	for k,p in pairs( playingTeamPawns ) do
		p:setVisibility( true )
	end

	pawnGrid:refreshPawnsVisibility()

	onBack = nil
	local teamName
	local teamNameCap
	if ( playingTeam == 1 ) then
		teamName = "white"
		teamNameCap = "White"
	else
		teamName = "black"
		teamNameCap = "Black"
	end

	popup = newPopup( uiGroup.middle, teamNameCap .. " turn", "If you play as " .. teamName .. "\nClick Ok to play", { "Ok" },
		function()
			for k,p in pairs( playingTeamPawns ) do
				p:showRevealed()
			end

			popup = removePopup( popup )

			onBack = "exit"

			return true
		end
	)

	refreshHud( true )
end

function testForTurnEnd( force )
	force = force or false

	actionCount = actionCount + 1

	refreshHud( true, true )

	if ( not teamAbleToWin( 1 ) ) then
		victory( 2, true )

	elseif ( not teamAbleToWin( 2 ) ) then
		victory( 1, true )

	elseif ( force or not teamAbleToAct() or actionCount >= ACTIONS_PER_TURN ) then
		actionCount = 0

		if ( playingTeam == 1 ) then
			playingTeam = 2
		else
			playingTeam = 1
		end

		newTurnBegin( not force )

	else
		skipButton.background.alpha = 1.0
		skipButton.text.alpha = 1.0
	end
end

function newTurnBegin( delayed )
	delayed = delayed or false
	local delay = 0

	if ( delayed ) then
		delay = 2000
	end

	if ( faceToFaceMode and playingTeam == 1 ) then
		unflipGroup( mainGroup.back )
		unflipGroup( mainGroup.middle )
		unflipGroup( mainGroup.front )
		unflipGroup( uiGroup.back )
		unflipGroup( uiGroup.middle )
		unflipGroup( uiGroup.front )

		unflipPawnsInto( mainGroup.frontNoFlip )

	elseif ( faceToFaceMode ) then
		flipGroup( mainGroup.back )
		flipGroup( mainGroup.middle )
		flipGroup( mainGroup.front )
		flipGroup( uiGroup.back )
		flipGroup( uiGroup.middle )
		flipGroup( uiGroup.front )

		flipPawnsInto( mainGroup.frontNoFlip )
	end

	showButton.background.alpha = 1.0
	showButton.text.alpha = 1.0
	resetShowButton()

	skipButton.background.alpha = 0.0
	skipButton.text.alpha = 0.0

	mask.isHitTestable = true

	pawnGrid:newTurn()
	pawnGrid:refreshHighlights()
	pawnGrid:refreshPawnsVisibility()

	onBack = nil
	local teamName
	local teamNameCap
	if ( playingTeam == 1 ) then
		teamName = "white"
		teamNameCap = "White"
	else
		teamName = "black"
		teamNameCap = "Black"
	end

	timer.performWithDelay( delay,
		function()
			popup = newPopup( uiGroup.middle, teamNameCap .. " turn", "If you play as " .. teamName .. "\nClick Ok to play", { "Ok" },
				function()
					popup = removePopup( popup )

					onBack = "exit"

					return true
				end
			)

			mask.isHitTestable = false
			refreshHud( true, true )
		end
	)
end

function teamAbleToAct()
	local playingTeamPawns

	if ( playingTeam == 1 ) then
		playingTeamPawns = pawnsTeam1
	else
		playingTeamPawns = pawnsTeam2
	end

	for k,p in pairs( playingTeamPawns ) do
		if ( p:canAct() ) then
			return true
		end
	end

	return false
end

function teamAbleToWin( team )
	local teamPawns

	if ( team == 1 ) then
		teamPawns = pawnsTeam1
	else
		teamPawns = pawnsTeam2
	end

	for k,p in pairs( teamPawns ) do
		if ( p:isAbleToWin() ) then
			return true
		end
	end

	return false
end

function victory( team, delayed )
	delayed = delayed or false
	local delay = 0

	if ( delayed ) then
		delay = 2000
	end

	mask.isHitTestable = true

	onBack = nil
	local teamName
	local teamNameCap
	if ( playingTeam == 1 ) then
		teamName = "white"
		teamNameCap = "White"
	else
		teamName = "black"
		teamNameCap = "Black"
	end

	timer.performWithDelay( delay,
		function()
			popup = newPopup( uiGroup.middle, teamNameCap .. " wins", "Congratulations!\nClick Ok to return to menu", { "Ok" },
				function()
					gotoMainMenu()

					return true
				end
			)

			mask.isHitTestable = false
		end
	)
end

function refreshHud( team, actions )
	team = team or false
	actions = actions or false

	local text = ""

	if ( team ) then
		if ( playingTeam == 1 ) then
			text = text .. "White turn"
		else
			text = text .. "Black turn"
		end
	end

	if ( actions ) then
		if ( team ) then
			text = text .. "\n"
		end

		text = text .. "Actions remaining: " .. ACTIONS_PER_TURN - actionCount
	end

	hud.text = text
end



function onGridSquareTap( event )
	if ( event.target.name == "squareHitbox" and event.target.square.name == "square" ) then
		local square = event.target.square
		local actionPerformed = false

		if ( square.pawn.name == "pawn" and square.pawn.team == playingTeam ) then
			possibleTargets = {}
			target = nil

			pawnGrid:refreshHighlights()

			if ( selection == square ) then
				selection = nil

				return true;
			end

			selection = square

			if ( selection.pawn:canWin() ) then

				if ( selection.pawn:wins() ) then
					victory( selection.pawn.team )
				end

				selection = nil

			elseif ( selection.pawn:canAct() ) then

				selection:setHighlight( HIGHLIGHT_COLOR_SELECTION )

				for i=1,4 do
					local square = pawnGrid:getSquare( selection.row + round( math.sin( math.pi * i / 2 ) ), selection.column + round( math.cos( math.pi * i / 2 ) ) )

					if ( square ~= nil ) then
						if ( square:canMoveTo() ) then
							table.insert( possibleTargets, { ["target"] = square, ["action"] = "move" } )
							square:setHighlight( HIGHLIGHT_COLOR_MOVE )

						elseif ( square.pawn.name == "pawn" and square.pawn.team ~= selection.pawn.team ) then
							table.insert( possibleTargets, { ["target"] = square, ["action"] = "attack" } )
							square:setHighlight( HIGHLIGHT_COLOR_ATTACK )

						end
					end
				end

			end

		elseif ( selection ~= nil ) then

			target = square

			local targetValid = false
			local action

			for i,v in ipairs( possibleTargets ) do
				if ( v.target == target ) then
					targetValid = true
					action = v.action
					break
				end
			end

			if ( targetValid ) then
				if ( action == "move" ) then
					selection.pawn:moves( target )

				elseif ( action == "attack" ) then
					selection.pawn:attacks( target.pawn )
				end

				actionPerformed = true
			end

			selection = nil

			possibleTargets = {}
			target = nil

			pawnGrid:refreshHighlights()

		end

		if ( actionPerformed ) then
			testForTurnEnd()
		end

		return true
	end
end

function onSetupSquareTap( event )
	if ( event.target.name == "squareHitbox" and event.target.square.name == "square" ) then
		local square = event.target.square

		if ( selection ~= nil ) then
			possibleTargets = {}

			if ( selection.name == "square" and selection.pawn.name == "pawn" ) then
				selection:setHighlight( HIGHLIGHT_COLOR_MOVE )
			else
				selection:setHighlight( false )
			end

			if ( selection == square ) then
				selection = nil;
				pawnGrid:refreshHighlights()

				return true;
			end
		end

		if ( square.pawn.name == "pawn" ) then

			selection = square

			selection:setHighlight( HIGHLIGHT_COLOR_SELECTION )

			pawnGrid:refreshHighlights()

			for r=1,2 do
				local row = r

				if ( selection.pawn.team == 1 ) then
					row = GRID_SIZE - r + 1
				end

				for column=1,GRID_SIZE do
					local square = pawnGrid:getSquare( row, column )

					if ( square:canMoveTo() ) then
						table.insert( possibleTargets, { ["target"] = square, ["action"] = "move" } )
						square:setHighlight( HIGHLIGHT_COLOR_MOVE )

					else
						square:setHighlight( HIGHLIGHT_COLOR_UNAVAILABLE )
					end
				end
			end

		end

		return true
	end
end

function onGridSquareSetupTap( event )
	if ( event.target.name == "squareHitbox" and event.target.square.name == "square" ) then
		target = event.target.square

		local targetValid = false

		for i,v in ipairs( possibleTargets ) do
			if ( v.target == target ) then
				targetValid = true
				break
			end
		end

		if ( targetValid ) then
			local pawn  = selection.pawn
			pawn:moves( target, true )
			pawn:setParent( mainGroup.frontNoFlip )

			selection:setHighlight( false )
			selection = nil

			possibleTargets = {}
			target = nil

			pawnGrid:refreshHighlights()
			pawnGrid:refreshPawnsVisibility()

			testForSetupTurnEnd()
		end

		return true
	end
end

function onFaceToFacePopup( event )
	if ( event.target.name == "buttonHitbox" and event.target.button.name == "button" ) then
		local button = event.target.button

		if ( button.title == "Yes" ) then
			faceToFaceMode = true
			onBack = "exit"
			popup = removePopup( popup )
			start()

		elseif ( button.title == "No" ) then
			onBack = "exit"
			popup = removePopup( popup )
			start()
		end

		return true
	end
end

function onExitPopup( event )
	if ( event.target.name == "buttonHitbox" and event.target.button.name == "button" ) then
		local button = event.target.button

		if ( button.title == "Yes" ) then
			gotoMainMenu()

		elseif ( button.title == "No" ) then
			onBack = "exit"
			popup = removePopup( popup )
		end

		return true
	end
end

function onShowButton( event )
	if ( event.target.name == "buttonHitbox" and event.target.button.name == "button") then
		local button = event.target.button

		if ( button.state == "off" ) then
			local teamPawns
			if ( playingTeam == 1 ) then
				teamPawns = pawnsTeam1
			else
				teamPawns = pawnsTeam2
			end

			for k,p in pairs( teamPawns ) do
				p:showRevealed();
			end

			button.state = "on"
			button.text.text = "Hide pawns"

		else
			pawnGrid:refreshPawnsVisibility()

			button.state = "off"
			button.text.text = "Show pawns"
		end

		return true
	end
end

function onSkipButton( event )
	if ( event.target.name == "buttonHitbox" and event.target.button.name == "button") then
		testForTurnEnd( true )

		return true
	end
end

function resetShowButton()
	showButton.state = "off"
	showButton.text.text = "Show pawns"
end



-- -----------------------------------------------------------------------------------
-- Scene event functions
-- -----------------------------------------------------------------------------------

-- create()
function scene:create( event )

	if ( event.params ~= nil and event.params.gamemode ~= nil ) then
		gamemode = event.params.gamemode
	else
		gamemode = "pvc"
	end

	local sceneGroup = self.view
	-- Code here runs when the scene is first created but has not yet appeared on LaunchScreen

	backGroup = display.newGroup()
	sceneGroup:insert( backGroup )

	mainGroup.back = display.newGroup()
	sceneGroup:insert( mainGroup.back )

	mainGroup.middle = display.newGroup()
	sceneGroup:insert( mainGroup.middle )

	mainGroup.middleNoFlip = display.newGroup()
	sceneGroup:insert( mainGroup.middleNoFlip )

	mainGroup.front = display.newGroup()
	sceneGroup:insert( mainGroup.front )

	mainGroup.frontNoFlip = display.newGroup()
	sceneGroup:insert( mainGroup.frontNoFlip )

	uiGroup.back = display.newGroup()
	sceneGroup:insert( uiGroup.back )

	uiGroup.middle = display.newGroup()
	sceneGroup:insert( uiGroup.middle )

	uiGroup.front = display.newGroup()
	sceneGroup:insert( uiGroup.front )


	-- back layer
  local background = display.newRect( backGroup, getAbsX( 0.5 ), getAbsY( 0.5 ), getAbsX( 2.0 ), getAbsY( 2.0 ) )
  setRadialGradient( background, getColorTable( "a56e17" ), getColorTable( "ffab24" ), {0.25, 0.05} )

	local boardBackground = display.newRect( backGroup, getAbsX( 0.5 ), getAbsY( 0.5 ), getAbsX( BOARD_WIDTH + BOARD_OFFSET ), getAbsX( BOARD_WIDTH + BOARD_OFFSET ) )
	boardBackground:setFillColor( getColorValues( "754319" ) )
	boardBackground.fill.blendMode = "multiply"


	-- main layer
	local boardBackgroundShadow = display.newLine( backGroup,
		getAbsX( 0.5 - ( BOARD_WIDTH + BOARD_OFFSET ) / 2 ), getAbsY( 0.5 ) + getAbsX(( BOARD_WIDTH + BOARD_OFFSET ) / 2 ),
		getAbsX( 0.5 + ( BOARD_WIDTH + BOARD_OFFSET ) / 2 ), getAbsY( 0.5 ) + getAbsX(( BOARD_WIDTH + BOARD_OFFSET ) / 2 ),
		getAbsX( 0.5 + ( BOARD_WIDTH + BOARD_OFFSET ) / 2 ), getAbsY( 0.5 ) - getAbsX(( BOARD_WIDTH + BOARD_OFFSET ) / 2 )
	)
	boardBackgroundShadow:setStrokeColor( 0, 0, 0, 0.4 )
	boardBackgroundShadow.strokeWidth = 6

	local boardBackgroundGlow = display.newLine( backGroup,
		getAbsX( 0.5 - ( BOARD_WIDTH + BOARD_OFFSET ) / 2 ), getAbsY( 0.5 ) + getAbsX(( BOARD_WIDTH + BOARD_OFFSET ) / 2 ),
		getAbsX( 0.5 - ( BOARD_WIDTH + BOARD_OFFSET ) / 2 ), getAbsY( 0.5 ) - getAbsX(( BOARD_WIDTH + BOARD_OFFSET ) / 2 ),
		getAbsX( 0.5 + ( BOARD_WIDTH + BOARD_OFFSET ) / 2 ), getAbsY( 0.5 ) - getAbsX(( BOARD_WIDTH + BOARD_OFFSET ) / 2 )
	)
	boardBackgroundGlow:setStrokeColor( 1, 1, 1, 0.4 )
	boardBackgroundGlow.strokeWidth = 6

	local boardGrid = {}
	for i = 0, GRID_SIZE * GRID_SIZE - 1 do
		local x = getAbsX( 0.5 ) + getAbsX( - ( BOARD_WIDTH * ( GRID_SIZE / 2 - 0.5 ) / GRID_SIZE )
			+ ( BOARD_WIDTH / GRID_SIZE * ( i % GRID_SIZE ) ) )
		local y = getAbsY( 0.5 ) + getAbsX( - ( BOARD_WIDTH * ( GRID_SIZE / 2 - 0.5 ) / GRID_SIZE )
			+ ( BOARD_WIDTH / GRID_SIZE * math.floor( i / GRID_SIZE ) ) )

		local square = display.newRect( backGroup, x, y, getAbsX( BOARD_WIDTH / GRID_SIZE ), getAbsX( BOARD_WIDTH / GRID_SIZE ) )

		if ( ( i % GRID_SIZE + math.floor( i / GRID_SIZE ) ) % 2 == 0 ) then
			-- light
			square:setFillColor( getColorValues( "d4bea0" ) )
		else
			-- dark
			square:setFillColor( getColorValues( "26180b" ) )
		end

		table.insert( boardGrid, square )
	end


	-- ui layer
	hudOptions = {
		parent = uiGroup.back,
		text = "",
		x = getAbsX( 0.5 ),
		y = ( getAbsY( 0.5 ) - getAbsX( BOARD_WIDTH / 2 ) ) / 2,
		width = getAbsX( 0.8 ),
		font = native.systemFont,
		fontSize = 70,
		align = "left"
	}
	hud = display.newText( hudOptions )
	hud:setFillColor( 1.0, 1.0, 1.0 )

	mask = display.newRect( uiGroup.front, getAbsX( 0.5 ), getAbsY( 0.5 ), getAbsX( 2.0 ), getAbsY( 2.0 ) )
	mask.alpha = 0.0
	mask:addEventListener( "tap", function() return true end )
	mask:addEventListener( "touch", function() return true end )


	-- buttons
	showButton = {}
	showButton.name = "button"
	showButton.state = "off"

	showButton.background = display.newRoundedRect( uiGroup.back, getAbsX( 1 / 4 ), getAbsY( 0.75 ) + getAbsX( BOARD_WIDTH / 4 ),
		getAbsX( 1 / 2 * 0.8 ), ( getAbsY( 0.5 ) - getAbsX( BOARD_WIDTH / 2 ) ) * 0.6, 20 )
	showButton.background:setFillColor( 1.0, 1.0, 1.0, 0.3 )
	showButton.background:setStrokeColor( 1.0, 1.0, 1.0 )
	showButton.background.strokeWidth = 6
	showButton.background.alpha = 0.0
	showButton.background.name = "buttonHitbox"
	showButton.background.button = showButton

	showButton.text = display.newText( uiGroup.back, "Show pawns", getAbsX( 1 / 4 ), getAbsY( 0.75 ) + getAbsX( BOARD_WIDTH / 4 ), native.systemFont, 70)
	showButton.text.alpha = 0.0

	skipButton = {}
	skipButton.name = "button"

	skipButton.background = display.newRoundedRect( uiGroup.back, getAbsX( 3 / 4 ), getAbsY( 0.75 ) + getAbsX( BOARD_WIDTH / 4 ),
		getAbsX( 1 / 2 * 0.8 ), ( getAbsY( 0.5 ) - getAbsX( BOARD_WIDTH / 2 ) ) * 0.6, 20 )
	skipButton.background:setFillColor( 1.0, 1.0, 1.0, 0.3 )
	skipButton.background:setStrokeColor( 1.0, 1.0, 1.0 )
	skipButton.background.strokeWidth = 6
	skipButton.background.alpha = 0.0
	skipButton.background.name = "buttonHitbox"
	skipButton.background.button = skipButton

	skipButton.text = display.newText( uiGroup.back, "Skip turn", getAbsX( 3 / 4 ), getAbsY( 0.75 ) + getAbsX( BOARD_WIDTH / 4 ), native.systemFont, 70)
	skipButton.text.alpha = 0.0


	-- events
	showButton.background:addEventListener( "tap", onShowButton )
	skipButton.background:addEventListener( "tap", onSkipButton )

end


-- show()
function scene:show( event )

	local sceneGroup = self.view
	local phase = event.phase

	if ( phase == "will" ) then
		-- Code here runs when the scene is still off screen (but is about to come on screen)
		onBack = nil
		popup = newPopup( uiGroup.middle, "Face to face mode", "Do you want to activate the face to face mode?", { "Yes", "No" }, onFaceToFacePopup )

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

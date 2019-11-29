
require "lib.relativePositioning"

POPUP_WIDTH = 0.8
POPUP_HEIGHT = 0.4

function newPopup( parent, title, description, buttons, callback )
	local popup = {}
	popup.name = "popup"

	popup.mask = display.newRect( parent, getAbsX( 0.5 ), getAbsY( 0.5 ), getAbsX( 2.0 ), getAbsY( 2.0 ) )
	popup.mask:setFillColor( 0.0, 0.0, 0.0, 0.5 )
	popup.mask:addEventListener( "tap", function() return true end )
	popup.mask:addEventListener( "touch", function() return true end )

	popup.background = display.newRoundedRect( parent, getAbsX( 0.5 ), getAbsY( 0.5 ), getAbsX( POPUP_WIDTH ), getAbsY( POPUP_HEIGHT ), 50 )
	popup.background:setFillColor( getColorValues( "a56e17f0" ) )
	popup.background:setStrokeColor( 1.0, 1.0, 1.0 )
	popup.background.strokeWidth = 6

	popupTitleOptions = {
		parent = parent,
		text = title,
		x = getAbsX( 0.5 ),
		y = getAbsY( 0.5 - ( POPUP_HEIGHT / 2 ) ) + 120,
		width = getAbsX( POPUP_WIDTH ) - 100,
		height = 0,
		font = native.systemFontBold,
		fontSize = 80,
		align = "center"
	}
	popup.title = display.newText( popupTitleOptions )

	popupDescriptionOptions = {
		parent = parent,
		text = description,
		x = getAbsX( 0.5 ),
		y = getAbsY( 0.5 ),
		width = getAbsX( POPUP_WIDTH ) - 100,
		height = getAbsY( POPUP_HEIGHT ) - 500,
		font = native.systemFontBold,
		fontSize = 70,
		align = "left"
	}
	popup.description = display.newText( popupDescriptionOptions )
	popup.description:setFillColor( 0.9, 0.9, 0.9 )

	popup.buttons = {}

	for i=1,#buttons do
		local buttontitle = buttons[i]
		local wMax = getAbsX( POPUP_WIDTH / #buttons )
		local w = math.min( wMax * 0.8, 250 )
		local x = getAbsX( 0.5 - ( POPUP_WIDTH / 2 ) ) + ( wMax * ( i - 0.5 ) )

		local button = {}
		button.name = "button"
		button.title = buttontitle

		button.background = display.newRoundedRect( parent, x, getAbsY( 0.5 + ( POPUP_HEIGHT / 2 ) ) - 100, w, 130, 10 )
		button.background:setFillColor( 1.0, 1.0, 1.0 )
		button.background:setStrokeColor( 0.0, 0.7, 0.7 )
		button.background.strokeWidth = 6
		button.background.name = "buttonHitbox"
		button.background.button = button

		buttonTextOptions = {
			parent = parent,
			text = buttontitle,
			x = x,
			y = getAbsY( 0.5 + ( POPUP_HEIGHT / 2 ) ) - 100,
			font = native.systemFont,
			fontSize = 60
		}
		button.text = display.newText( buttonTextOptions )
		button.text:setFillColor( 0.0, 0.0, 0.0 )

		button.background:addEventListener( "tap", callback )

	  table.insert(	popup.buttons, button )
	end

	return popup
end

function removePopup( popup )
  popup.mask:removeSelf()
	popup.background:removeSelf()
	popup.title:removeSelf()
	popup.description:removeSelf()

	for i=1,#popup.buttons do
		local button = popup.buttons[i]

		button.background:removeSelf()
		button.text:removeSelf()
	end

	return {}
end

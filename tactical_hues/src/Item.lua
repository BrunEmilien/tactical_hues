
ITEM_HEIGHT = 110
ITEM_SPACING = 35

---- MODULE

local Item = {}

Item.__index = Item
setmetatable( Item, Item )



-- METHODS

function Item:new( parent, setIndex, index, title, callbackOnTap )

  self.name = "item"
  self.setIndex = setIndex
  self.index = index
	self.title = title

	self.back = display.newRect( parent, getAbsX( 0.5 ), ( ITEM_HEIGHT + ITEM_SPACING ) * index - ITEM_HEIGHT / 2,
		getAbsX( 0.95 ), ITEM_HEIGHT )
  if ( title == "Return" ) then
    self.back:setFillColor( 0.3, 0.3, 0.3 )
  else
    self.back:setFillColor( 0.5, 0.5, 0.5 )
  end
	self.back:setStrokeColor( 0.8, 0.8, 0.8 )
	self.back.strokeWidth = 6
	self.back.name = "itemHitbox"
	self.back.item = self
	self.back.alpha = 0.0

	itemTextOptions = {
		parent = parent,
		text = title,
		x = getAbsX( 0.5 ),
		y = ( ITEM_HEIGHT + ITEM_SPACING ) * index - ITEM_HEIGHT / 2,
		width = getAbsX( 0.9 ),
    font = native.systemFont,
    fontSize = 70,
		align = "left"
	}
	self.text = display.newText( itemTextOptions )
  self.text:setFillColor( 1.0, 1.0, 1.0 )
	self.text.alpha = 0.0

	if ( callbackOnTap ~= nil ) then
		self.back:addEventListener( "tap", callbackOnTap )
	end

end

function Item:setVisible( visible )
  local alpha = 0.0

  if ( visible ) then
    alpha = 1.0
  end

  self.back.alpha = alpha
  self.text.alpha = alpha
end

function Item:getY()
  return self.back.y
end

function Item:getHeight()
  return self.back.height
end



-- META METHODS

function Item:__call( ... )

  local inst = setmetatable( {}, self )

  inst:new( ... )

  return inst

end



return Item

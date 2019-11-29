
---- MODULE

local Square = {}

Square.__index = Square
setmetatable( Square, Square )



-- METHODS

function Square:new( displayGroup, x, y, w, h, row, column, isHitTestable )

  x = x or 0
  y = y or 0
  w = w or 0
  h = h or 0
  row = row or 1
  column = column or 1
  isHitTestable = isHitTestable or false

  self.name = "square"

  self.x = x
  self.y = y
  self.w = w
  self.h = h
  self.row = row
  self.column = column
  self.pawn = {}

  self.highlight = display.newRect( displayGroup, self.x, self.y, self.w * HIGHLIGHT_WIDTH, self.h * HIGHLIGHT_WIDTH )
  self.highlight:setFillColor( unpack( HIGHLIGHT_COLOR_UNAVAILABLE ) )
  self.highlight.alpha = 0.0
  self.highlight.isHitTestable = isHitTestable
  self.highlight.name = "squareHitbox"
  self.highlight.square = self

end

function Square:setHighlight( color )
  color = color or false

  if ( color == false ) then
    self.highlight.alpha = 0.0

  else
    self.highlight:setFillColor( unpack( color ) )
    self.highlight.alpha = 1.0
  end
end

function Square:refreshHighlight()
  if ( self.pawn.name == "pawn" ) then
    if ( self.pawn:canWin() ) then
      self:setHighlight( HIGHLIGHT_COLOR_WIN )
      self.highlight.alpha = 1.0

    elseif ( not self.pawn:canAct() ) then
      self:setHighlight( HIGHLIGHT_COLOR_UNAVAILABLE )
      self.highlight.alpha = 1.0

    else
      self.highlight.alpha = 0.0
    end

  else
    self.highlight.alpha = 0.0
  end
end

function Square:setPawn( pawn )
  pawn = pawn or {}

  self.pawn = pawn
end

function Square:canMoveTo()
  if ( self.pawn.name == "pawn" ) then
    return false
  else
    return true
  end
end

function Square:addEventListener( listener )
  self.highlight:addEventListener( "tap", listener )
end

function Square:removeEventListener( listener )
  self.highlight:removeEventListener( "tap", listener )
end



-- META METHODS

function Square:__call( ... )

  local inst = setmetatable( {}, self )

  inst:new( ... )

  return inst

end



return Square

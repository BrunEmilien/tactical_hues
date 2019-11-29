
local Square = require "src.Square"

---- MODULE

local Grid = {}

Grid.__index = Grid
setmetatable( Grid, Grid )



-- METHODS

function Grid:new( displayGroup )

  self.squares = {}

  for row = 1, GRID_SIZE do
    table.insert( self.squares, {} )

    for column = 1, GRID_SIZE do
      local x = getAbsX( 0.5 ) + getAbsX( - ( BOARD_WIDTH * ( GRID_SIZE / 2 - 0.5 ) / GRID_SIZE )
        + ( BOARD_WIDTH / GRID_SIZE * ( column - 1 ) ) )
  		local y = getAbsY( 0.5 ) + getAbsX( - ( BOARD_WIDTH * ( GRID_SIZE / 2 - 0.5 ) / GRID_SIZE )
  			+ ( BOARD_WIDTH / GRID_SIZE * ( row - 1 ) ) )
      local w = getAbsX( ( BOARD_WIDTH / GRID_SIZE ) * HIGHLIGHT_WIDTH )

      table.insert( self.squares[row], Square( displayGroup, x, y, w, w, row, column, true ) )
    end
  end

end

function Grid:unhighlightAll()
  for i, row in ipairs( self.squares ) do
    for i, s in ipairs( row ) do
      s:setHighlight( false )
    end
  end
end

function Grid:refreshHighlights()
  for i, row in ipairs( self.squares ) do
    for i, s in ipairs( row ) do
      s:refreshHighlight()
    end
  end
end

function Grid:setRowHighlight( row, color )
  if ( row ~= nil and ( row >= 1 and row <= GRID_SIZE ) ) then

    for i, s in ipairs( self.squares[row] ) do
      s:setHighlight( color )
    end
  end
end

function Grid:getSquare( row, column )
  if ( row == nil or column == nil ) then
    return nil
  end

  row = math.floor( row )
  column = math.floor( column )

  if ( not ( row >= 1 and row <= GRID_SIZE and column >= 1 and column <= GRID_SIZE ) ) then
    return nil
  end

  return self.squares[row][column]
end

function Grid:canMoveTo( row, column )
  return self:getSquare( row, column ):canMoveTo()
end

function Grid:addEventListenerToSquares( listener )
  for i, row in ipairs( self.squares ) do
    for i, s in ipairs( row ) do
      s:addEventListener( listener )
    end
  end
end

function Grid:removeEventListenerToSquares( listener )
  for i, row in ipairs( self.squares ) do
    for i, s in ipairs( row ) do
      s:removeEventListener( listener )
    end
  end
end

function Grid:refreshPawnsVisibility()
  for i, row in ipairs( self.squares ) do
    for i, s in ipairs( row ) do

      local pawn = s.pawn

      if ( pawn.name == "pawn" ) then
        pawn:setVisibility( true )
      end

    end
  end
end

function Grid:newTurn()
  for i, row in ipairs( self.squares ) do
    for i, s in ipairs( row ) do

      local pawn = s.pawn

      if ( pawn.name == "pawn" ) then
        pawn:newTurn()
      end

    end
  end
end



-- META METHODS

function Grid:__call( ... )

  local inst = setmetatable( {}, self )

  inst:new( ... )

  return inst

end



return Grid

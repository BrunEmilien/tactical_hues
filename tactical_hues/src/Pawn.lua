
---- MODULE

local Pawn = {}

Pawn.__index = Pawn
setmetatable( Pawn, Pawn )


local pawnSheetOptions = {
  width = 180,
  height = 180,
  numFrames = 15
}
local pawnImageSheet = graphics.newImageSheet( "assets/textures/pawns.png", pawnSheetOptions )



-- METHODS

function Pawn:new( displayGroup, type, team, number, actionsPerTurn, couldWin, defeats )

  canWin = canWin or true
  defeats = defeats or { attacking = {}, defending = {} }

  self.name = "pawn"

  self.type = type
  self.team = team
  self.actionsPerTurn = actionsPerTurn
  self.couldWin = couldWin
  self.defeats = defeats

  self.revealed = false
  self.alive = true
  self.acted = 0

  self.container = {}
  self.x = 0
  self.y = 0
  self.w = 0
  self.h = 0

  self.images = {
    unrevealedPawn = display.newImageRect( displayGroup, pawnImageSheet, UNREVEALED_PAWN_INDEX + team - 1, self.w, self.h ),
    pawn = display.newImageRect( displayGroup, pawnImageSheet, ( team - 1 ) * 5 + number, self.w, self.h )
  }

  self:adaptImages()

  self.images.unrevealedPawn.alpha = 0.0
  self.images.pawn.alpha = 0.0

end

function Pawn:adaptImages()
  self.images.unrevealedPawn.x = self.x
  self.images.unrevealedPawn.y = self.y
  self.images.unrevealedPawn.width = self.w
  self.images.unrevealedPawn.height = self.h

  self.images.pawn.x = self.x
  self.images.pawn.y = self.y
  self.images.pawn.width = self.w
  self.images.pawn.height = self.h
end

function Pawn:setContainer( container )
  container = container or {}

  if ( self.container.name == "square" ) then
    self.container:setPawn( nil )
  end

  self.container = container

  if ( container.name == "square" ) then
    self.x = self.container.x
    self.y = self.container.y
    self.w = self.container.w
    self.h = self.container.h

    self:adaptImages()

    self.container:setPawn( self )
  end
end

function Pawn:setVisibility( visible )
  if ( visible and self.alive ) then

    if ( self.revealed ) then
      self.images.unrevealedPawn.alpha = 0.0
      self.images.pawn.alpha = 1.0

    else
      self.images.unrevealedPawn.alpha = 1.0
      self.images.pawn.alpha = 0.0
    end

  else
    self.images.unrevealedPawn.alpha = 0.0
    self.images.pawn.alpha = 0.0
  end
end

function Pawn:setRevealed( revealed, refresh )
  refresh = refresh or false

  self.revealed = revealed

  if ( refresh ) then
    self:setVisibility( true )
  end
end

function Pawn:getParent()
  return self.images.pawn.parent
end

function Pawn:setParent( parent )
  self.images.unrevealedPawn.parent:remove( self.images.unrevealedPawn )
  parent:insert( self.images.unrevealedPawn )
  self.images.pawn.parent:remove( self.images.pawn )
  parent:insert( self.images.pawn )
end

function Pawn:rotate( rotation )
  self.images.unrevealedPawn:rotate( rotation )
  self.images.pawn:rotate( rotation )
end

function Pawn:setRotation( rotation )
  self.images.unrevealedPawn.rotation = rotation
  self.images.pawn.rotation = rotation
end

function Pawn:showRevealed()
  if ( self.alive ) then
    self.images.unrevealedPawn.alpha = 0.0
    self.images.pawn.alpha = 1.0

  else
    self.images.unrevealedPawn.alpha = 0.0
    self.images.pawn.alpha = 0.0
  end
end

function Pawn:newTurn()
  self.acted = 0
end

function Pawn:canAct()
  return self.alive and ( self.acted < self.actionsPerTurn )
end

function Pawn:canWin()
  if ( self:canAct() and self.container.name == "square" ) then
    local row = self.container.row

    return self.couldWin and ( ( self.team == 1 and row == 1 ) or ( self.team == 2 and row == GRID_SIZE ) )
  end

  return false
end

function Pawn:isAbleToWin()
  return self.alive and self.couldWin
end

function Pawn:dies()
  -- print( self.type .. " dies" )

  self.alive = false
  self:setVisibility( false )
  self:setContainer( nil )
end

-- Actions

function Pawn:moves( target, force )
  force = force or false

  if ( ( force or self:canAct() ) and ( target ~= nil and target.name == "square" ) ) then
    -- print( self.type .. " is moving" )

    self:setContainer( target )

    if ( not force ) then
      self.acted = self.acted + 1
    end
  end
end

function Pawn:attacks( target )
  if ( self:canAct() and ( target ~= nil and target.name == "pawn" and target.team ~= self.team ) ) then

    -- print( self.type .. " is attacking" )
    self:setRevealed( true, true )

    for i,v in ipairs( self.defeats.attacking ) do
      if ( v == target.type ) then
        target:dies()
        break
      end
    end

    self.acted = self.acted + 1

    target:defends( self )

  end
end

function Pawn:defends( target )
  if ( target ~= nil and target.name == "pawn" and target.team ~= self.team ) then
    -- print( self.type .. " is defending" )

    self:setRevealed( true, true )

    for i,v in ipairs( self.defeats.defending ) do
      if ( v == target.type ) then
        target:dies()
        break
      end
    end

  end
end

function Pawn:wins()
  if ( self:canAct() and self.canWin and self.container.name == "square" ) then
    -- print( self.type .. " tries to win" )

    if ( self:canWin() ) then
      -- print( self.type .. " wins" )

      self.acted = self.acted + 1
      return true
    end
  end

  return false
end



-- META METHODS

function Pawn:__call( ... )

  local inst = setmetatable( {}, self )

  inst:new( ... )

  return inst

end



return Pawn

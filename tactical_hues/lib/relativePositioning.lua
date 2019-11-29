
-- Turn a relative position (0.0 - 1.0) to an absolute position (pixels)
function getAbsPos( relX, relY )
  relY = relY or 0.0
  local absPos = {}

  absPos.x = display.contentWidth * relX
  absPos.y = display.contentHeight * relY

  return absPos
end

-- Turn a relative x position (0.0 - 1.0) to an absolute x position (pixels)
function getAbsX( relX )
  return getAbsPos( relX ).x
end

-- Turn a relative y position (0.0 - 1.0) to an absolute y position (pixels)
function getAbsY( relY )
  return getAbsPos( 0.0, relY ).y
end

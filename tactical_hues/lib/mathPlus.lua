
function round( x )
  local absX = math.abs( x )
  local n = math.floor( absX )

  if ( absX % n >= 0.5 ) then
    n = n + 1
  end

  if ( x < 0 ) then
    n = n * -1
  end

  return n
end

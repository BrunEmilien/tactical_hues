
function getColorTable( htmlColorCode )
  local hex = {["0"] = 0, ["1"] = 1, ["2"] = 2, ["3"] = 3, ["4"] = 4, ["5"] = 5, ["6"] = 6, ["7"] = 7, ["8"] = 8, ["9"] = 9, a = 10, b = 11, c = 12, d = 13, e = 14, f = 15}

  local r = ( hex[htmlColorCode:sub( 1, 1 )] * 16 + hex[htmlColorCode:sub( 2, 2 )] ) / 255
  local g = ( hex[htmlColorCode:sub( 3, 3 )] * 16 + hex[htmlColorCode:sub( 4, 4 )] ) / 255
  local b = ( hex[htmlColorCode:sub( 5, 5 )] * 16 + hex[htmlColorCode:sub( 6, 6 )] ) / 255
  local a = 1.0

  if ( #htmlColorCode == 8 ) then
    a = ( hex[htmlColorCode:sub( 7, 7 )] * 16 + hex[htmlColorCode:sub( 8, 8 )] ) / 255
  end

  return { r, g, b, a }
end

function getColorValues( htmlColorCode )
  return unpack( getColorTable( htmlColorCode ) )
end

function setRadialGradient( object, color1, color2, radiuses, center )
  center = center or {0.5, 0.5}
  radiuses = radiuses or {0.5, 0.0}

  object.fill.effect = "generator.radialGradient"
  object.fill.effect.color1 = color1
  object.fill.effect.color2 = color2
  object.fill.effect.center_and_radiuses = { center[1], center[2], radiuses[1], radiuses[2] }
  object.fill.effect.aspectRatio = object.width/object.height
end

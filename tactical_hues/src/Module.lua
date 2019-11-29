
---- MODULE

local Module = {}

Module.__index = Module
setmetatable( Module, Module )



-- METHODS

function Module:new( param )

  self.param = param

end



-- META METHODS

function Module:__call( ... )

  local inst = setmetatable( {}, self )

  inst:new( ... )

  return inst

end



return Module

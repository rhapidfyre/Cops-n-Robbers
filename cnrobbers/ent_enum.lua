
---------- ENTITY ENUMERATOR --------------
local entityEnumerator = {
  __gc = function(enum)
    if enum.destructor and enum.handle then
      enum.destructor(enum.handle)
    end
    enum.destructor = nil
    enum.handle = nil
  end
}

local function EnumerateEntities(initFunc, moveFunc, disposeFunc)
  return coroutine.wrap(function()
    local iter, id = initFunc()
    if not id or id == 0 then
      disposeFunc(iter)
      return
    end
    
    local enum = {handle = iter, destructor = disposeFunc}
    setmetatable(enum, entityEnumerator)
    
    local next = true
    repeat
      coroutine.yield(id)
      next, id = moveFunc(iter)
    until not next
    
    enum.destructor, enum.handle = nil, nil
    disposeFunc(iter)
  end)
end

--- EXPORT EnumerateObjects()
-- Used to loop through all objects rendered by the client
-- @return The table of entities
-- @usage for objs in EnumerateObjects() do
function EnumerateObjects()
  return EnumerateEntities(FindFirstObject, FindNextObject, EndFindObject)
end

--- EXPORT EnumeratePeds()
-- Used to loop through all objects rendered by the client
-- @return The table of entities
-- @usage for peds in EnumeratePeds() do
function EnumeratePeds()
  return EnumerateEntities(FindFirstPed, FindNextPed, EndFindPed)
end

--- EXPORT EnumerateVehicles()
-- Used to loop through all objects rendered by the client
-- @return The table of entities
-- @usage for vehs in EnumerateVehicles() do
function EnumerateVehicles()
  return EnumerateEntities(FindFirstVehicle, FindNextVehicle, EndFindVehicle)
end

--- EXPORT EnumeratePickups()
-- Used to loop through all pickups rendered by the client
-- @return The table of entities
-- @usage for pickups in EnumeratePickups() do
function EnumeratePickups()
  return EnumerateEntities(FindFirstPickup, FindNextPickup, EndFindPickup)
end
-------------------------------------------------	
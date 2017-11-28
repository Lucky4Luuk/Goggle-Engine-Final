require("distance_functions")

local objects = {}

function updateAllObjects(o)
  objects = o
end

function updateObject(o, index)
  objects[index] = o
end

function getObjects()
  return objects
end

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

function getCollisionResponses(bsres) --BSRES is a table of bounding sphere responses, gotten with getBSResponses
  local cres = {}
  if #bsres > 0 then
    for i=1, #bsres do
      local o1 = objects[bsres[i][1]]
      local o2 = objects[bsres[i][2]]
    end
  end
end

function getBSResponses()
  local bsres = {}
  for i=1, #objects do
    for j=1, #objects do
      if vec_distance(objects[i].pos, objects[j].pos) < (objects[i].bsr + objects[j].bsr) then
        -- Calculate center of the area where the 2 spheres overlap

        --Insert data into table
        table.insert(bsres, {i, j, p})
      end
    end
  end
  return bsres
end

function getBoundingSphere(index)
  return objects[index].bsr
end

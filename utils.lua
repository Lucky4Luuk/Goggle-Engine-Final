function string.starts(String,Start)
   return string.sub(String,1,string.len(Start))==Start
end

function string.ends(String,End)
   return End=='' or string.sub(String,-string.len(End))==End
end

function string.split(String,sep)
   local sep, fields = sep or ":", {}
   local pattern = string.format("([^%s]+)", sep)
   String:gsub(pattern, function(c) fields[#fields+1] = c end)
   return fields
end

function file_exists(file)
  local f = io.open(file, "rb")
  if f then f:close() end
  return f ~= nil
end

function lines_from(file)
  if not file_exists(file) then return {} end
  lines = {}
  for line in io.lines(file) do
    lines[#lines + 1] = line
  end
  return lines
end

function isNaN( v ) return type( v ) == "number" and v ~= v end

function getAvgTexCol(tex)
  local c = love.graphics.newCanvas(1,1)
  love.graphics.setCanvas(c)
  love.graphics.push()
  love.graphics.scale(1/tex:getWidth(), 1/tex:getHeight())
  love.graphics.draw(tex)
  love.graphics.pop()
  love.graphics.setCanvas()
  local r, g, b, a = c:newImageData():getPixel(0,0)
  return {r, g, b}
end

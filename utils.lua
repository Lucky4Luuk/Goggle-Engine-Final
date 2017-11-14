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

function saveImage(data, filename)
  local file = io.open(filename,"w")
  file:close()
  file = io.open(filename,"wb")
  file:write(data)
  file:close()
end

function print_table(t)
  local s = "{"
  for i=1,#t do
    s = s .. tostring(t[i])
    if i < #t then
      s = s .. ", "
    end
  end
  print(s.."}")
end

#!/usr/local/bin/luajit

for line in io.lines() do
   for id in line:gmatch("%S+") do
      print(id .. " 1")
   end
end

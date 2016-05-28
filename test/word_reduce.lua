#!/usr/local/bin/luajit

--dbg = require("debugger")
--dbg()

currentWord = ""
currentTotal = 0
for line in io.lines() do
   word,count = string.match(line, "(%S+)%s+(%d+)")
   count = tonumber(count)
   
   if word ~= currentWord then
      if currentWord ~= "" then
	 print(currentWord .. " " .. currentTotal)
      end
      currentWord = word
      currentTotal = 0
   end
   currentTotal = currentTotal+count
end

if currentWord ~= "" then
   print(currentWord .. " " .. currentTotal)
end

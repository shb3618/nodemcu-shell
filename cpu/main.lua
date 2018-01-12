-- == CPU ==
-- Author: Rene K. Mueller <spiritdude@gmail.com>
-- Description: 
--    Display luakips (kips = thousands of instructions per second) 
--    or set cpu 80/160 MHz
--
-- History:
-- 2018/01/11: 0.0.1: first version
 
return function(...)
   table.remove(arg,1)
   if #arg == 0 then
      local n = 10000
      local t = tmr.now()
      local i = n
      while i > 0 do
         i = i - 1
      end
      t = tmr.now() - t       -- us or 1/1,000,000s
      -- console.print(t.." "..n)
      -- n = instructions per t[us]
      -- n * 1000000 / t         -- instructions per 1s
      -- n = n * 10000 / (t/100) -- instructions per 1s
      n = n * 10 / (t/100)       -- k instructions per 1s
      console.print(n.." luakips") 
   elseif #arg == 1 then
      if arg[1] == '80' or arg[1] == '160' then
         console.print("cpu freq = "..arg[1].." MHz")
         node.setcpufreq(arg[1] == '80' and node.CPU80MHZ or node.CPU160MHZ)
      else
         console.print("ERROR: only 80 or 160 MHz supported: "..arg[1])
      end
   end
end
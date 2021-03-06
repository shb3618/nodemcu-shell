-- == Display Library ==
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
-- License: MIT License (see LICENSE file)
-- Description: 
--    This small library provides some higher level print() functionality
--    Note that all rendering is performed by display.flush(), so call it when
--       when all display.print() or display.clear() is done
--    Depending on the screen height there is auto-scroll.
--
--    display.disp      display pointer, to access lower-level functionality
--    display.setFont()
--    display.clear()   clear screen
--    display.print()   print a string to the display
--    display.flush()   render clear/print to display
--
--  Weight: ~2400 bytes heap
--
-- History: 
-- 2018/02/08: 0.0.2: esp32 support with u8g2
-- 2018/01/09: 0.0.1: from display/init.lua extracted

if display and display.disp then
   display.buffer = {}                    -- content buffer (array of lines)
   display._changed = false
   display._rot = 0
   display.width = display.width or display.disp:getWidth()
   display.height = display.height or display.disp:getHeight()
   if arch=='esp8266' then
      display.fontHeight = display.disp:getFontAscent() - display.disp:getFontDescent() + 1
   else
      display.fontHeight = display.disp:getAscent() - display.disp:getDescent()
   end

   display.setFont = function(fo)
      if fo then
         display.disp:setFont(fo)
         display.disp:setFontRefHeightExtendedText()
         if arch=='esp8266' then
            display.disp:setDefaultForegroundColor()
         end
         display.disp:setFontPosTop()
         if arch=='esp8266' then
            display.fontHeight = display.disp:getFontAscent() - display.disp:getFontDescent() + 1
         else
            display.fontHeight = display.disp:getAscent() - display.disp:getDescent() + 1
         end
         display._changed = true
      end
   end

   display.setRotation = function(a) 
      local w = display.width
      local h = display.height
      if a == 0 then
         _ = u8g and display.disp:undoRotation() or display.disp:setDisplayRotation(u8g2.R0 or 0)
         if display._rot == 90 or display._rot == 270 then
            display.width = h
            display.height = w
         end
      elseif a == 90 then
         _ = u8g and display.disp:setRot90() or display.disp:setDisplayRotation(u8g2.R1 or 1)
         if display._rot == 0 or display._rot == 180 then
            display.width = h
            display.height = w
         end
      elseif a == 180 then
         _ = u8g and display.disp:setRot180() or display.disp:setDisplayRotation(u8g2.R2 or 2)
         if display._rot == 90 or display._rot == 270 then
            display.width = h
            display.height = w
         end
      elseif a == 270 then
         _ = u8g and display.disp:setRot270() or display.disp:setDisplayRotation(u8g2.R3 or 3)
         if display._rot == 0 or display._rot == 180 then
            display.width = h
            display.height = w
         end
      end
      display._rot = a
      display._changed = true
   end

   display.render = function(f)            -- render content (anything)
      display.disp:firstPage()
      repeat
         f();
      until display.disp:nextPage() == false
      collectgarbage()
   end
   
   display.flush = function()               -- render content (strings)
      if display._changed then
         if arch=='esp8266' then
            display.disp:firstPage()
            repeat
               local y = 0;
               for i,v in ipairs(display.buffer) do
                  --console.print("=",v)
                  display.disp:drawStr(0,y,v)
                  y = y + display.fontHeight;
               end
            until display.disp:nextPage() == false
         else
            display.disp:clearBuffer()
            local y = 0;
            for i,v in ipairs(display.buffer) do
               --console.print("=",v)
               display.disp:drawStr(0,y,v)
               y = y + display.fontHeight;
            end
            display.disp:sendBuffer()
         end
      end
      display._changed = false
      collectgarbage()
   end

   -- global functions
   display.clear = function()
      display.buffer = {}
      display._changed = true
      --display.flush()
   end
   
   display.print = function(...)
      local s = ""
      for i,v in ipairs(arg) do
         s = s .. (i>1 and " " or "")
         s = s .. tostring(v)
      end
      if true then               -- autowrap lines
         local e = s:len()
         repeat
            local f = s:sub(1,e)
            -- if string is too long, getStrWidth() reports wrong width, make sure e < 50 or so
            if e < 50 and display.disp:getStrWidth(f) <= display.width then
               table.insert(display.buffer,f)
               if(e==s:len()) then
                  s = ""
               else
                  s = s:sub(e+1)
                  e = s:len()
               end
            else
               e = e-1
            end
         until s:len() == 0 
      else
         table.insert(display.buffer,s)
      end
      while(#display.buffer * display.fontHeight > display.height) do   -- scrolling required?
         table.remove(display.buffer,1)
      end
      display._changed = true
      --display.flush()
      collectgarbage()
   end
end

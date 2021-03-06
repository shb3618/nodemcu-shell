-- == Sysinfo ==
-- Copyright (c) 2018 by Rene K. Mueller <spiritdude@gmail.com>
-- License: MIT License (see LICENSE file)
-- Description: displays sysinfo (adapted from system-info.lua)
-- Todo:
--   With NodeMCU "built 2017-12-25 17:45 Lua 5.1.4 on SDK 2.1.0(116b762)" it has a memory leak
-- History:
-- 2018/02/22: 0.0.4: timer.* -> tmr.* (possible now)
-- 2018/01/30: 0.0.3: tmr.* to timer.*
-- 2018/01/05: 0.0.2: better node.info() output
-- 2018/01/03: 0.0.1: first version

return function(...)
   local kv = function(k,v,u) 
      local s = k..': '.. (u and v..' '..u or v);
      console.print(s)
   end

   kv('Architecture',arch)
   if node.chipid then
      kv('Chip ID',node.chipid()..(type(node.chipid())=='number' and " / "..string.format("0x%x",node.chipid()) or ""))
   end
   if node.flashid then
      kv('Flash ID',node.flashid()..(type(node.flashid())=='number' and " / "..string.format("0x%x",node.flashid()) or ""))
   end
   kv('Heap',node.heap(),'bytes')
   if node.info then
      local maver, miver, devv, cid, fid, fsize, fmode, fspeed, arch = node.info()
      kv('Info',"V"..maver.."."..miver.."."..devv..", FlashMode "..fmode..", FlashSpeed "..fspeed..", Arch "..arch)
   end
   local t = tmr.time();
   kv("Uptime",string.format("%dd %dh %dm %ds",int(t/24/3600),int(t/3600)%24,int(t/60)%60,t%60))
       
   if adc and arch=='esp8266' then     -- make it conditional in case it doesn't exist
      adc.force_init_mode(adc.INIT_VDD33)
      kv('Vdd',adc.readvdd33(),'mV')
   end
   
   local address, size = file.fscfg()
   kv('File System Address',address.." / "..string.format("0x%x",address))
   kv('File System Size',size,'bytes')
 
   if rtctime then
      local tm = rtctime.epoch2cal(rtctime.get())
      kv('RTC Time',string.format("%04d/%02d/%02d %02d:%02d:%02d %s",tm["year"],tm["mon"],tm["day"],tm["hour"],tm["min"],tm["sec"],'UTC'))
   end
   
   local remain, used, total = file.fsinfo()
   kv('File System Usage',used..' / '..total,'bytes')
 
   if arch=='esp8266' then
      kv('Wifi STA MAC Address',wifi.sta.getmac())
      kv('Wifi AP MAC Address',wifi.ap.getmac())
    
      kv('WiFi Channel',wifi.getchannel())
    
      local wifimode = wifi.getmode()
      if wifimode == wifi.STATION then
         kv('WiFi Mode','STATION')
      elseif wifimode == wifi.SOFTAP then
         kv('WiFi Mode','SOFTAP')
      elseif wifimode == wifi.STATIONAP then
         kv('WiFi Mode','STATIONAP')
      elseif wifimode == wifi.NULLMODE then
         kv('WiFi Mode','NULLMODE')
      end
    
      if (wifimode == wifi.STATIONAP) or (wifimode == wifi.SOFTAP) then
         local ip, netmask, gateway = wifi.ap.getip()
         kv('AP IP',ip)
         kv('AP netmask',netmask)
         kv('AP gateway',gateway)
         
         kv('AP client list','')
         local clients = wifi.ap.getclient()
         for mac, ip in pairs(clients) do
           kv(''..mac..'',ip)
         end
      end
    
      local wifiphymode = wifi.getphymode()
      if wifiphymode == wifi.PHYMODE_B then
         kv('WiFi Physical Mode','B')
      elseif wifiphymode == wifi.PHYMODE_G then
         kv('WiFi Physical Mode','G')
      elseif wifiphymode == wifi.PHYMODE_N then
         kv('WiFi Physical Mode','N')
      end
 
      local s = wifi.sta.status()
      if s == wifi.STA_IDLE then
         kv('wifi.sta.status','STA_IDLE')
      elseif s == wifi.STA_CONNECTING then
         kv('wifi.sta.status','STA_CONNECTING')
      elseif s == wifi.STA_WRONGPWD then
         kv('wifi.sta.status','STA_WRONGPWD')
      elseif s == wifi.STA_APNOTFOUND then
         kv('wifi.sta.status','STA_APNOTFOUND')
      elseif s == wifi.STA_FAIL then
         kv('wifi.sta.status','STA_FAIL')
      elseif s == wifi.STA_GOTIP then
         kv('wifi.sta.status','STA_GOTIP')
         kv('Hostname',wifi.sta.gethostname())
    
         local ip, netmask, gateway = wifi.sta.getip()
         kv('STA IP',ip)
         kv('STA netmask',netmask)
         kv('STA gateway',gateway)
    
         local ssid, password, bssid_set, bssid = wifi.sta.getconfig()
         kv('SSID',ssid)
         -- kv('password',password) -- not sure if it should be shown.
         kv('BSSID set',bssid_set)
         kv('BSSID',bssid)
    
         kv('STA Broadcast IP',wifi.sta.getbroadcast())
         kv('RSSI',wifi.sta.getrssi(),'dB')
      end
   end
end

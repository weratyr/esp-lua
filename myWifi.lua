local modname = ...
local W = {}
_G[modname] = W

--------------------------------------------------------------------------------
-- Local used modules
--------------------------------------------------------------------------------
-- Table module
local wifi = wifi
local tmr = tmr
local print = print
local node = node
-- Limited to local environment
setfenv(1,W)

function setWifiMode(mode)
  wifi.setmode(mode)
  wifi.setphymode(wifi.PHYMODE_N)
end

function setupWifi(ssid,pw,cfg)
 wifi.sta.config(ssid,pw)
 wifi.sta.setip(cfg)
 --if tmr.alarm(1, 15000, tmr.ALARM_AUTO, doReconnect) then
  --  print("running timer")
 --end

end

function editWifi()
 local head="<html><head></head><body>"
 local content="<table>sldfjslf</table>"
 local tail="</body></html>"
 return head .. content .. tail
 
end

function doReconnect() 
 print "do reconnect"
 print("\n\tSTA - DISCONNECTED".."\n\tSSID: "..wifi.getphymode())
end

return W

-- Set module name as parameter of require
local modname = ...
local DS18B20 = {}
_G[modname] = DS18B20

--------------------------------------------------------------------------------
-- Local used modules
--------------------------------------------------------------------------------
-- Table module
local table = table
-- String module
local string = string
-- One wire module
local ow = ow
-- Timer module
local tmr = tmr
-- Wifi
local wifi = wifi
-- pairs
local pairs = pairs
-- print
local print = print
-- math 
local math = math
-- cjson
local cjson = cjson
-- pcall
local pcall = pcall

setfenv(1,DS18B20)

local function readTemperature(pin,addr)
  local count=0
  local temps={}
  ow.setup(pin)
  if(addr == nil) then
    print("No addresses.")
    return result
   else
    --print("found dev")
    local crc = ow.crc8(string.sub(addr,1,7))
    if (crc == addr:byte(8)) then
      if ((addr:byte(1) == 0x10) or (addr:byte(1) == 0x28)) then
       local sensor = ""
       for j = 1,8 do sensor = sensor .. string.format("%02x", addr:byte(j)) end  
      ow.reset(pin)
      ow.select(pin, addr)
      ow.write(pin, 0x44, 1)
      --tmr.delay(10000)
      present = ow.reset(pin)
      ow.select(pin, addr)
      ow.write(pin,0xBE,1)
      --print("P="..present)  
      local data = nil
      data = string.char(ow.read(pin))
      for i = 1, 8 do
        data = data .. string.char(ow.read(pin))
      end
      crc = ow.crc8(string.sub(data,1,8))
      if (crc == data:byte(9)) then
       local t = (data:byte(1) + data:byte(2) * 256) * 625
       
       if(addr:byte(1) == 0x10) then
                 -- we have DS18S20, the measurement must change
                 t = t * 8;  -- compensating for the 9-bit resolution only
                 t = t - 2500 + ((10000 * (data:byte(8) - data:byte(7))) / data:byte(8))
        end
        print(t)
        if(t ~= 850000) then
            --print(t)
            temps[sensor] = t
        end
       end                   
        tmr.wdclr()
      end
       end
    end
    addr = nil
    present = nil
    sensor = nil
    t = nil
    
    return temps
end


function addrs(pin)
  ow.setup(pin)
  local tbl = {}
  ow.reset_search(pin)
  repeat
    addr = ow.search(pin)
    if(addr ~= nil) then
      table.insert(tbl, addr)
    end
    tmr.wdclr()
  until (addr == nil)
  ow.reset_search(pin)
  return tbl
end

function getTemp(pin,addrs)
    local outStr = ""
    local tempList = {}
    --print("getTemp")
    
    for a,b in pairs(addrs) do 
       -- print(a,b)
        local entry = readTemperature(pin,b)
        for s,t in pairs(entry) do 
            tempList[s] = string.format("%.1f",(t / 10000))
        end
    end
    tempList["mac"] = wifi.sta.getmac()
    ok, json = pcall(cjson.encode, tempList)
    if ok then
      --print(json)
      outStr=json
    end
    
    return outStr
end

return DS18B20

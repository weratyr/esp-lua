-- Set module name as parameter of require
local modname = ...
local pressRelay = {}
--_G[modname] = pressRelay

--------------------------------------------------------------------------------
-- Local used modules
--------------------------------------------------------------------------------
-- String module
local string = string
-- Timer module
local tmr = tmr
-- print
local print = print
-- gpio 
local gpio = gpio
-- cjson
local cjson = cjson
-- pcall
local pcall = pcall
setfenv(1,pressRelay)

function setGPIOMode(pin,mode)
    gpio.mode(pin, mode)
end 

local function getGPIOPinState(pin)
    return gpio.read(pin)
end
    
function press(pin,time)
    local toggle = {}
    local res = ""
    toggle['pin'] = pin 
    toggle['time'] = time
    setGPIOMode(pin, gpio.OUTPUT)
    gpio.write(pin, gpio.HIGH)
    tmr.delay(time)
    gpio.write(pin, gpio.LOW)
    ok, json = pcall(cjson.encode, toggle)
    if ok then
      print(json)
      res=json
    end
    return res
end

return pressRelay

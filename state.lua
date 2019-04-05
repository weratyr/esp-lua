-- Set module name as parameter of require
local modname = ...
local pinState = {}
_G[modname] = pinState

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
setfenv(1,pinState)

local function setGPIOMode(pin,mode)
    gpio.mode(pin, mode,gpio.PULLUP)
end 

function getGPIOPinState(pin)
    local states = {}
    local res = ""
    setGPIOMode(pin,gpio.INPUT)
    
    states["state"] = gpio.read(pin)
    states["pin"] = pin
    ok, json = pcall(cjson.encode, states)
    if ok then
      print(json)
      res=json
    end
    return res
end
    
return pinState

-- Set module name as parameter of require
local myWifi = require("myWifi")
local config = require("config")
myWifi.setWifiMode(wifi.STATION)
myWifi.setupWifi(ssid,passwd,cfg)




cfg = nil
passwd = nil
ssid = nil


local function clean_up(cn,c)
        cn:on("disconnection", function()
         if string.find(c,"espReset") then
            tmr.delay(5000)
            print("do reset")
            node.restart()
         end
        end)
end

local function send_output(cn,output)
    cn:send(output)
end

-- connection handler function
function connect(conn)
   print("connect")
  
   conn:on("receive", function(cn,c)
    -- clean up connections
    clean_up(cn,c)
    if string.find(c, "favicon.ico") == nil then
      out = ""    
      if string.find(c, "getTemp") then
        local myDS1820 = require("ds18BS20")
        local addrs = myDS1820.addrs(ds1820Pin)
        addrs = myDS1820.addrs(ds1820Pin)
        out = myDS1820.getTemp(ds1820Pin,addrs)
        print(out)
        myDS1820 = nil
        ds18BS20 = nil
        package.loaded["ds18BS20"] = nil
      end

      if string.find(c, "setWifi") then
       print("set wifi")
      end

      if string.find(c, "editWifi") then
       print("edit wifi")
       out=myWifi.editWifi()
      end

      if string.find(c, "switchPin") then
        local pressRelay = require("pressRelay")
        if string.find(c, "?pin") then
            out = pressRelay.press(relayPin,700000)
        end
        if string.find(c, "?pin1") then
            out = pressRelay.press(relayPin1,700000)
        end
        pressRelay = nil
        package.loaded["pressRelay"] = nil
      end

      if string.find(c, "getStatus") then
        pinState = require("state")
        if string.find(c, "?pin") then
            out = pinState.getGPIOPinState(statePin)
        end
         if string.find(c, "?pin1") then
            out = pinState.getGPIOPinState(statePin1)
        end 
        pinState = nil
        package.loaded["state"] = nil
      end

      if string.find(c, "getHumidity") then
        status, temp, humi, temp_dec, humi_dec = dht.read(dh22Pin)
        if status == dht.OK then
            local res = {}
            res["DHT"] = "02"
            res["T"] = temp
            res["H"] = humi
            ok, json = pcall(cjson.encode, res)
            res=nil
            if ok then
                --print(json)
                out=json
            else
                print("failed to encode!")
            end
        elseif status == dht.ERROR_CHECKSUM then
            out="DHT Checksum error."
        elseif status == dht.ERROR_TIMEOUT then
            out="DHT timed out."
        end
      end
      print(out)
      local contentLength = string.len(out)
     --check if output have content
      if contentLength > 0 then
        --header = 
        --header=string.gsub(header,"0",contentLength)
        send_output(cn,"HTTP/1.1 200 OK\r\nServer: NodeLuau\r\nContent-Type: text/html\r\n\r\n"..out)
        --send_output(cn,out)   
      else 
        send_output(cn,"api error")
      end 

    end -- find favicon
    out = nil
    cn:close()
   end) -- on receive
end

-- load socket
so=require("socketServer")
so.bindServer(so.createSocketServer(net.TCP), 80, connect)
local pressRelay = require("pressRelay")
pressRelay.setGPIOMode(relayPin,gpio.OUTPUT)
pressRelay.setGPIOMode(relayPin1,gpio.OUTPUT)
pressRelay = nil
package.loaded["pressRelay"] = nil

so = nil
socketServer = nil
package.loaded["socketServer"] = nil
print("file end")

-- Set module name as parameter of require
local modname = ...
local SOCKSERVER = {}
_G[modname] = SOCKSERVER

--------------------------------------------------------------------------------
-- Local used modules
--------------------------------------------------------------------------------
-- Table module
local net = net
local srv = nil

setfenv(1,SOCKSERVER)

function createSocketServer(protocol) 
    srv=net.createServer(protocol,10)
    return srv
end

function bindServer(server,port,callback)
    server:listen(port,callback)
end

return SOCKSERVER


local socket = require("socket")

local Proxy = cc.load("puremvc").Proxy
local TestServerProxy = class("TestServerProxy", Proxy)

function TestServerProxy:ctor()
	TestServerProxy.super.ctor(self, "TestServerProxy")
end

function TestServerProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	tarslib.register(cc.FileUtils:getInstance():fullPathForFilename("Testluac.tars"))
	self.client = {}
	self.server = socket.bind("192.168.0.33", 13800)
	self.server:settimeout(0)
	self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(handler(self, self.serverLoop), 0.1, false)
end

function TestServerProxy:onRemove()
end

function TestServerProxy:serverLoop(dt)
	local conn = self.server:accept()
	if conn then
		conn:settimeout(0)
		self.client[os.time()] = conn
	end
	local toremove = {}
	for k,v in pairs(self.client) do
		local body, status, partial = v:receive("*a")
		print("server recv:", body, status, partial)
    	if status ~= "close" and status ~= "Socket is not connected" then
    		local tarslib = cc.load("jfutils").Tars
    		local msg = body or partial
    		if msg and string.len(msg) > 0 then
    			print("recv msg:", msg, string.len(msg))
    			local _, s1 = tarslib.decode(msg, "Test::B")
    			local tab = {i=1,f=2.22,s="hahaha"}
    			local s2 = tarslib.encode(tab, "Test::B")
    			print("send msg:", s2, string.len(s2))
    			v:send(s2)
    		end
    	else
    		v:shutdown()
    		v:close()
    		table.insert(toremove, k)
    	end
	end
	for i,v in ipairs(toremove) do
		self.client[v] = nil
	end
end

return TestServerProxy
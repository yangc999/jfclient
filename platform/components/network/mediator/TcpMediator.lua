
local JFSocket = cc.load("jfutils").JFSocket
local ByteArray = cc.load("jfutils").ByteArray

local Proxy = cc.load("puremvc").Proxy
local TestClientProxy = class("TestClientProxy", Proxy)

function TestClientProxy:ctor()
	TestClientProxy.super.ctor(self, "TestClientProxy")
end

function TestClientProxy:onRegister()
	self.client = JFSocket.new()
	self.client:addEventListener(JFSocket.EVENT_CONNECTED, handler(self, self.clientLoop))
	self.client:addEventListener(JFSocket.EVENT_DATA, handler(self, self.onRecv))
	self.client:connect("192.168.0.33", 13800)
end

function TestClientProxy:onRemove()
end

function TestClientProxy:clientLoop()
	local msg = string.pack(">h", 123)
	print("msg len:", string.len(msg))
	self.client:send(msg)
	--self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function(dt)
	--	
	--end, 0.1, false)
end

function TestClientProxy:onRecv(evt)
	local _, msg = string.unpack(evt.data, ">h")
	print("client recv:", msg)
	self.client:send(evt.data)
end

return TestClientProxy
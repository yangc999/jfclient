
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local LoginProxy = class("LoginProxy", Proxy)

function LoginProxy:ctor()
	LoginProxy.super.ctor(self, "LoginProxy")
    local wxuid=cc.UserDefault:getInstance():getIntegerForKey("wxuid")
	local data = ProxyData.new()
	data:prop("token", "")
	data:prop("uid", 0)
    data:prop("wxuid", wxuid)
	self:setData(data)
end

function LoginProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path = cc.FileUtils:getInstance():fullPathForFilename("platform/components/login/tars/LoginProto.tars")
	tarslib.register(path)
end

function LoginProxy:onRemove()
end

return LoginProxy
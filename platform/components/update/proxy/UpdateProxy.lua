
local Proxy = cc.load("puremvc").Proxy
local UpdateProxy = class("UpdateProxy", Proxy)

function UpdateProxy:ctor()
	UpdateProxy.super.ctor(self, "UpdateProxy")
	self:setData({})
end

function UpdateProxy:onRegister()
	
end

function UpdateProxy:onRemove()
end

return UpdateProxy

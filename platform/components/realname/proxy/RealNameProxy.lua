--region *.lua
--Date
--实名注册的Proxy
local RealNameData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local RealNameProxy = class("RealNameProxy", Proxy)

function RealNameProxy:ctor()
	RealNameProxy.super.ctor(self, "RealNameProxy")
end

function RealNameProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = RealNameData.new()  --公告所用的数据部分

    data:prop("name", "")  --用户名
    data:prop("id", "") --身份证号
    
	self:setData(data)
end

function RealNameProxy:onRemove()
end

return RealNameProxy
--endregion

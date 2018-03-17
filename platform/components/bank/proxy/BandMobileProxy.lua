--region *.lua
--Date 2017/11/10
--绑定手机号Proxy
local BandData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local BandMobileProxy = class("BandMobileProxy", Proxy)

function BandMobileProxy:ctor()
	BandMobileProxy.super.ctor(self, "BandMobileProxy")
end

function BandMobileProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = BandData.new()  --数据部分
    data:prop("scheduleID",nil) --当前用户定时器ID

	self:setData(data)
end

function BandMobileProxy:onRemove()
end

return BandMobileProxy
--endregion

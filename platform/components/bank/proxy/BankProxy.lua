--region *.lua
--Date 2017/11/10
--yangyisong
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local BankProxy = class("BankProxy", Proxy)

function BankProxy:ctor()
	BankProxy.super.ctor(self, "BankProxy")
end

function BankProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = ProxyData.new()  --公告所用的数据部分
	data:prop("gold", 0, platformFacade, PlatformConstants.UPDATE_GOLD)    --当前用户的金币数
	data:prop("safeGold", 0, platformFacade, PlatformConstants.UPDATE_SAFEGOLD)  --当前用户保险箱的金币数
    data:prop("drawMoney",0) --当前用户要存的钱
    data:prop("password", "") --用户输入的密码

	self:setData(data)
end

function BankProxy:onRemove()
end

return BankProxy
--endregion

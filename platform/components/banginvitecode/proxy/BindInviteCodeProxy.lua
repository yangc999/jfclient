--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local BindInviteCodeProxy = class("BindInviteCodeProxy", Proxy)

function BindInviteCodeProxy:ctor()
	BindInviteCodeProxy.super.ctor(self, "BindInviteCodeProxy")
end

function BindInviteCodeProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = ProxyData.new()  --公告所用的数据部分
    data:prop("friendCode","") --朋友邀请码
    data:prop("agentCode", "") --代理商邀请码

	self:setData(data)
end

function BindInviteCodeProxy:onRemove()
end

return BindInviteCodeProxy
--endregion

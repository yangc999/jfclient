--region *.lua
--Date
--比赛的代理类

local MatchData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local MatchProxy = class("MatchProxy", Proxy)

function MatchProxy:ctor()
	MatchProxy.super.ctor(self, "MatchProxy")	
end

function MatchProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = MatchData.new()  --公告所用的数据部分
	--data:prop("anlist", {}, platformFacade, PlatformConstants.SHOW_ANNOUNCELIST)  --公告列表，公告数据改变时，发送SHOW_ANNOUNCELIST消息
    --data:prop("curId", -1)  --当前公告ID
    --data:prop("curTitle", "") --当前公告的标题
	self:setData(data)
end

function MatchProxy:onRemove()
end

return MatchProxy
--endregion

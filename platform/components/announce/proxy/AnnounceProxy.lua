--region *.lua
--Date 2017.11.02
--公告代理类

local AnnounceData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local AnnounceProxy = class("AnnounceProxy", Proxy)

function AnnounceProxy:ctor()
	AnnounceProxy.super.ctor(self, "AnnounceProxy")
	
end

function AnnounceProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = AnnounceData.new()  --公告所用的数据部分
	data:prop("anlist", {}, platformFacade, PlatformConstants.SHOW_ANNOUNCELIST)  --公告列表，公告数据改变时，发送SHOW_ANNOUNCELIST消息
    data:prop("curId", -1)  --当前公告ID
    data:prop("curTitle", "") --当前公告的标题
    data:prop("anConlist",{}) --公告内容列表 形如{id=1, content="xxxxxx"}
	self:setData(data)
end

function AnnounceProxy:onRemove()
end

return AnnounceProxy

--endregion

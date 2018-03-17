--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local GameHelpData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local GameHelpProxy = class("GameHelpProxy", Proxy)

function GameHelpProxy:ctor()
	GameHelpProxy.super.ctor(self, "GameHelpProxy")
	
end

function GameHelpProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    local data = GameHelpData.new()  --公告所用的数据部分
	data:prop("gamehelplist", {}, platformFacade, PlatformConstants.SHOW_GAMEHELPLIST)  --公告列表，公告数据改变时，发送SHOW_GameHelpLIST消息
    data:prop("curId", -1)  --当前公告ID
    data:prop("curTitle", "") --当前公告的标题
    data:prop("anConlist",{}) --公告内容列表 形如{id=1, content="xxxxxx"}
	self:setData(data)
end

function GameHelpProxy:onRemove()
end

return GameHelpProxy


--endregion

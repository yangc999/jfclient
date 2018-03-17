
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local ChatProxy = class("ChatProxy", Proxy)

function ChatProxy:ctor()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	ChatProxy.super.ctor(self, "ChatProxy")

	local data = ProxyData.new()
	self:setData(data)
end

function ChatProxy:onRegister()
end

function ChatProxy:onRemove()
end

return ChatProxy
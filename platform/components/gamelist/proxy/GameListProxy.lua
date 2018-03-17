
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local GameListProxy = class("GameListProxy", Proxy)

function GameListProxy:ctor()
	GameListProxy.super.ctor(self, "GameListProxy")
end

function GameListProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local proxy = platformFacade:retrieveProxy("LoadProxy")
	local data = ProxyData.new()
	data:prop("private", {}, platformFacade, PlatformConstants.UPDATE_PRIGAMELIST)
	data:prop("public", {}, platformFacade, PlatformConstants.UPDATE_PUBGAMELIST)
	data:prop("quick", {})
	data:prop("champion", {})
	self:setData(data)
end

function GameListProxy:onRemove()
end

return GameListProxy
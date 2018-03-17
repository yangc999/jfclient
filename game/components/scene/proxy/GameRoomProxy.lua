
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local GameRoomProxy = class("GameRoomProxy", Proxy)

function GameRoomProxy:ctor()
	GameRoomProxy.super.ctor(self, "GameRoomProxy")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local lastRoomId = cc.UserDefault:getInstance():getStringForKey(string.format("roomId_%d", login:getData().uid))
	local lastServerId = cc.UserDefault:getInstance():getIntegerForKey(string.format("serverId_%d", login:getData().uid))
	local data = ProxyData.new()
	data:prop("gameType", 0)
	data:prop("gameId", 0)
	data:prop("roomId", lastRoomId or "")
	data:prop("serverId", lastServerId or 0)
	data:prop("roomKey", "")
	data:prop("masterId", 0)
	data:prop("gameState", 0)
    data:prop("matchData",0,gameFacade,GameConstants.UPDATE_RANDING)
	self:setData(data)
end

function GameRoomProxy:onRegister()
end

function GameRoomProxy:onRemove()
end

return GameRoomProxy
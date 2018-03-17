
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local WaitingRiseProxy = class("WaitingRiseProxy", Proxy)

function WaitingRiseProxy:ctor()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	WaitingRiseProxy.super.ctor(self, "WaitingRiseProxy")

	local data = ProxyData.new()
    data:prop("respMsg", {iRanking=12,iPlayerNum=0,iTablePlaying=5,ePlayerState="",iBeginPlayers=32}, gameFacade, GameConstants.UPDATE_WAITINGRISE)
	self:setData(data)
end

function WaitingRiseProxy:onRegister()
end

function WaitingRiseProxy:onRemove()
end

return WaitingRiseProxy
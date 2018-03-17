
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local EliminateProxy = class("EliminateProxy", Proxy)

function EliminateProxy:ctor()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

	EliminateProxy.super.ctor(self, "EliminateProxy")

	local data = ProxyData.new()
    data:prop("matchMsg", {sMatchName="转转麻将1元话费赛",iPlayers=32,vecMatchAwards={iAwardType=0,iAwardValue=0}})
    data:prop("rankMsg", {iMatchID=1,iRanking=18,iKnockOutTime="16:15"})
	self:setData(data)
end

function EliminateProxy:onRegister()
end

function EliminateProxy:onRemove()
end

return EliminateProxy
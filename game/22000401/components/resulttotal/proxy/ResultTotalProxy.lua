
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local ResultTotalProxy = class("ResultTotalProxy", Proxy)

function ResultTotalProxy:ctor()
    print("------------>ResultTotalProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	ResultTotalProxy.super.ctor(self, "ResultTotalProxy")
	local data = ProxyData.new()
    
    data:prop("TimesData", {},gameFacade, "RT_updatetimes")
    data:prop("ScoreData", {},gameFacade, "RT_updatescore")
    data:prop("Winers", {},gameFacade, "RT_winers")

	self:setData(data)
end

function ResultTotalProxy:onRegister()
    print("------------>ResultTotalProxy:onRegister")
end

function ResultTotalProxy:onRemove()
    print("------------>ResultTotalProxy:onRemove")
end

return ResultTotalProxy

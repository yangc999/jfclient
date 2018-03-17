
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local ResultProxy = class("ResultProxy", Proxy)

function ResultProxy:ctor()
    print("------------>ResultProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	ResultProxy.super.ctor(self, "ResultProxy")
	local data = ProxyData.new()
    
    data:prop("HuUserChair", 255)
    data:prop("bFinished", false, gameFacade, "RE_updatebutton")
    data:prop("Round", {}, gameFacade, "RE_updateround")
    data:prop("ScoreData", {},gameFacade, "RE_updatescore")
    data:prop("NiaoCardData", {},gameFacade, "RE_updateniaocard")
    data:prop("HandCardData", {},gameFacade, "RE_updatehandcard")

	self:setData(data)
end

function ResultProxy:onRegister()
    print("------------>ResultProxy:onRegister")
end

function ResultProxy:onRemove()
    print("------------>ResultProxy:onRemove")
end

return ResultProxy

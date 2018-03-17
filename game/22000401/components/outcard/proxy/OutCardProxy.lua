
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local OutCardProxy = class("OutCardProxy", Proxy)

function OutCardProxy:ctor()
    print("------------>OutCardProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	OutCardProxy.super.ctor(self, "OutCardProxy")
	local data = ProxyData.new()
    data:prop("LastOutCardData", {})
    data:prop("ClickCardValue",0,gameFacade, "OC_clickcardvalue")
	data:prop("OutCardData", {},gameFacade, "OC_outcard")
    data:prop("ActInfoData", {},gameFacade, "OC_actinfo")
    data:prop("GameStationData", {},gameFacade, "OC_gamestation")
	self:setData(data)
end

function OutCardProxy:onRegister()
    print("------------>OutCardProxy:onRegister")

end

function OutCardProxy:onRemove()
    print("------------>OutCardProxy:onRemove")
end

return OutCardProxy


local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local HandCardProxy = class("HandCardProxy", Proxy)

function HandCardProxy:ctor()
    print("------------>HandCardProxy:ctor")
    HandCardProxy.super.ctor(self, "HandCardProxy")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
	local data = ProxyData.new()
    data:prop("SelfHandCards", {})
    data:prop("AllHandCards", {})
    data:prop("IsCanOutCard", false)
    local visibleCards = { 
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,0,0,0,
        0,0,0,0,0,0,0,
    }
    data:prop("VisibleCards",visibleCards)  -- 桌面可见牌，查听用到

    data:prop("ClickCardValue",0,gameFacade, "HC_clickcardvalue")
    data:prop("HandCards", {},gameFacade, "HC_fetchcards")
    data:prop("UserHandCards", {},gameFacade, "HC_videofetchcards")
    data:prop("TokenData", {},gameFacade, "HC_getToken")
    data:prop("OutCardValue",0,gameFacade, "HC_outcardreq")
    data:prop("OutCardData", {},gameFacade, "HC_outcard")
    data:prop("ActInfoData", {},gameFacade, "HC_actinfo")
    data:prop("GameStationData", {},gameFacade, "HC_gamestation")
    data:prop("TestData", {},gameFacade, "HC_test")
	self:setData(data)
end

function HandCardProxy:onRegister()
    print("------------>HandCardProxy:onRegister")

end

function HandCardProxy:onRemove()
    print("------------>HandCardProxy:onRemove")
end

return HandCardProxy

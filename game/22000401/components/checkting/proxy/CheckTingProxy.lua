
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local CheckTingProxy = class("CheckTingProxy", Proxy)

function CheckTingProxy:ctor()
    print("------------>CheckTingProxy:ctor")
    CheckTingProxy.super.ctor(self, "CheckTingProxy")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	
	local data = ProxyData.new()
    data:prop("CardData", {},gameFacade, "CT_card")
	self:setData(data)
end

function CheckTingProxy:onRegister()
    print("------------>CheckTingProxy:onRegister")

end

function CheckTingProxy:onRemove()
    print("------------>CheckTingProxy:onRemove")
end

return CheckTingProxy

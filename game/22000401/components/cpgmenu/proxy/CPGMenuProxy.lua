
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local CPGMenuProxy = class("CPGMenuProxy", Proxy)

function CPGMenuProxy:ctor()
    print("------------>CPGMenuProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	CPGMenuProxy.super.ctor(self, "CPGMenuProxy")
	local data = ProxyData.new()
	
    data:prop("ActNotifyData", {},gameFacade, "CP_actnotify")
    data:prop("ActInfoData", {},gameFacade, "CP_actinfo")
	self:setData(data)
end

function CPGMenuProxy:onRegister()
    print("------------>CPGMenuProxy:onRegister")

end

function CPGMenuProxy:onRemove()
    print("------------>CPGMenuProxy:onRemove")
end

return CPGMenuProxy

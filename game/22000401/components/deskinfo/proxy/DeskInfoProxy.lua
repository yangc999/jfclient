
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local DeskInfoProxy = class("DeskInfoProxy", Proxy)

function DeskInfoProxy:ctor()
    print("------------>DeskInfoProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants
	DeskInfoProxy.super.ctor(self, "DeskInfoProxy")
	local data = ProxyData.new()
    data:prop("NiaoCard", {})
    data:prop("LaiZi", {35})
    data:prop("IsCan7Dui",false)
	data:prop("Round", {},gameFacade, "DI_updateround")
    data:prop("MakeNTData", {},gameFacade, "DI_makent")
    data:prop("ActNotifyData", {},gameFacade, "DI_actnotify")
    data:prop("TokenData", {},gameFacade, "DI_getTokens")
    data:prop("NiaoCardData", {},gameFacade, "DI_niaocard")
    data:prop("GameStationData", {},gameFacade, "DI_gamestation")
	self:setData(data)
end

function DeskInfoProxy:onRegister()
    print("------------>DeskInfoProxy:onRegister")
end

function DeskInfoProxy:onRemove()
    print("------------>DeskInfoProxy:onRemove")
end

return DeskInfoProxy

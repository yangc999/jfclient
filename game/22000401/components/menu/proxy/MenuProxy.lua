
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local MenuProxy = class("MenuProxy", Proxy)

function MenuProxy:ctor()
    print("------------>MenuProxy:ctor")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local gameConstants = cc.exports.GameConstants

	MenuProxy.super.ctor(self, "MenuProxy")
	local data = ProxyData.new()
    data:prop("GameStationData", {},gameFacade, "ME_gamestation")
    data:prop("AutoData", {},gameFacade, "ME_auto")
	self:setData(data)
end

function MenuProxy:onRegister()
    print("------------>MenuProxy:onRegister")

end

function MenuProxy:onRemove()
    print("------------>MenuProxy:onRemove")
end

return MenuProxy

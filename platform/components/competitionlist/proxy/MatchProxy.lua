local MatchProxy=class("MatchProxy",cc.load("puremvc").Proxy)
local ProxyData=cc.load("jfutils").ProxyData
function MatchProxy:ctor()
	MatchProxy.super.ctor(self, "MatchProxy")
end
function MatchProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local data = ProxyData.new()
    data:prop("gameList",{},PlatformConstants.UPDATE_MATCHGAMELIST)
    self:setData(data)
end
function MatchProxy:onRemove()
end
return MatchProxy
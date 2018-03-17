local ProxyData = cc.load("jfutils").ProxyData
local Proxy = cc.load("puremvc").Proxy
local CptMoreGameProxy = class("CptMoreGameProxy", Proxy)

function CptMoreGameProxy:ctor()
	CptMoreGameProxy.super.ctor(self, "CptMoreGameProxy")
end

function CptMoreGameProxy:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local data = ProxyData.new()
    data:prop("gameList", {},platformFacade,PlatformConstants.UPDATE_COMPETITIONMOREGAMELIST)
    data:prop("gameListSelected",{},platformFacade,PlatformConstants.UPDATE_COMPETITIONMOREGAMELISTSELECTED)
	self:setData(data)
    self:present()
end

function CptMoreGameProxy:onRemove()
end
function CptMoreGameProxy:saveData()
    cc.LocalStorage:setItem("gameList",json.encode(self:getData().gameList))
    cc.LocalStorage:setItem("gameListSelected",json.encode(self:getData().gameListSelected))
end

function CptMoreGameProxy:present()
--     cc.LocalStorage:removeItem("gameList")
--     cc.LocalStorage:removeItem("gameListSelected")
   if cc.LocalStorage:getItem("gameList")~="" and cc.LocalStorage:getItem("gameListSelected")~="" then
   self:getData().gameList=json.decode(cc.LocalStorage:getItem("gameList"))
   self:getData().gameListSelected=json.decode(cc.LocalStorage:getItem("gameListSelected"))
   end
end

return CptMoreGameProxy
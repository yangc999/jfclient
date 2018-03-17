
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local RoomKeyProxy = class("RoomKeyProxy", Proxy)

function RoomKeyProxy:ctor()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	RoomKeyProxy.super.ctor(self, "RoomKeyProxy")
	local data = ProxyData.new()
	data:prop("key", "", platformFacade, PlatformConstants.UPDATE_ROOMKEY)
	self:setData(data)
end

function RoomKeyProxy:onRegister()
end

function RoomKeyProxy:onRemove()
end

return RoomKeyProxy
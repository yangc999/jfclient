
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local RoomListProxy = class("RoomListProxy", Proxy)

function RoomListProxy:ctor()
	RoomListProxy.super.ctor(self, "RoomListProxy")
end

function RoomListProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path = cc.FileUtils:getInstance():fullPathForFilename("platform/components/roomlist/tars/RoomDynamicProto.tars")
	tarslib.register(path)
	
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	local data = ProxyData.new()
	data:prop("gameId", nil)
	data:prop("public", {}, platformFacade, PlatformConstants.UPDATE_PUBROOM)
	data:prop("quick", {}, platformFacade, PlatformConstants.UPDATE_QUICKROOM)
	self:setData(data)
end

function RoomListProxy:onRemove()
end

return RoomListProxy

local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local RoomConfigProxy = class("RoomConfigProxy", Proxy)

function RoomConfigProxy:ctor()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	RoomConfigProxy.super.ctor(self, "RoomConfigProxy")
	local data = ProxyData.new()
	data:prop("config", nil, platformFacade, PlatformConstants.UPDATE_ROOMCFG)
	data:prop("choice", nil, platformFacade, PlatformConstants.UPDATE_ROOMCHC)
	data:prop("select", nil, platformFacade, PlatformConstants.UPDATE_ROOMSLC)
	data:prop("iAntiCheating", (cc.UserDefault:getInstance():getIntegerForKey("iAntiCheating", 0) == 0) and false or true, platformFacade, PlatformConstants.UPDATE_ANTICHEATING)
	self:setData(data)
end

function RoomConfigProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path = cc.FileUtils:getInstance():fullPathForFilename("platform/components/privateroom/tars/PrivateRoomHttpProto.tars")
	tarslib.register(path)
end

function RoomConfigProxy:onRemove()
end

return RoomConfigProxy

local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local HorseLampProxy = class("HorseLampProxy", Proxy)

function HorseLampProxy:ctor()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	HorseLampProxy.super.ctor(self, "HorseLampProxy")
	local data = ProxyData.new()
--	data:prop("id", 0, platformFacade, PlatformConstants.UPDATE_HORSELAMP)
	data:prop("text", "", platformFacade, PlatformConstants.UPDATE_HORSELAMP)
	self:setData(data)
end

function HorseLampProxy:onRegister()
--	local tarslib = cc.load("jfutils").Tars
--	local path1 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/userinfo/tars/UserInfoProto.tars")
--	tarslib.register(path1)
--	local path2 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/userinfo/tars/UserInfoHttpProto.tars")
--	tarslib.register(path2)
end

function HorseLampProxy:onRemove()
end

return HorseLampProxy
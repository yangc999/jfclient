
local Mediator = cc.load("puremvc").Mediator
local HttpMediator = class("HttpMediator", Mediator)

function HttpMediator:ctor(scene)
	HttpMediator.super.ctor(self, "HttpMediator")
	self.scene = scene
end

function HttpMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {PlatformConstants.START_HALL}
end

function HttpMediator:onRegister()
	local tarslib = cc.load("jfutils").Tars
	--tarslib.register(cc.FileUtils:getInstance():fullPathForFilename("platform/components/network/tars/JFGameHttpProto.tars"))
end

function HttpMediator:onRemove()
end

function HttpMediator:handleNotification(notification)
	local name = notification:getName()
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_HALL then
		local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
		platformFacade:removeMediator("HttpMediator")
		platformFacade:removeMediator("LoginButtonMediator")
		platformFacade:removeProxy("LoginProxy")
	end
end

return HttpMediator
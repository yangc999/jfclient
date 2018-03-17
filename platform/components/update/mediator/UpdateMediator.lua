
local Mediator = cc.load("puremvc").Mediator
local UpdateMediator = class("UpdateMediator", Mediator)

function UpdateMediator:ctor(scene)
	UpdateMediator.super.ctor(self, "UpdateMediator")
	self.scene = scene
end

function UpdateMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_HALL, 
	}
end

function UpdateMediator:onRegister()
	
end

function UpdateMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:removeCommand(PlatformConstants.START_REGISTER)
	platformFacade:removeCommand(PlatformConstants.START_HALL)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function UpdateMediator:handleNotification(notification)
	local name = notification:getName()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_HALL then
		platformFacade:removeMediator("UpdateMediator")
	end
end

return UpdateMediator
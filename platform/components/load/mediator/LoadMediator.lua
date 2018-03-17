
local Mediator = cc.load("puremvc").Mediator
local LoadMediator = class("LoadMediator", Mediator)

function LoadMediator:ctor(scene)
	LoadMediator.super.ctor(self, "LoadMediator")
	self.scene = scene
end

function LoadMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGIN, 
		PlatformConstants.SHOW_UPDATE, 
		PlatformConstants.START_UPDATE, 
	}
end

function LoadMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:registerCommand(PlatformConstants.REQUEST_CONFIG, cc.exports.RequestConfigCommand)
	platformFacade:registerCommand(PlatformConstants.START_UPDATE, cc.exports.StartUpdateCommand)
	platformFacade:registerCommand(PlatformConstants.SHOW_UPDATE, cc.exports.ShowUpdateCommand)
    platformFacade:registerCommand(PlatformConstants.START_INITWX, cc.exports.StartInitWeiXinCommand)
	platformFacade:registerCommand(PlatformConstants.START_LOGIN, cc.exports.StartLoginCommand)

	local ui = cc.LayerColor:create(cc.c4b(255, 255, 255, 255))

	ccdb.CCFactory:getInstance():loadDragonBonesData("platform_res/login/logo/logoo_ske.json")
	ccdb.CCFactory:getInstance():loadTextureAtlasData("platform_res/login/logo/logoo_tex.json")
	local testdb = ccdb.CCFactory:getInstance():buildArmatureDisplay("Armature", "logoo")
	local ani = testdb:getArmature():getAnimation():play("newAnimation", 1)
	--ani.timeScale = 0.5
	testdb:setPosition(display.cx, display.cy)
	ui:addChild(testdb)

	testdb:addEvent("complete", function()
		self.loop = cc.Director:getInstance():getScheduler():scheduleScriptFunc(function()
			platformFacade:sendNotification(PlatformConstants.REQUEST_CONFIG)
		end, 0.5, false)
	end)

	self:setViewComponent(ui)
	self.scene:addChild(self:getViewComponent())

    audio.preloadSound("sound/rotate.mp3")
    audio.preloadSound("sound/getreward.mp3")
    audio.preloadSound(PlatformConstants.HALL_MUSIC_PATH)
end

function LoadMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	--platformFacade:removeCommand(PlatformConstants.START_UPDATE)
	--platformFacade:removeCommand(PlatformConstants.SHOW_UPDATE)
	--platformFacade:removeCommand(PlatformConstants.START_LOGIN)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function LoadMediator:handleNotification(notification)
	local name = notification:getName()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_LOGIN then
		platformFacade:removeMediator("LoadMediator")
	elseif name == PlatformConstants.SHOW_UPDATE then
		platformFacade:removeMediator("LoadMediator")
	elseif name == PlatformConstants.START_UPDATE then
		if self.loop then
			cc.Director:getInstance():getScheduler():unscheduleScriptEntry(self.loop)
			self.loop = nil
		end
	end
end

return LoadMediator
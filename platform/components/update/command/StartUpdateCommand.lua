
local UpdateProxy = import("..proxy.UpdateProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartUpdateCommand = class("StartUpdateCommand", SimpleCommand)

function StartUpdateCommand:execute(notification)
	local scene = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    platformFacade:registerProxy(UpdateProxy.new())
    local update = platformFacade:retrieveProxy("UpdateProxy")
    if true then
        platformFacade:sendNotification(PlatformConstants.START_LOGIN, scene)
    else
        platformFacade:sendNotification(PlatformConstants.SHOW_UPDATE, scene)
    end
end

return StartUpdateCommand
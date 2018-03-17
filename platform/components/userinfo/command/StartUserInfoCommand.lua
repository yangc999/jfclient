
local UserInfoProxy = import("..proxy.UserInfoProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartUserInfoCommand = class("StartUserInfoCommand", SimpleCommand)

function StartUserInfoCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	platformFacade:registerProxy(UserInfoProxy.new())
end

return StartUserInfoCommand
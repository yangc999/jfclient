
local UserInfoMediator = import("..mediator.UserInfoMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowUserInfoCommand = class("ShowUserInfoCommand", SimpleCommand)

function ShowUserInfoCommand:execute(notification)
	local scene = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	platformFacade:registerMediator(UserInfoMediator.new(scene))
end

return ShowUserInfoCommand
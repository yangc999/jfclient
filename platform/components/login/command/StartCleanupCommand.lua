
local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartCleanupCommand = class("StartCleanupCommand", SimpleCommand)

function StartCleanupCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:removeProxy("GameListProxy")
	platformFacade:removeProxy("RoomListProxy")
	platformFacade:removeProxy("DeskListProxy")
	platformFacade:removeProxy("HorseLampProxy")
	platformFacade:removeProxy("MatchRecordsProxy")
	platformFacade:removeProxy("LotteryProxy")
	platformFacade:removeProxy("GameHelpProxy")
	platformFacade:removeProxy("BenefitsProxy")
	platformFacade:removeProxy("BankProxy")
	platformFacade:removeProxy("AnnounceProxy")
	platformFacade:removeProxy("RealNameProxy")
	platformFacade:removeProxy("ShopProxy")
	platformFacade:removeProxy("UserInfoProxy")
    cc.UserDefault:getInstance():deleteValueForKey("wxuid")
	platformFacade:removeProxy("LoginProxy")
end

return StartCleanupCommand
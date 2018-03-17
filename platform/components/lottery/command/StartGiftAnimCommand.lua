--region *.lua
--Date
--此启动抽奖动画UI
local LotteryProxy = import("..proxy.LotteryProxy")
local GiftAnimMediator = import("..mediator.GiftAnimMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartGiftAnimCommand = class("StartGiftAnimCommand", SimpleCommand)

function StartGiftAnimCommand:execute(notification)
    print("StartGiftAnimCommand:execute")

    local type = notification:getBody()

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(LotteryProxy.new())
	platformFacade:registerMediator(GiftAnimMediator.new(type))
end

return StartGiftAnimCommand
--endregion

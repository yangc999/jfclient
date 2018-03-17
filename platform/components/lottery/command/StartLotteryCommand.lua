--region *.lua
--Date
--启动转盘UI
local LotteryProxy = import("..proxy.LotteryProxy")
local LotteryMediator = import("..mediator.LotteryMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartLotteryCommand = class("StartLotteryCommand", SimpleCommand)

function StartLotteryCommand:execute(notification)
    print("StartLotteryCommand:execute")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(LotteryProxy.new())
	platformFacade:registerMediator(LotteryMediator.new())
end

return StartLotteryCommand
--endregion

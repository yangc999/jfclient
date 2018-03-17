--region *.lua
--Date
--启动战绩页面

local MatchRecordsProxy = import("..proxy.MatchRecordsProxy")
local MatchRecordsMediator = import("..mediator.MatchRecordsMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartMatchRecordsCommand = class("StartMatchRecordsCommand", SimpleCommand)

function StartMatchRecordsCommand:execute(notification)
    print("StartMatchRecordsCommand:execute")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(MatchRecordsProxy.new())
	platformFacade:registerMediator(MatchRecordsMediator.new())
end

return StartMatchRecordsCommand

--endregion

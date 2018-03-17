--region *.lua
--Date
--启动战绩详情页面
local MatchRecordsProxy = import("..proxy.MatchRecordsProxy")
local MatchRecordDetailMediator = import("..mediator.MatchRecordDetailMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartMatchRecordDetailCommand = class("StartMatchRecordDetailCommand", SimpleCommand)

function StartMatchRecordDetailCommand:execute(notification)
    print("StartMatchRecordDetailCommand:execute")

    --local body = notification:getBody()
   -- print("sRoomNo:" .. body)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(MatchRecordsProxy.new())
	platformFacade:registerMediator(MatchRecordDetailMediator.new())
end

return StartMatchRecordDetailCommand
--endregion

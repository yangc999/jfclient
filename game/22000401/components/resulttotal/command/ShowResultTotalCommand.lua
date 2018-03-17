local ResultTotalMediator = import("..mediator.ResultTotalMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ShowResultTotalCommand = class("ShowResultTotalCommand", SimpleCommand)

function ShowResultTotalCommand:execute(notification)
    print("-------------->ShowResultTotalCommand:execute")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local data = gameFacade:retrieveProxy("ResultTotalProxy"):getData()

    print("ShowResultTotalCommand:execute scoredata len = " .. tostring(#data.ScoreData))
    if name == MyGameConstants.C_SHOW_RESULTTOTAL then
        if #data.ScoreData >= 1 then
            gameFacade:registerMediator(ResultTotalMediator.new())
        end
    end
end

return ShowResultTotalCommand
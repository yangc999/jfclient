
local ResultTotalProxy = import("..proxy.ResultTotalProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ResultTotalCommand = class("ResultTotalCommand", SimpleCommand)

function ResultTotalCommand:execute(notification)
    print("-------------->ResultTotalCommand:execute")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(ResultTotalProxy.new())

    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local data = gameFacade:retrieveProxy("ResultTotalProxy"):getData()

    if name == MyGameConstants.PAIJU_INFO then
        local TimesData = {}
        TimesData.zmTimes = {}
        TimesData.dpTimes = {}
        TimesData.znTimes = {}
        TimesData.mgTimes = {}
        TimesData.agTimes = {}
        
        for k,v in pairs(body.vMJResult) do
            table.insert(TimesData.zmTimes,v.iZimo)
            table.insert(TimesData.dpTimes,v.iDianpao)
            table.insert(TimesData.znTimes,v.iNiao)
            table.insert(TimesData.mgTimes,v.iMingGang)
            table.insert(TimesData.agTimes,v.iAnGang)
        end
        data.TimesData = TimesData
        data.ScoreData = body.vScores
        data.Winers = body.vWiners
    end
end

return ResultTotalCommand
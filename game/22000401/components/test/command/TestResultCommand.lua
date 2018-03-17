local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local TestResultCommand = class("TestResultCommand", SimpleCommand)

function TestResultCommand:execute(notification)
    print("-------------->TestResultCommand:execute")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    if name == MyGameConstants.GAME_TEST then
        -- »»ÅÆ
        if body.iType == 2 and body.iCID == GameUtils:getInstance():getSelfServerChair() then
            if #data.SelfHandCards == #body.vTiles then
                local handCards = body.vTiles
                local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
                GameLogic:sort(handCards, deskInfo.LaiZi)
                data.SelfHandCards = handCards
                data.TestData = handCards
            end
        end
    end
end

return TestResultCommand
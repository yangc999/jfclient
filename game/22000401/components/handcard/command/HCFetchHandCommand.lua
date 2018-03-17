local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HCFetchHandCommand = class("HCFetchHandCommand", SimpleCommand)

function HCFetchHandCommand:execute(notification)
    print("-------------->HCFetchHandCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()

    if name == MyGameConstants.FETCH_HANDCARDS then
        local handCards = body.vAllTiles
        local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
        GameLogic:sort(handCards,deskInfo.LaiZi)
        data.HandCards = handCards
        data.SelfHandCards = handCards
        
        local visibleCards = {
            0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,0,0,0,
            0,0,0,0,0,0,0,
        }
        data.VisibleCards = visibleCards
        for k,v in pairs(handCards) do
            if data.VisibleCards[v] ~= nil then
                data.VisibleCards[v] = data.VisibleCards[v] + 1
            end
        end
    end
end

return HCFetchHandCommand
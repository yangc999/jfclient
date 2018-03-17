local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HCVideoFetchHandCommand = class("HCVideoFetchHandCommand", SimpleCommand)

function HCVideoFetchHandCommand:execute(notification)
    print("-------------->HCVideoFetchHandCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    local UserHandCards = {}

    if name == MyGameConstants.FETCH_VIDEO_HANDCARDS then
        local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
        for k,v in pairs(body.mCID_Handtile) do
            local handCards = v[2]
            GameLogic:sort(handCards,deskInfo.LaiZi)
            UserHandCards[k] = handCards
            if v[1] == GameUtils:getInstance():getSelfServerChair() then
                data.SelfHandCards = handCards
            end
        end
        data.UserHandCards = UserHandCards
        data.AllHandCards = UserHandCards
    end
end

return HCVideoFetchHandCommand
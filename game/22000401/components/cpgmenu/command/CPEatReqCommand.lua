
local SimpleCommand = cc.load("puremvc").SimpleCommand
local CPEatReqCommand = class("CPEatReqCommand", SimpleCommand)

local EatChoiceMediator = import("..mediator.EatChoiceMediator")

function CPEatReqCommand:execute(notification)
    print("-------------->CPEatReqCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("CPGMenuProxy"):getData()
    local ActNotifyData = data.ActNotifyData

    if name == MyGameConstants.C_EAT_REQ then

        -- 如果只有一种吃法就直接吃 否则就显示吃的选择界面
        local eatFlag = ActNotifyData.usChiFlags

        if eatFlag == MyGameConstants.EatType.usT
            or eatFlag == MyGameConstants.EatType.usZ
            or eatFlag == MyGameConstants.EatType.usW then
            -- 直接发送吃牌请求
            local pak1 = {
                chiValue = 0,
                ActFlag = MyGameConstants.MJActFlag.Chi,
                EatFlag = eatFlag,
            }
            GameUtils:getInstance():sendNotification(24, pak1, "MJContext::TMJ_actionPlayerReady")
        else
            -- 多种吃牌选择界面
            local image_root = gameFacade:retrieveMediator("MainMediator").image_root
            gameFacade:registerMediator(EatChoiceMediator.new(image_root))
        end


    end
end

return CPEatReqCommand

local SimpleCommand = cc.load("puremvc").SimpleCommand
local PlayerSitCommand = class("PlayerSitCommand", SimpleCommand)

function PlayerSitCommand:execute(notification)
    print("-------------->PlayerSitCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    if name == MyGameConstants.PLAYER_SIT then
        if body.iChairID >= 0 and body.iChairID <= 3 then
            local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
            local login = platformFacade:retrieveProxy("LoginProxy")
            if body.lPlayerID == login:getData().uid then
                dump(body,"player")
                print("玩家 chair = " .. tostring(body.iChairID) .. "发送准备消息")
                GameUtils:getInstance():setSelfServerChair(body.iChairID)              
                -- 发送准备通知
                gameFacade:sendNotification(MyGameConstants.C_PREPARE_REQ)
            end
            data.CurSitPlayer = body
            data.CurPlayerNums = data.CurPlayerNums + 1
        end
    end
end

return PlayerSitCommand
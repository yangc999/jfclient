
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PlayerRecomeCommand = class("PlayerRecomeCommand", SimpleCommand)

function PlayerRecomeCommand:execute(notification)
    print("-------------->PlayerRecomeCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()

    dump(body,"body")
    if name == MyGameConstants.PLAYER_RECOME then
        if body.iChairID >= 0 and body.iChairID <= 3 then
            local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
            local login = platformFacade:retrieveProxy("LoginProxy")
            if body.lPlayerID == login:getData().uid then
                --gameFacade:sendNotification(MyGameConstants.C_SHOW_LOADING_ANIMATE) -- 显示加载动画界面     
                GameUtils:getInstance():setSelfServerChair(body.iChairID)
                local pak2 = {
                    nVer = 1001,
                    nCmd = 13,
                    vecMsgData = 0,
                }
                local tarslib = cc.load("jfutils").Tars     
                local req2 = tarslib.encode(pak2, "JFGameSoProto::TSoMsg")
                print("--------->player recome")
                gameFacade:sendNotification(GameConstants.SEND_SOCKET, req2, 1) -- 请求断线重连数据
            end
            data.CurRecomePlayer = body
        end
    end
end

return PlayerRecomeCommand
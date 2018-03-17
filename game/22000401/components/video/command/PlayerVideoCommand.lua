
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PlayerVideoCommand = class("PlayerVideoCommand", SimpleCommand)

function PlayerVideoCommand:execute(notification)
    print("-------------->PlayerVideoCommand:execute")
    local name = notification:getName()
    local body = notification:getBody()
    local tp = notification:getType()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("VideoProxy"):getData()

    if data.CurIndex >= data.AllIndex then
        return
    end

    if body == nil then
        data.CurIndex = data.CurIndex + 1
    end
    
    local gameTp = data.GameMsgData[data.CurIndex][1]        -- 消息类型
    local gameResp = data.GameMsgData[data.CurIndex][2]      -- 消息数据
    local delayTime = 1     -- 每帧之间的延迟时间

    print("-------------->PlayerVideoCommand:tp = " .. tostring(gameTp))
    if name == MyGameConstants.C_PLAY_VIDEO then
        print("current frame = " .. tostring(data.CurIndex))
        print("gameTp = " .. tostring(gameTp))
        if body ~= nil then      -- 断线重连
            print("game station")
            local gameStateResp = data.GameStateData[data.CurIndex]
            gameFacade:sendNotification(MyGameConstants.GAME_STATION, gameStateResp)
        elseif gameTp == 16 then  -- 游戏开始消息
            gameFacade:sendNotification(MyGameConstants.START_GAME, gameResp,gameTp)
        elseif gameTp == 17 then  -- 定庄消息
            delayTime = 2
            gameFacade:sendNotification(MyGameConstants.MAKE_NT, gameResp,gameTp)
        elseif gameTp == 19 then  -- 漂结果消息
            gameFacade:sendNotification(MyGameConstants.PIAO_RESP, gameResp,gameTp)
        elseif gameTp == 20 then  -- 发牌消息
            gameFacade:sendNotification(MyGameConstants.FETCH_VIDEO_HANDCARDS, gameResp,gameTp)
        elseif gameTp == 21 then  -- 得令牌消息
            gameFacade:sendNotification(MyGameConstants.GET_TOKEN, gameResp,gameTp)
        elseif gameTp == 23 then  -- 出牌消息
            gameFacade:sendNotification(MyGameConstants.C_CANCEL_CURSAME_CARD,gameTp)
            gameFacade:sendNotification(MyGameConstants.OUTCARD_INFO, gameResp,gameTp)
        elseif gameTp == 24 then  -- 动作消息
            data.ActNotifyData = gameResp
        elseif gameTp == 25 then

        elseif gameTp == 26 then  -- 动作结果消息
            gameFacade:sendNotification(MyGameConstants.ACT_INFO, gameResp,gameTp)
        elseif gameTp == 27 then  -- 抓鸟消息
            delayTime = 2.5
            gameFacade:sendNotification(MyGameConstants.NIAO_CARD, gameResp,gameTp)
        elseif gameTp == 28 then  -- 单局结算消息
            gameFacade:sendNotification(MyGameConstants.ROUND_FINISH, gameResp,gameTp)
            gameFacade:sendNotification(MyGameConstants.C_GAME_INIT)
        end

        -- 播放下一帧
        if data.IsPause == false and data.CurIndex < data.AllIndex then
            local root = gameFacade:retrieveMediator("VideoMediator").root
            performWithDelay(root,function()
                gameFacade:sendNotification(MyGameConstants.C_PLAY_VIDEO)
            end,delayTime)
        end
    end
end

return PlayerVideoCommand
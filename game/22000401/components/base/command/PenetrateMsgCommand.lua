
local SimpleCommand = cc.load("puremvc").SimpleCommand
local PenetrateMsgCommand = class("PenetrateMsgCommand", SimpleCommand)

function PenetrateMsgCommand:execute(notification)
    print("-------------->PenetrateMsgCommand:execute")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
	
    print("-------------->PenetrateMsgCommand:tp = " .. tostring(tp))
    if name == GameConstants.PENETRATE_MSG then
        local tarslib = cc.load("jfutils").Tars     
        if tp == 109 then      -- 玩家坐下
            dump(body,"resp_sit")
            if body.iResultID == 0 then
                gameFacade:sendNotification(MyGameConstants.PLAYER_SIT,body) 
            else
                gameFacade:sendNotification(GameConstants.EXIT_GAME)
            end
        elseif tp == 105 then  -- 玩家离桌
            dump(body,"resp_stand")
            gameFacade:sendNotification(MyGameConstants.PLAYER_STAND,body)  
        elseif tp == 96 then   -- 玩家掉线
            dump(body,"resp_offline")
            gameFacade:sendNotification(MyGameConstants.PLAYER_OFFLINE,body) 
        elseif tp == 97 then   -- 玩家重入
            dump(body,"resp_recome")
            gameFacade:sendNotification(MyGameConstants.PLAYER_RECOME,body)        
        elseif tp == 3 then  -- 3为游戏消息
            -- 快速开始模式还未坐下时，不处理游戏消息
            if GameUtils:getInstance():getGameType() == 3 and gameFacade:retrieveProxy("PlayerInfoProxy"):getData().CurPlayerNums ~= 4 then
                return
            end

            local _, resp = tarslib.decode(body, "JFGameSoProto::TSoMsg")
            local gameTP = resp.nCmd
            dump(resp, "resp")

            if gameTP == 14 then  -- 断线重连
                print("game station")
                local _, resp1 = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyPushStatDataNew")
                dump(resp1,"resp1")
                local _ = nil
                local gameResp = nil
                if resp1.eMJState < 15 or resp1.eMJState == 24 then
                     _, gameResp = tarslib.decode(resp1.vecMsgData, "MJProto::TResumePreTile")
                elseif resp1.eMJState == 15 then
                     _, gameResp = tarslib.decode(resp1.vecMsgData, "MJProto::TResumeJiaPiao")
                elseif resp1.eMJState >= 16 and resp1.eMJState < 24 then
                     _, gameResp = tarslib.decode(resp1.vecMsgData, "MJProto::TResumePlaying")
                end
                gameResp.eMJState = resp1.eMJState
                dump(gameResp, "gameStationResp",10)
                gameFacade:sendNotification(MyGameConstants.GAME_STATION,gameResp)
            elseif gameTP == 15 then  -- 同意消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_actionPlayerReady")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.AGREE_GAME,gameResp)
            elseif gameTP == 16 then  -- 游戏开始消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyGameBegin")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.START_GAME,gameResp)
            elseif gameTP == 17 then  -- 定庄消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyChoseZhuang")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.MAKE_NT,gameResp)
            elseif gameTP == 18 then  -- 漂通知消息
                gameFacade:sendNotification(MyGameConstants.PIAO_NOTIFY)
            elseif gameTP == 19 then  -- 漂结果消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_actionJiaPiao")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.PIAO_RESP,gameResp)
            elseif gameTP == 20 then  -- 发牌消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyDealTile")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.FETCH_HANDCARDS,gameResp.sSelfTiles)
            elseif gameTP == 21 then  -- 得令牌消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyDrawedTile")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.GET_TOKEN,gameResp)
            elseif gameTP == 23 then  -- 出牌消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_actionDoDiscard")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.C_CANCEL_CURSAME_CARD)
                gameFacade:sendNotification(MyGameConstants.OUTCARD_INFO, gameResp)
            elseif gameTP == 24 then  -- 动作消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyCanCPGHG")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.ACT_NOTIFY, gameResp)
            elseif gameTP == 25 then
                
            elseif gameTP == 26 then  -- 动作结果消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyActivedCPGHG")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.ACT_INFO, gameResp)
            elseif gameTP == 27 then  -- 抓鸟消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyZhuaNiao")
                dump(gameResp, "gameResp")
                gameFacade:sendNotification(MyGameConstants.NIAO_CARD, gameResp)
            elseif gameTP == 28 then  -- 单局结算消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyRoundFinish")
                dump(gameResp, "gameResp",5)
                gameFacade:sendNotification(MyGameConstants.ROUND_FINISH, gameResp)
                gameFacade:sendNotification(MyGameConstants.C_GAME_INIT)
            elseif gameTP == 29 then  -- 总结算消息
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyGameFinish")
                dump(gameResp, "gameResp",5)
                gameFacade:sendNotification(MyGameConstants.PAIJU_INFO, gameResp)
            elseif gameTP == 30 then  -- 某玩家托管或者取消托管
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_notifyPlayerAuto")
                dump(gameResp, "gameResp",5)
                gameFacade:sendNotification(MyGameConstants.AUTO_INFO, gameResp)
            elseif gameTP == 32 then  -- 配牌
                local _, gameResp = tarslib.decode(resp.vecMsgData, "MJProto::TMJ_Test")
                dump(gameResp, "gameResp",5)
                gameFacade:sendNotification(MyGameConstants.GAME_TEST, gameResp)
            end
        end
    end
end

return PenetrateMsgCommand

local ResultMediator = import("..mediator.ResultMediator")
local ResultProxy = import("..proxy.ResultProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local ResultCommand = class("ResultCommand", SimpleCommand)

function ResultCommand:execute(notification)
    print("-------------->ResultCommand:execute")
    local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")

    if GameUtils:getInstance():getGameType() == 4 then
        local AllScore = {}
        for k,v in pairs(body.vScoreDetail) do
            table.insert(AllScore,v.iSumScore)
        end
        -- 刷新玩家头像总分
        local playerInfo = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
        local allScoreData = { }
        for i = 1, #AllScore do
            allScoreData[i] = playerInfo.ScoreData[i] + AllScore[i]
        end
        playerInfo.ScoreData = allScoreData

        return
    end

    gameFacade:registerProxy(ResultProxy.new())
	gameFacade:registerMediator(ResultMediator.new())
    
    local MyGameConstants = cc.exports.MyGameConstants
    local data = gameFacade:retrieveProxy("ResultProxy"):getData()

    if name == MyGameConstants.ROUND_FINISH then
        local Round = {}
        Round.iNowRound = body.iNowRound
        Round.iAllRound = body.iAllRound
        data.Round = Round
        
        local ScoreData = {}
        ScoreData.HuScore = {}
        ScoreData.GangScore = {}
        ScoreData.NiaoScore = {}
        ScoreData.PiaoScore = {}
        ScoreData.AllScore = {}
        for k,v in pairs(body.vScoreDetail) do
            table.insert(ScoreData.HuScore,v.iHuedScore)
            table.insert(ScoreData.GangScore,v.iGangScore)
            table.insert(ScoreData.NiaoScore,v.iNiaoScore)
            table.insert(ScoreData.PiaoScore,v.iPiaoScore)
            table.insert(ScoreData.AllScore,v.iSumScore)
        end
        -- 刷新玩家头像总分
        if GameUtils:getInstance():getGameType() ~= 10 then
            local playerInfo = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
            local allScoreData = { }
            for i = 1, #ScoreData.AllScore do
                allScoreData[i] = playerInfo.ScoreData[i] + ScoreData.AllScore[i]
            end
            playerInfo.ScoreData = allScoreData
        end

        data.ScoreData = ScoreData
        data.bFinished = body.bFinished
        data.HuUserChair = body.mj_nHuederCID
        if body.mj_nHuederCID == 255 then
            data.HandCardData = body.vTiles[GameUtils:getInstance():getSelfServerChair() + 1]
        else
            data.HandCardData = body.vTiles[body.mj_nHuederCID + 1]
        end

        local NiaoCard = gameFacade:retrieveProxy("DeskInfoProxy"):getData().NiaoCard
        if #NiaoCard >= 1 then
            data.NiaoCardData = NiaoCard
        end

        -- 等待下一局状态
        local gameRoom = gameFacade:retrieveProxy("GameRoomProxy")
        gameRoom:getData().gameState = MyGameConstants.GameStation.GS_WAIT_NEXT_ROUND
    end

end

return ResultCommand
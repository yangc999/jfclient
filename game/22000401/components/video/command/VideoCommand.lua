local GameLogic = import("....GameLogic")
local VideoMediator = import("..mediator.VideoMediator")
local VideoProxy = import("..proxy.VideoProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local VideoCommand = class("VideoCommand", SimpleCommand)

function VideoCommand:execute(notification)
    print("-------------->VideoCommand:execute")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local GameMsgData = {}
    local GameStateData = {}  -- 断线重连数据

    local tarslib = cc.load("jfutils").Tars     
    local videoData = platformFacade:retrieveProxy("MatchRecordsProxy"):getData().watchVideo
    local _,resp = tarslib.decode(videoData,"MJProto::TMJ_VideoData")
    dump(resp, "resp",10)

    -- 自己椅子号
    local login = platformFacade:retrieveProxy("LoginProxy")
    for k, v in pairs(resp.vPlayerInfo) do
        if v.iPlayerID == login:getData().uid then
            GameUtils:getInstance():setSelfServerChair(v.iCID)
        end
    end

    -- 玩家信息
    local playerInfo = gameFacade:retrieveProxy("PlayerInfoProxy"):getData()
    playerInfo.AllUserInfo = resp.vPlayerInfo

    for i,msg in pairs(resp.mCount_VideoMsg) do
        local structName = ""
        local tp = msg[2].mType_Msg[1][1]
        print("tp = " .. tostring(tp))
        if tp == 16 then      -- 游戏开始
            structName = "MJProto::TMJ_notifyGameBegin"
        elseif tp == 17 then  -- 定庄
            structName = "MJProto::TMJ_notifyChoseZhuang"
        elseif tp == 19 then  -- 漂结果
            structName = "MJProto::TMJ_actionJiaPiao"
        elseif tp == 20 then  -- 发牌
            structName = "MJProto::TMJ_Video_Dealtile"
        elseif tp == 21 then  -- 得令牌
            structName = "MJProto::TMJ_notifyDrawedTile"
        elseif tp == 23 then  -- 出牌
            structName = "MJProto::TMJ_actionDoDiscard"
        elseif tp == 24 then  -- 动作
            structName = "MJProto::TMJ_notifyCanCPGHG"
        elseif tp == 26 then  -- 动作结果
            structName = "MJProto::TMJ_notifyActivedCPGHG"
        elseif tp == 27 then  -- 抓鸟
            structName = "MJProto::TMJ_notifyZhuaNiao"
        elseif tp == 28 then  -- 单局结算
            structName = "MJProto::TMJ_notifyRoundFinish"
        end

        if structName ~= "" then
            local _, gameResp = tarslib.decode(msg[2].mType_Msg[1][2], structName)
            local msg = {}
            msg[1] = tp
            msg[2] = gameResp
            table.insert(GameMsgData,msg)
            --dump(gameResp,"gameResp",10)
        end
    end

    local root = notification:getBody()
    gameFacade:registerProxy(VideoProxy.new())

    -- 消息数据
    local videoProxyData = gameFacade:retrieveProxy("VideoProxy"):getData()
    videoProxyData.GameMsgData = GameMsgData
    dump(videoProxyData.GameMsgData,"GameMsgData",10)

    -- 发牌前的数据
    local preTileState = {
        mj_iNowRound = 0,
        mj_iAllRound = 0,
        iZhuangCID = -1,
        vPlayerScores = {0,0,0,0},
        vBPlayerReady = {false,false,false,false},
    }

    --加飘时的数据
    local piaoState = {
        sPreTile = preTileState,
        vPiaoPoint = {255,255,255,255},
    }

    -- 打牌时的数据
    local playingState = {
        sPiaoStat = piaoState,
        wallNumas = -1,
        iTokenOwnerCID = -1,
        vAllHandtiles = {
            {vAllTiles = {},vChiPengGang = {}},
            {vAllTiles = {},vChiPengGang = {}},
            {vAllTiles = {},vChiPengGang = {}},
            {vAllTiles = {},vChiPengGang = {}},
        },
        mCID_DisCarded = {{0,{}},{1,{}},{2,{}},{3,{}}},
        sCanAct = {
            iCID = 0,
            mj_vActs = {},
        },
        mj_iLastTilepos = -1,
        mj_iLastOuterCID = -1,
        niaoCards = {},
    }
    for k,v in pairs(resp.vPlayerInfo) do
        preTileState.vPlayerScores[v.iCID + 1] = v.iScore
    end
    for k,v in pairs(GameMsgData) do
        playingState.sCanAct = {iCID = 0,mj_vActs = {}}
        local eMJState = 10
        local gameResp = {}
        if v[1] == 16 then -- 游戏开始
            eMJState = 12
            preTileState.mj_iNowRound = v[2].mj_iNowRound
            preTileState.mj_iAllRound = v[2].mj_iAllRound
            gameResp = clone(preTileState)
        elseif v[1] == 17 then -- 定庄
            eMJState = 14
            preTileState.iZhuangCID = v[2].nBankerCID
            gameResp = clone(preTileState) 
        elseif v[1] == 19 then -- 加飘
            eMJState = 15
            piaoState.vPiaoPoint[v[2].iCID + 1] = v[2].iPiaoPoint
            gameResp = clone(piaoState)
        elseif v[1] == 20 then -- 发手牌
            eMJState = 16
            for i,handCard in pairs(v[2].mCID_Handtile) do
                playingState.vAllHandtiles[handCard[1] + 1].vAllTiles = handCard[2]
            end
            gameResp = clone(playingState)
        elseif v[1] == 21 then -- 得令牌
            eMJState = 17
            if v[2].eDrawedTile ~= 254 then
                table.insert(playingState.vAllHandtiles[v[2].iCID + 1].vAllTiles,v[2].eDrawedTile)
            end
            playingState.iTokenOwnerCID = v[2].iCID
            playingState.wallNumas = v[2].iTileWallNums
            gameResp = clone(playingState)
        elseif v[1] == 23 then -- 出牌
            eMJState = 18
            GameLogic:removeOneItemInTable(playingState.vAllHandtiles[v[2].iCID + 1].vAllTiles, v[2].eDisCardedTile)
            local len = #playingState.mCID_DisCarded[v[2].iCID + 1][2]
            playingState.mCID_DisCarded[v[2].iCID + 1][2][len + 1] = v[2].eDisCardedTile
            playingState.mj_iLastTilepos = len + 1
            playingState.mj_iLastOuterCID = v[2].iCID
            gameResp = clone(playingState)
        elseif v[1] == 24 then -- 动作通知
            eMJState = 19
            playingState.sCanAct = v[2]
            gameResp = clone(playingState)
        elseif v[1] == 26 then -- 动作结果
            eMJState = 19
            local iType = v[2].sAct.iType
            local iActCID = v[2].sAct.iActCID
            local eActTile = v[2].sAct.eActTile
            local len = #playingState.mCID_DisCarded[v[2].sAct.iFromCID + 1][2]
            if table.nums(v[2].sCPG.vTiles) > 0 then
                table.insert(playingState.vAllHandtiles[iActCID + 1].vChiPengGang,v[2].sCPG)
            end
            playingState.vAllHandtiles[iActCID + 1].vAllTiles = v[2].vAllTiles
            playingState.mCID_DisCarded[v[2].sAct.iFromCID + 1][2][len] = nil
            playingState.iTokenOwnerCID = iActCID
            playingState.mj_iLastTilepos = -1
            playingState.mj_iLastOuterCID = v[2].sAct.iFromCID
            gameResp = clone(playingState)
        elseif v[1] == 27 then -- 抓鸟
            eMJState = 21
            gameResp = clone(playingState)
        end

        if v[1] ~= 28 then
            gameResp.eMJState = eMJState
            table.insert(GameStateData,gameResp)
        end
    end
    videoProxyData.GameStateData = GameStateData
    dump(GameStateData,"GameStateData",10)

    videoProxyData.AllIndex = #GameMsgData
	gameFacade:registerMediator(VideoMediator.new(root))
end

return VideoCommand
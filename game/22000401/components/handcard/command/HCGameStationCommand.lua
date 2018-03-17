local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HCGameStationCommand = class("HCGameStationCommand", SimpleCommand)

function HCGameStationCommand:execute(notification)
    print("-------------->HCGameStationCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    if name == MyGameConstants.GAME_STATION then
        -- 判断令牌是不是在自己手中
        if body.eMJState >= 16 and body.eMJState < 24 then
            if body.iTokenOwnerCID == GameUtils:getInstance():getSelfServerChair() then
                data.IsCanOutCard = true
            end

            local server_chair = GameUtils:getInstance():getSelfServerChair()
            local handCards = body.vAllHandtiles[server_chair + 1].vAllTiles
            local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
            GameLogic:sort(handCards, deskInfo.LaiZi)
            data.SelfHandCards = handCards

            -- 断线重连录像中保存全部玩家手牌
            if GameUtils:getInstance():getGameType() == 10 then
                dump(body.vAllHandtiles,"body.vAllHandtiles",10)
                for k, v in pairs(body.vAllHandtiles) do
                    local cards = clone(v.vAllTiles)
                    GameLogic:sort(cards, deskInfo.LaiZi)
                    data.AllHandCards[k] = cards
                end
            end

            -- 桌面可见牌处理
            for k, v in pairs(handCards) do
                if data.VisibleCards[v] ~= nil then
                    data.VisibleCards[v] = data.VisibleCards[v] + 1
                end
            end

            local allHandCards = body.vAllHandtiles
            if table.nums(allHandCards) >= 1 then
                for k, v in pairs(allHandCards) do
                    local ui_chair = GameUtils:getInstance():getUIChairByServerChair(k - 1)
                    if v.vChiPengGang ~= nil and table.nums(v.vChiPengGang) >= 1 then
                        for i, cpData in pairs(v.vChiPengGang) do
                            local bAnGang = cpData.bAnGang
                            local iType = cpData.iType
                            local nIndex = cpData.index + 1
                            local cardData = cpData.vTiles
                            if iType == MyGameConstants.MJActFlag.Chi
                                or iType == MyGameConstants.MJActFlag.Peng then
                                for n = 1, 3 do
                                    if data.VisibleCards[cardData[n]] ~= nil then
                                        data.VisibleCards[cardData[n]] = data.VisibleCards[cardData[n]] + 1
                                    end
                                end
                            elseif iType >= MyGameConstants.MJActFlag.DianGang and iType <= MyGameConstants.MJActFlag.BuGang then
                                if bAnGang == true then
                                    local bShow = false
                                    if k - 1 == GameUtils:getInstance():getSelfServerChair() then
                                        bShow = true
                                    else
                                        if MyGameConstants.IS_SHOW_ANGANG_CARD then
                                            bShow = true
                                        end
                                    end
                                    for n = 1, 4 do
                                        if data.VisibleCards[cardData[n]] ~= nil then
                                            data.VisibleCards[cardData[n]] = data.VisibleCards[cardData[n]] + 1
                                        end
                                    end

                                else
                                    for n = 1, 4 do
                                        if data.VisibleCards[cardData[n]] ~= nil then
                                            data.VisibleCards[cardData[n]] = data.VisibleCards[cardData[n]] + 1
                                        end
                                    end
                                end
                            end
                        end
                    end
                end
            end

            local outCardData = body.mCID_DisCarded
            if table.nums(outCardData) >= 1 then
                for k, v in pairs(outCardData) do
                    for index, vaule in pairs(v[2]) do
                        if data.VisibleCards[vaule] ~= nil then
                            data.VisibleCards[vaule] = data.VisibleCards[vaule] + 1
                        end
                    end
                end
            end
        end
        data.GameStationData = body
    end
end

return HCGameStationCommand
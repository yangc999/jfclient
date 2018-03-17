local GameLogic = import("....GameLogic")
local SimpleCommand = cc.load("puremvc").SimpleCommand
local HCActInfoCommand = class("HCActInfoCommand", SimpleCommand)

function HCActInfoCommand:execute(notification)
    print("-------------->HCActInfoCommand:execute")
	local name = notification:getName()
	local body = notification:getBody()
	local tp = notification:getType()
    local MyGameConstants = cc.exports.MyGameConstants
	
    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local data = gameFacade:retrieveProxy("HandCardProxy"):getData()
    if name == MyGameConstants.ACT_INFO then
        local deskInfo = gameFacade:retrieveProxy("DeskInfoProxy"):getData()
        -- 吃碰杠时重新刷新手牌
        if body.sAct.iActCID == GameUtils:getInstance():getSelfServerChair() then
            local handCards = body.vAllTiles
            GameLogic:sort(handCards, deskInfo.LaiZi)
            data.SelfHandCards = handCards
            print("---> SelfHandCards")
            dump(data.SelfHandCards, "SelfHandCards")
        else
            local handTab = body.vAllTiles
            GameLogic:sort(handTab, deskInfo.LaiZi)
            data.AllHandCards[body.sAct.iActCID + 1] = handTab

            -- 保存可见牌
            local vTiles = body.sCPG.vTiles
            if body.sAct.eAction == MyGameConstants.MJActFlag.Chi then
                for k, v in pairs(vTiles) do
                    if body.sAct.eActTile ~= v then
                        if data.VisibleCards[v] ~= nil then
                            data.VisibleCards[v] = data.VisibleCards[v] + 1
                        end
                    end
                end
            elseif body.sAct.eAction == MyGameConstants.MJActFlag.Peng then
                if data.VisibleCards[body.sAct.eActTile] ~= nil then
                    data.VisibleCards[body.sAct.eActTile] = data.VisibleCards[body.sAct.eActTile] + 2
                end
            elseif body.sAct.eAction == MyGameConstants.MJActFlag.DianGang then
                if data.VisibleCards[body.sAct.eActTile] ~= nil then
                    data.VisibleCards[body.sAct.eActTile] = data.VisibleCards[body.sAct.eActTile] + 3
                end
            elseif body.sAct.eAction == MyGameConstants.MJActFlag.AnGang then
                if MyGameConstants.IS_SHOW_ANGANG_CARD then
                    if data.VisibleCards[body.sAct.eActTile] ~= nil then
                        data.VisibleCards[body.sAct.eActTile] = data.VisibleCards[body.sAct.eActTile] + 4
                    end
                end
            elseif body.sAct.eAction == MyGameConstants.MJActFlag.BuGang then
                if data.VisibleCards[body.sAct.eActTile] ~= nil then
                    data.VisibleCards[body.sAct.eActTile] = data.VisibleCards[body.sAct.eActTile] + 1
                end
            end
        end

        data.ActInfoData = body
    end
end

return HCActInfoCommand
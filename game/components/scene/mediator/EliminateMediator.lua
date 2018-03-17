
local Mediator = cc.load("puremvc").Mediator
local EliminateMediator = class("EliminateMediator", Mediator)

function EliminateMediator:ctor()
    print("EliminateMediator:ctor")
	EliminateMediator.super.ctor(self, "EliminateMediator")
end

function EliminateMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
	}
end

function EliminateMediator:onRegister()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
	local GameConstants = cc.exports.GameConstants
    local ui = cc.CSLoader:createNode("game/res/ui_csb/EliminateLayer.csb")
    local eliminateData=gameFacade:retrieveProxy("EliminateProxy")
    local rankData=eliminateData:getData().rankMsg
    local matchData=eliminateData:getData().matchMsg
    dump(matchData,"matchData")
    dump(eliminateData:getData(),"eliminateData",10)
    self.rewardText=seekNodeByName(ui,"reward_text")
    self.qrcodeImg=seekNodeByName(ui,"qrcode_img")
    self.rankText=seekNodeByName(ui,"rank_text")
    self.againBtn=seekNodeByName(ui,"again_btn")
    self.shareBtn=seekNodeByName(ui,"share_btn")
    self.backBtn=seekNodeByName(ui,"back_btn")
    self.icon=seekNodeByName(ui,"icon")
    local richText = ccui.RichText:create()
    richText:ignoreContentAdaptWithSize(true) 
    richText:setAnchorPoint(cc.p(0.5,0.5))
    local textFont="font/fangzhenyuanstatic.ttf"
    local element1 = ccui.RichElementText:create(1, cc.c3b(255,255,255), 255, "恭喜您在".. tostring(os.date("%H:%M",rankData.iKnockOutTime)) .."结束的", textFont, 24)
    local element2 = ccui.RichElementText:create(1, cc.c3b(255,244,92), 255, "【"..matchData.sMatchName.."】", textFont, 30)
    local element3 = ccui.RichElementText:create(1, cc.c3b(255,255,255), 255, matchData.iPlayers.."人赛中荣获", textFont, 24)
    richText:pushBackElement(element1)
    richText:pushBackElement(element2)
    richText:pushBackElement(element3)
    richText:setPosition(640,423)
    ui:addChild(richText)
    self.againBtn:addClickEventListener(function ()
        gameFacade:removeMediator("EliminateMediator")
        gameFacade:sendNotification(GameConstants.EXIT_GAME)
        platformFacade:sendNotification(PlatformConstants.START_COMPETITIONLIST)
    end)
    self.shareBtn:addClickEventListener(function ()
        cc.utils:captureScreen( function(succeed, outputFile)
            if succeed then
                local strScene = "0"  -- 0 分享到好友   1 分享到朋友圈
                local ShareFriendUrl = "http://share.game4588.com" -- 好友分享网址
                local imageName = cc.FileUtils:getInstance():getWritablePath() .. "game_share.png"
                local strImgPath = cc.FileUtils:getInstance():fullPathForFilename(imageName)
                cc.exports.wxShareFriends(ShareFriendUrl, "", "", strImgPath, strScene)
            end
        end ,
        "game_share.png")
    end)
    self.backBtn:addClickEventListener(function ()
        gameFacade:removeMediator("EliminateMediator")
        gameFacade:sendNotification(GameConstants.EXIT_GAME)
    end)
    local rewardType=""
    local awardValue = 0
    if matchData.vecMatchAwards ~= nil then
        awardValue = matchData.vecMatchAwards.iAwardValue
        local iAwardType = matchData.vecMatchAwards.iAwardType
        if iAwardType ~= nil and iAwardType == 2 then
            rewardType = "钻石"
        elseif iAwardType ~= nil and iAwardType == 3 then
            rewardType = "房卡"
        elseif iAwardType ~= nil and iAwardType == 4 then
            rewardType = "金币"
        end
    end
    self.rewardText:setString("奖励：" .. rewardType .. "×" .. tostring(awardValue))
    self.rankText:setString(rankData.iRanking)
    local iconPath="game/res/ui_res/eliminate/taotai.png"
--    if rankData.iRanking<=4 then
--       iconPath="game/res/ui_res/eliminate/shengli.png"
--    end
    if matchData.vecMatchAwards ~= nil and rankData.iRanking<=4 then
       iconPath="game/res/ui_res/eliminate/shengli.png"
    end
    self.icon:loadTexture(iconPath)
    self:setViewComponent(ui)
	local scene = gameFacade:retrieveMediator("SceneMediator").scene
	scene:addChild(ui)
end

function EliminateMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    self:getViewComponent():removeFromParent()
	gameFacade:removeProxy("EliminateProxy")
end

function EliminateMediator:handleNotification(notification)
end

return EliminateMediator
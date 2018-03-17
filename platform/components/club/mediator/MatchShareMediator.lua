--region *.lua
--Date
--比赛分享的UI
local Mediator = cc.load("puremvc").Mediator
local MatchShareMediator = class("MatchShareMediator", Mediator)

local ShareUrl = "http://share.game4588.com"

function MatchShareMediator:ctor(payno)
	MatchShareMediator.super.ctor(self, "MatchShareMediator")
	--self.payno = payno  --设置根结点
end

function MatchShareMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
	return {
       -- PlatformConstants.RESULT_BINDMOBILE,
	}
end

function MatchShareMediator:onRegister()
    print("MatchShareMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    --platformFacade:registerCommand(PlatformConstants.START_BINDMOBILE, cc.exports.StartBindMobileCommand) --注册启动设置银行取款密码界面

    local ui = cc.CSLoader:createNode("hall_res/club/matchshare.csb")  --设置UI的csb
	self:setViewComponent(ui)
	local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
	scene:addChild(self:getViewComponent())

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景
     --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:setZoomScale(-0.1)
		btnClose:addClickEventListener(function()
			platformFacade:removeMediator("MatchShareMediator")
		end)
	end

    --获取分享朋友的按钮
    local btnShareFriend = seekNodeByName(self.bgImg, "btn_Friend")
    if btnShareFriend then
       btnShareFriend:addClickEventListener(function()
            print("开始分享到朋友圈") --function(strUrl, strTitle, strDesc, strImgPath, strScene)
             local strImgPath = cc.FileUtils:getInstance():fullPathForFilename("platform_res/share/task-5.png")
			 cc.exports.wxShareFriends(ShareUrl, "分享好友", "请看我玩的最好玩最火爆的棋牌游戏",strImgPath, "0")
		end)
    end

    --获取分享到朋友圈的按钮
    local btnShareMoments = seekNodeByName(self.bgImg, "btn_Moments")
    if btnShareMoments then
       btnShareMoments:addClickEventListener(function()
            print("开始分享到朋友圈")
			local strImgPath = cc.FileUtils:getInstance():fullPathForFilename("platform_res/share/task-4.png")
			 cc.exports.wxShareFriends(ShareUrl, "分享朋友圈", "请看我玩的最好玩最火爆的棋牌游戏",strImgPath, "1")
		end)
    end
end

function MatchShareMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

end

function MatchShareMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.START_BINDMOBILE)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return MatchShareMediator
--endregion

--region *.lua
--Date
--显示中奖动画的UI
local Mediator = cc.load("puremvc").Mediator
local GiftAnimMediator = class("GiftAnimMediator", Mediator)
local ShareFriendUrl = "http://share.game4588.com"

function GiftAnimMediator:ctor(type)

	GiftAnimMediator.super.ctor(self, "GiftAnimMediator")
    self.mType = type

end

function GiftAnimMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
        PlatformConstants.START_LOGOUT,
        PlatformConstants.RESULT_WEIXINSHARE,
	}
end

function GiftAnimMediator:onRegister()
  print(" GiftAnimMediator:onRegister")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
  local lotteryProxy = platformFacade:retrieveProxy("LotteryProxy")

  --platformFacade:registerCommand(PlatformConstants.START_LOGIN, cc.exports.StartLoginCommand)
  local ui = cc.CSLoader:createNode("hall_res/lottery/giftLayer.csb")  --设置UI的csb
  self:setViewComponent(ui)
  --local scene = cc.Director:getInstance():getRunningScene()
  local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
  scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景

  --转盘灯的动画
  self.Panel = seekNodeByName(ui, "Panel_1")--背景

  local btnShare = seekNodeByName(ui, "btn_share") --分享按钮
    if btnShare then
		btnShare:addClickEventListener(function()
            btnShare:setZoomScale(-0.1)
			--platformFacade:removeMediator("LotteryMediator")
            --发送分享
            local gameName = cc.exports.getProductName()
            local strImgPath = cc.FileUtils:getInstance():fullPathForFilename("platform_res/share/share.png") --图标
            local strTitle = "分享好友"
            local strDesc = "长按二维码免费领房卡礼包并可参与" .. gameName .."所有活动。\n" .. gameName .."戏活动，日送十万豪礼。"
            local strScene = "1"  --0 分享到好友   1 分享到朋友圈
            cc.exports.wxShareFriends(ShareFriendUrl, strTitle, strDesc, strImgPath, strScene)  --发送请求微信分享的请求
		end)
	end

  --获取关闭按钮
  local btnClose = seekNodeByName(ui, "btn_cancle")
	if btnClose then
		btnClose:addClickEventListener(function()
            print("click btnClose")
            btnClose:setZoomScale(-0.1)
			platformFacade:removeMediator("GiftAnimMediator")
		end)
	end
  --出现动画
  --cc.exports.showGetAnimation(ui)
  self.animator = seekNodeByName(ui, "get_animal")
	local animation = cc.CSLoader:createTimeline("hall_res/qiandao/qiandao.csb")
	---提示创建动画并启动
	print("start create animation")
  --帧事件
  local onFrameEvent = function(frame)
    local eventName = frame:getEvent()
    if eventName == "daidai" then
       print("daidai event事件")
       animation:gotoFrameAndPlay(51, true)  --当动画播放到标记有"daidai"帧事件时，就从51帧开始不停轮播，帧事件要在cocostudio 动画里设置，
    end                                                           --如qiandao.csd 先要勾选 “开始记录动画”，再点击某一关键帧，设置帧事件名字为 daidai 即可
  end
  --开始播放动画，从0帧开始，false表示播放完后不循环
	animation:gotoFrameAndPlay(0, false)
  animation:setFrameEventCallFunc(onFrameEvent)  --设置帧事件监听
	self.animator:setVisible(true)
	self.animator:runAction(animation)

  local drawResult = lotteryProxy:getData().rollerResult
  if drawResult~=nil then
     dump(drawResult, "抽奖结果")
     local name = drawResult.sPropName
     performWithDelay(self:getViewComponent(), function() 
        -- platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE,"恭喜您抽得:" .. name .. " 大奖")
     end,1)
  end
end

function GiftAnimMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    if name == PlatformConstants.START_LOGOUT then
       platformFacade:removeMediator("GiftAnimMediator")
    elseif name == PlatformConstants.RESULT_WEIXINSHARE then
       print("RESULT_WEIXINSHARE 微信分享结果")
        if body == 0 then
           print("抽奖分享好友成功")
           platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "抽奖分享朋友圈成功")
        else
          print("抽奖分享好友失败，错误码:" .. tostring(body))
          platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "抽奖分享朋友圈失败")
        end
        platformFacade:removeMediator("GiftAnimMediator")
    end
end

function GiftAnimMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.REQUEST_BINDMOBILE)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return GiftAnimMediator
--endregion

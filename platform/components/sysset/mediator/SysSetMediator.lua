--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local Mediator = cc.load("puremvc").Mediator
local SysSetMediator = class("SysSetMediator", Mediator)

function SysSetMediator:ctor()
	  SysSetMediator.super.ctor(self, "SysSetMediator")
    self.voiceAuto = (cc.UserDefault:getInstance():getStringForKey("voiceAuto", "true")) == "true" and true or false --手动false，自动true 语音
end

function SysSetMediator:listNotificationInterests()
    local PlatformConstants = cc.exports.PlatformConstants
  	return {
  		PlatformConstants.START_LOGOUT, 
  	}
end

function SysSetMediator:onRegister()
    print("SysSetMediator:onRegister")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local PlatformConstants = cc.exports.PlatformConstants
    local hallProxy = platformFacade:retrieveProxy("HallProxy")
    
    platformFacade:registerCommand(PlatformConstants.START_GAMEHELPLAYER, cc.exports.StartGameHelpLayerCommand)
    platformFacade:registerCommand(PlatformConstants.START_USERAGREEUILAYER, cc.exports.StartUserAgreeUiCommand)

    local ui = cc.CSLoader:createNode("hall_res/set/hallsetLayer.csb")  --设置UI的csb
  	self:setViewComponent(ui)
    local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景 (大厅所在的场景)
  	scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景
    self.scene = scene

    -->>>> 获取按钮控件
    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--获取背景
    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
    --获取语音切换按钮
    local imgVoiceBg = seekNodeByName(self.bgImg, "imgVoiceBg")
    --获取背景音乐大小调整滑杆
    local slidBgMusic = seekNodeByName(self.bgImg, "slidBgMusic")
    --获取音效大小调整滑杆
    local slidBgEffect = seekNodeByName(self.bgImg, "slidBgEffect")
    --获取背景音乐开关
    local imgMusicIcon = seekNodeByName(self.bgImg, "imgMusicIcon")
    --获取音效开关
    local imgEffectIcon = seekNodeByName(self.bgImg, "imgEffectIcon")
    --获取游戏帮助按钮
    local btnHelp = seekNodeByName(self.bgImg, "btn_help")

    -->>>> 控件初始化
    --初始化语言开关
    if self.voiceAuto == false then  --当前是手动语音
        imgVoiceBg:loadTexture("platform_res/set/sd.png")
    else
        imgVoiceBg:loadTexture("platform_res/set/zd.png")
    end
    --背景音乐滑动杆初始化
    if slidBgMusic then
        local bgMusicVol = cc.UserDefault:getInstance():getIntegerForKey("bgMusicVolume")
        print("jaymusic bgMusicVol:"..bgMusicVol)
        if bgMusicVol==nil then
          bgMusicVol=50
        end
        slidBgMusic:setPercent(bgMusicVol)
    end
    --按钮音乐滑动杆初始化
    if slidBgEffect then
        local effectVol = cc.UserDefault:getInstance():getIntegerForKey("bgEffectVolume")
        print("jaymusic effectVol:"..effectVol)
        if effectVol==nil then
          effectVol=50
        end
        slidBgEffect:setPercent(effectVol)
    end
    --背景音乐开关按钮初始化
    if hallProxy:getData().bgMusicCanPlay == 1 then  --当前是开启音乐
        imgMusicIcon:loadTexture("platform_res/set/yinyue.png")
    else  --当前是关闭音乐
        imgMusicIcon:loadTexture("platform_res/set/yinyueclose.png")
    end
    --按钮音效开关按钮初始化
    if hallProxy:getData().effectMusicCanPlay == 1 then  --当前是开启音乐
        imgEffectIcon:loadTexture("platform_res/set/yinxiao.png")
    else  --当前是关闭音乐
        imgEffectIcon:loadTexture("platform_res/set/yinxiaoclose.png")
    end

    -->>>> 监听方法
    --关闭按钮监听
    if btnClose then
      btnClose:addClickEventListener(function()
        print("click btnClose btn")
        btnClose:setZoomScale(-0.1)
        platformFacade:removeMediator("SysSetMediator")
      end)
    end
    --语音开关监听
    local function switchVoice()
        if self.voiceAuto == false then  --当前是手动语音
          self.voiceAuto = true   --切换成自动语音
          cc.UserDefault:getInstance():setStringForKey("voiceAuto", "true")
          imgVoiceBg:loadTexture("platform_res/set/zd.png")
        else
          self.voiceAuto = false   --切换成手动语音
          cc.UserDefault:getInstance():setStringForKey("voiceAuto", "false")
          imgVoiceBg:loadTexture("platform_res/set/sd.png")
        end
    end
    imgVoiceBg:addClickEventListener(switchVoice)
    --背景音乐调节更新方法  
    local function updateBgMusicVol()
        local voiceNum = 0
        voiceNum = slidBgMusic:getPercent()
        print("jaymusic slidBgMusic set voiceNum:" .. voiceNum)
        cc.UserDefault:getInstance():setIntegerForKey("bgMusicVolume", voiceNum) --设定音效的音量大小
        local vol = voiceNum/100.0
        if vol > 1.0 then vol = 1.0 end
        if vol < 0.0 then vol = 0.0 end
        print("jaymusic slidBgMusic vol:" .. vol)
        ccexp.AudioEngine:setVolume(hallProxy:getData().bgMusicID,vol)
    end
    --背景音乐调节音量杆调节监听
    local function touchMusicMovedCallback(sender, eventType)
        print("jaymusic slidBgMusic touchMusicMovedCallback:",sender,"eventType:",eventType)
        if eventType == ccui.SliderEventType.slideBallDown then  --按下

        elseif eventType == ccui.SliderEventType.percentChanged then  --改变进度
          updateBgMusicVol()
        elseif eventType == ccui.SliderEventType.slideBallUp then  --抬起
          updateBgMusicVol()
        end
    end
    slidBgMusic:addEventListener(touchMusicMovedCallback)

    --更新按钮音量
    local function updateEffectVol()
        local voiceNum = 0
        voiceNum = slidBgEffect:getPercent()
        print("jaymusic voiceNum:" .. voiceNum)
        cc.UserDefault:getInstance():setIntegerForKey("bgEffectVolume", voiceNum) --设定音效的音量大小
    end
    --按钮音量调节监听
    local function touchMovedCallback(sender, eventType)
        print("jaymusic touchMovedCallback:",sender,"eventType:",eventType)
        if eventType == ccui.SliderEventType.slideBallDown then  --按下

        elseif eventType == ccui.SliderEventType.percentChanged then  --改变进度
          updateEffectVol()
        elseif eventType == ccui.SliderEventType.slideBallUp then  --抬起
          updateEffectVol()
        end
    end
    slidBgEffect:addEventListener(touchMovedCallback)

    --背景音乐开关监听  
    local function switchMusic()  --交替播放/停止音乐
        if hallProxy:getData().bgMusicCanPlay == 1 then  --当前是开启音乐
            hallProxy:getData().bgMusicCanPlay = 0   --关闭音乐   
            imgMusicIcon:loadTexture("platform_res/set/yinyueclose.png")
            ccexp.AudioEngine:pause(hallProxy:getData().bgMusicID)
        else  --当前是关闭音乐
            hallProxy:getData().bgMusicCanPlay = 1   --开启音乐  
            imgMusicIcon:loadTexture("platform_res/set/yinyue.png")
            ccexp.AudioEngine:resume(hallProxy:getData().bgMusicID)
        end
    end
    imgMusicIcon:addClickEventListener(switchMusic)
    --音效开关监听
    local function switchEffect()  --交替播放/停止音效
        if hallProxy:getData().effectMusicCanPlay == 1 then  --当前是开启音乐
          hallProxy:getData().effectMusicCanPlay = 0  
          imgEffectIcon:loadTexture("platform_res/set/yinxiaoclose.png")
        else  --当前是关闭音乐
          imgEffectIcon:loadTexture("platform_res/set/yinxiao.png")
          hallProxy:getData().effectMusicCanPlay=1
        end
    end
    imgEffectIcon:addClickEventListener(switchEffect)

    --帮助按钮监听  
    if btnHelp then
        local txtBtnHelp = seekNodeByName(btnHelp, "txtHelp")
        txtBtnHelp:enableOutline(cc.c3b(173, 35, 0), 2)
    		btnHelp:addClickEventListener(function()
            print("click btnHelp btn")
            --开启游戏帮助界面
            platformFacade:sendNotification(PlatformConstants.START_GAMEHELPLAYER)
            --platformFacade:sendNotification(PlatformConstants.START_CUSTOMHELPLAYER)
    		end)
  	end

    --退出账号按钮
    local btnQuit = seekNodeByName(self.bgImg, "btnLogOut")
    if btnQuit then
        local txtQuit = seekNodeByName(btnQuit, "txtQuit")
        txtQuit:enableOutline(cc.c3b(173, 35, 0), 2)
  		  btnQuit:addClickEventListener(function()
          print("click btnQuit btn")
          --关闭音乐
          ccexp.AudioEngine:stopAll()
          hallProxy:getData().bgMusicID=nil
          --退出帐号命令
          platformFacade:sendNotification(PlatformConstants.REQUEST_LOGOUT)
  		  end)
    end

    --用户协议的超链接
    local imgUserAgree = seekNodeByName(self.bgImg, "Img_userAgree")
    if imgUserAgree then
        imgUserAgree:addClickEventListener(function()
          print("click imgUserAgree")
          platformFacade:sendNotification(PlatformConstants.START_USERAGREEUILAYER, 1)
        end)
    end

    --用户隐私的超链接
    local imgUserPrivacy = seekNodeByName(self.bgImg, "Img_userPrivacy")
    if imgUserPrivacy then
        imgUserPrivacy:addClickEventListener(function()
          print("click imgUserAgree")
          platformFacade:sendNotification(PlatformConstants.START_USERAGREEUILAYER, 2)
        end)
    end

    --版本号
    local txtVersion = seekNodeByName(self.bgImg, "txtVersion")
    local nowVersion = cc.exports.getVersionName()
    print("now application version:",nowVersion)
    if txtVersion then
        txtVersion:setString(txtVersion:getString()..nowVersion)
    end
end

function SysSetMediator:handleNotification(notification)
    print("SysSetMediator:handleNotification")
    local name = notification:getName()
    local body = notification:getBody()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    --local shopProxy = platformFacade:retrieveProxy("ShopProxy")
    if name == PlatformConstants.START_LOGOUT then
        platformFacade:removeMediator("SysSetMediator")
    end
end

function SysSetMediator:onRemove()
    print("SysSetMediator:onRemove")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
  	local PlatformConstants = cc.exports.PlatformConstants
  	
  	platformFacade:removeCommand(PlatformConstants.START_GAMEHELPLAYER)
    platformFacade:removeCommand(PlatformConstants.START_USERAGREEUILAYER)

    self:getViewComponent():removeFromParent()
  	self:setViewComponent(nil)
end

return SysSetMediator
--endregion

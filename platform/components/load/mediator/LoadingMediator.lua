--region *.lua
--Date
--LoadingMediator  网络请求时转圈的loading
local Mediator = cc.load("puremvc").Mediator
local LoadingMediator = class("LoadingMediator", Mediator)
local bAnimStop = false
local WaitTime = 1  --等待1s出现loading动画

function LoadingMediator:ctor(scene)
    print("LoadingMediator onRegister()")
	LoadingMediator.super.ctor(self, "LoadingMediator")
	self.scene = scene
end

function LoadingMediator:listNotificationInterests()
    print("LoadingMediator listNotificationInterests()")
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT, 
		PlatformConstants.SHOW_LOADINGANIM,  --显示加载动画
        PlatformConstants.HIDE_LOADINGANIM,  --隐藏加载动画
	}
end

function LoadingMediator:onRegister()
    print("LoadingMediator onRegister()")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local ui = cc.LayerColor:create(cc.c4b(39,40,34,210)) --cc.Layer:create()
    self:setViewComponent(ui)
    self:getViewComponent():setZOrder(-1005)
    self:getViewComponent():setVisible(false)
	self.scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景

    --platformFacade:registerCommand(PlatformConstants.REQUEST_CONFIG, cc.exports.RequestConfigCommand)
    local function onTouchBegan(touch, event)
        printf('on Loading TouchBegan')
        return true
    end

    local function onTouchEnded(touch, event)
        printf('on Loading TouchEnded')
    end
	
    local listener = cc.EventListenerTouchOneByOne:create()
    listener:setSwallowTouches(true)
    listener:registerScriptHandler(onTouchBegan,cc.Handler.EVENT_TOUCH_BEGAN )
    local eventDispatcher = ui:getEventDispatcher()
    eventDispatcher:addEventListenerWithSceneGraphPriority(listener, ui)

    self:initAnimal()
end

function LoadingMediator:showLoading(message, outtimetip, call_back, time)
    print("LoadingMediator showLoading()")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    self.time = 8  --延续时间
    if time ~= nil then
       self.time = time   
    end
    print("等待时间:" .. tostring(self.time))
   
    self.message = "正在网络请求..."   --文本提示
    if message~=nil then
      self.message = message
    end

    self.outTimeTip = "请求超时"  --超时提醒文本
    if outtimetip~=nil then
       self.outTimeTip = outtimetip
    end

    self.outTimeCallback = nil   --超时回调函数
    if call_back~=nil then
       self.outTimeCallback = call_back
    end
   
    print("show Loading setvisible true")
    self:getViewComponent():setVisible(false)
    self:getViewComponent():setZOrder(1005)  --显示的时候设置为顶层，不让穿透
    bAnimStop = false
    --等待1秒才显示loading动画
    performWithDelay(self:getViewComponent(), function() 
        if bAnimStop == true then
           print("bAnimStop is true")
           return
        end
        self:getViewComponent():setVisible(true)  --等待1秒后，出现loading框
        self:showAnimal(self.message)

        --等待15秒后出现提示,并隐藏掉动画
       performWithDelay(self:getViewComponent(), function ()
		-- body
        -- print("self.bStop = " .. tostring(bAnimStop))
        if bAnimStop == true then
           return
        end
        print('请求超时处理-------------- ')
        
         local tips = '连接超时，请稍后再试' 
         if(self.outTimeTip ~= nil)then
           tips = self.outTimeTip
         end
         --显示连接超时提示
        platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, tips)
        self:outTimeClose()  --删除结点
	end, self.time)

    end, WaitTime)

    
end

--超时处理
function LoadingMediator:outTimeClose()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local ui = self:getViewComponent()

    local callback = self.outTimeCallback
    print("self.outTimeCallback:==========")
    
    if  bAnimStop == false and self.outTimeCallback ~= nil then
         print("self.bStop = " .. tostring(bAnimStop))
         self.outTimeCallback()
    else
       print("self.outTimeCallback is nil")
    end
     
     self:hideLoading()
end

--隐藏动画
function LoadingMediator:hideLoading()
    print("LoadingMediator:hideLoading")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local ui = self:getViewComponent()

    if self.animAction then
       self.animAction:pause()
    end
    
    bAnimStop = true
    ui:setZOrder(-5)
    ui:setVisible(false)
end

--初始化动画
function LoadingMediator:initAnimal()
    print("LoadingMediator initAnimal()")
    local ui = self:getViewComponent()
    local csbFile = "Armature/load/load.csb"
	self.loadinganimlNode = cc.CSLoader:createNode(csbFile)
	self.animAction = cc.CSLoader:createTimeline(csbFile)
    --加载动画
    self.animAction:setTimeSpeed(24.0/30)
	self.loadinganimlNode:runAction(self.animAction)
	self.animAction:pause()
    
	self.loadinganimlNode:setPosition(display.width/2-30,display.height/2)
	ui:addChild(self.loadinganimlNode)

    self.loadingLabel = cc.LabelTTF:create('','Arial',28)
	ui:addChild(self.loadingLabel)
    self.loadingLabel:setTag(101)
	self.loadingLabel:setColor(ccc3(153,148,186))
	self.loadingLabel:setAnchorPoint(0,0.5)
end

--显示动画
function LoadingMediator:showAnimal(message)
    print("LoadingMediator:showAnimal")
    local ui = self:getViewComponent()

    self.loadinganimlNode:setPosition(display.width/2-30,display.height/2)
    --加载动画
    if self.animAction then
       print("self.animAction")
       self.animAction:gotoFrameAndPlay(0, true)
    else
       print("self.animAction is nil")
    end
	
    if message ~= nil then
		self.loadingLabel:setString(message)
		self.loadinganimlNode:setPositionX(self.loadinganimlNode:getPositionX() - self.loadingLabel:getContentSize().width/2)
		self.loadingLabel:setPosition(self.loadinganimlNode:getPositionX() + self.loadinganimlNode:getContentSize().width/2
           + self.loadingLabel:getContentSize().width/2, self.loadinganimlNode:getPositionY())
	end
end

function LoadingMediator:handleNotification(notification)
    print("LoadingMediator:handleNotification()")
    local name = notification:getName()
    local body = notification:getBody()
    print("handleNotification:",name,body)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --local shopProxy = platformFacade:retrieveProxy("ShopProxy")
    if name == PlatformConstants.START_LOGOUT then
        --platformFacade:removeMediator("LoadingMediator")
        print("LoadingAnim Logout")
    elseif name == PlatformConstants.SHOW_LOADINGANIM then  --显示出Loading动画
        print("show LoadingAnim")
        local message = body.msg
        local outtimetip = body.outtip
        local call_back = body.callback
        local time = body.time
        self:showLoading(message, outtimetip, call_back, time)
    elseif name == PlatformConstants.HIDE_LOADINGANIM then  --隐藏动画
        print("hide LoadingAnim")
        self:hideLoading()
    end
end

function LoadingMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	--platformFacade:removeCommand(PlatformConstants.START_UPDATE)
    self.animAction:release()

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)

end

return LoadingMediator
--endregion

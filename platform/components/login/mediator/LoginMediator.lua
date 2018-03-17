
local LoginButtonMediator = import(".LoginButtonMediator")

local Mediator = cc.load("puremvc").Mediator
local LoginMediator = class("LoginMediator", Mediator)

function LoginMediator:ctor(scene)
	LoginMediator.super.ctor(self, "LoginMediator")
  self.scene = scene
end

function LoginMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_HALL, 
    PlatformConstants.SET_USERAGREE,
	}
end
--不同意退出
function LoginMediator:notAgreeExit()
   local sAgree = cc.UserDefault:getInstance():getStringForKey("useragree", "true")
   if sAgree == "false" then --如果用户不同意，直接退出游戏
       local PlatformConstants = cc.exports.PlatformConstants
       local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
       local strMsg = "您没有点击同意用户协议，是否退出游戏?"
       local function okCall()  --确定按钮回调
              cc.Director:getInstance():endToLua()
       end 
       local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
       platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
       --cc.Director:getInstance():endToLua()
       return false
   end
   return true
end
function LoginMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:registerCommand(PlatformConstants.START_REGISTER, nil)
	platformFacade:registerCommand(PlatformConstants.START_USERAGREE, cc.exports.StartAgreementCommand)
	platformFacade:registerCommand(PlatformConstants.START_HALL, cc.exports.StartHallCommand)
  local loginProxy = platformFacade:retrieveProxy("LoginProxy")

  local csbPath = "hall_res/login/LoginLayer.csb"
	local ui = cc.CSLoader:createNode(csbPath)
  ccdb.CCFactory:getInstance():loadDragonBonesData("platform_res/login/kais/shouye_ske.json")
  ccdb.CCFactory:getInstance():loadTextureAtlasData("platform_res/login/kais/shouye_tex.json")
  local anim = ccdb.CCFactory:getInstance():buildArmatureDisplay("Armature", "shouye")
  anim:getArmature():getAnimation():play("newAnimation")
  seekNodeByName(ui, "FileNode_1"):addChild(anim)
	--local action = cc.CSLoader:createTimeline("hall_res/login/AnimationNode.csb")
	--action:play("animation0", true)
	--seekNodeByName(ui, "FileNode_1"):runAction(action)
	--ui:setPosition(display.cx, display.cy)
	self:setViewComponent(ui)
	self.scene:addChild(self:getViewComponent())

	--for test
	local keyboardEventListener = cc.EventListenerKeyboard:create()
	keyboardEventListener:registerScriptHandler(function(keyCode, event)
		print("keyCode", keyCode)
		local load = platformFacade:retrieveProxy("LoadProxy")
		if keyCode == cc.KeyCode.KEY_1 then
            local bAgree = self:notAgreeExit()
            if bAgree then
			 load:getData().deviceCode = "000098"
			 platformFacade:sendNotification(PlatformConstants.REQUEST_LOGIN)
            end
		elseif keyCode == cc.KeyCode.KEY_2 then
            local bAgree = self:notAgreeExit()
			 if bAgree then
			   load:getData().deviceCode = "000051"
			   platformFacade:sendNotification(PlatformConstants.REQUEST_LOGIN)
            end
		elseif keyCode == cc.KeyCode.KEY_3 then
            local bAgree = self:notAgreeExit()
			 if bAgree then
			   load:getData().deviceCode = "000052"
			   platformFacade:sendNotification(PlatformConstants.REQUEST_LOGIN)
            end
		elseif keyCode == cc.KeyCode.KEY_4 then
            local bAgree = self:notAgreeExit()
			 if bAgree then
			   load:getData().deviceCode = "000053"
			   platformFacade:sendNotification(PlatformConstants.REQUEST_LOGIN)
            end
		end
	end, cc.Handler.EVENT_KEYBOARD_PRESSED)
	local eventDispatcher = self.scene:getEventDispatcher()
	eventDispatcher:addEventListenerWithSceneGraphPriority(keyboardEventListener, self:getViewComponent())

    --如果有微信登录ID缓存则直接登录
    if loginProxy:getData().wxuid~=0 then
       platformFacade:registerCommand(PlatformConstants.REQUEST_LOGINWX, cc.exports.RequestWxLoginCommand)
       platformFacade:sendNotification(PlatformConstants.REQUEST_LOGINWX)
       return
    end 

    --checkBox
    local function selectedEvent(sender, eventType)
      if eventType == ccui.CheckBoxEventType.selected then
         print("setUserAgree:" .. "true")
		 cc.UserDefault:getInstance():setStringForKey("useragree", "true")
      elseif eventType == ccui.CheckBoxEventType.unselected then
         print("setUserAgree:" .. "false")
         cc.UserDefault:getInstance():setStringForKey("useragree", "false")
      end
    end

    self.chkAgree = seekNodeByName(ui, "chkAgree") --
    if self.chkAgree then
      local sCheck = cc.UserDefault:getInstance():getStringForKey("useragree", "true")
      if sCheck == "false" then
         self.chkAgree:setSelected(false)
      else 
         self.chkAgree:setSelected(true)
      end
      self.chkAgree:addEventListener(selectedEvent)
    else
       print("can not found chkAgree")
    end
    local txtUserProto = seekNodeByName(ui, "txtUserProto")
    if txtUserProto then
		--btn_back:setZoomScale(-0.1)
		txtUserProto:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.START_USERAGREE, self.scene)
		end)
	end
    
	platformFacade:registerMediator(LoginButtonMediator.new(self:getViewComponent()))

    --首次登录
    local sFirstLogin = cc.UserDefault:getInstance():getStringForKey("firstlogin", "1")
    if sFirstLogin=="1" then --如果是首次登录
      cc.UserDefault:getInstance():setStringForKey("firstlogin", "0")
      platformFacade:sendNotification(PlatformConstants.START_USERAGREE, self.scene)
    end
end

function LoginMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	--platformFacade:removeCommand(PlatformConstants.START_REGISTER)
	--platformFacade:removeCommand(PlatformConstants.START_USERAGREE)
	--platformFacade:removeCommand(PlatformConstants.START_HALL)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

function LoginMediator:handleNotification(notification)
	local name = notification:getName()
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.START_HALL then
		local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
		platformFacade:removeMediator("LoginMediator")
		platformFacade:removeMediator("LoginButtonMediator")
    elseif name == PlatformConstants.SET_USERAGREE then
    	if self.chkAgree then
    		self.chkAgree:setSelected(true)
    	end
	end
end

return LoginMediator
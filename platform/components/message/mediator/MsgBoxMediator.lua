--region *.lua
--Date
--弹出框

local Mediator = cc.load("puremvc").Mediator
local MsgBoxMediator = class("MsgBoxMediator", Mediator)

local NoticeBox          = 1      -----提示  只有 知道了 按钮 点玩关闭
local NormalBox        = 2     -----普通msgBox 确定 取消 

function MsgBoxMediator:ctor(mType, msgText, scene,okcall)

	MsgBoxMediator.super.ctor(self, "MsgBoxMediator")
	--self.scene = scene
    self.mType = mType
    self.msg = msgText
    self.okcall = okcall   --确定按钮的回调函数
    --self.code = 1

    self.scene = scene

end

function MsgBoxMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_MSGBOX,
        PlatformConstants.UPDATE_MSGBOX_EX,
        PlatformConstants.CLOSE_MSGBOX,
        PlatformConstants.START_LOGOUT,
	}
end

function MsgBoxMediator:onRegister()
	print(" MsgBoxMediator:onRegister")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    --platformFacade:registerCommand(PlatformConstants.START_LOGIN, cc.exports.StartLoginCommand)
    local ui = cc.CSLoader:createNode("hall_res/messageTip/tipLayer.csb")  --设置UI的csb
	self:setViewComponent(ui)
    --local scene = platformFacade:retrieveMediator("HallMediator").scene --获取要加载上的场景
    --local scene = cc.Director:getInstance():getRunningScene()
	--self.scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景
    self:getViewComponent():setZOrder(1000)

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    self:getViewComponent():setVisible(false)
    self.scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景
    

    --获取关闭按钮
    local btnClose = seekNodeByName(self.bgImg, "btn_close")
	if btnClose then
		btnClose:addClickEventListener(function()
            btnClose:setZoomScale(-0.1)
			--platformFacade:removeMediator("MsgBoxMediator")
            self:getViewComponent():setVisible(false)
		end)
	end

    --获取取消按钮
    self.btnCancel = seekNodeByName(self.bgImg, "btn_cancle")
	if self.btnCancel then
		self.btnCancel:addClickEventListener(function()
            self.btnCancel:setZoomScale(-0.1)
            --[[
            if type(cancel_callback) == "function" then
                    cancel_callback()
            end
            --]]
			--print("MsgBox Code:" .. tostring(self.code))
            print("MsgBox Cancel")
            platformFacade:sendNotification(PlatformConstants.MSGBOX_CANCEL)
            self:getViewComponent():setVisible(false)
		end)
	end

    --获取确定按钮
    self.btnOk = seekNodeByName(self.bgImg, "btn_ok")

        if self.btnOk then
		  self.btnOk:addClickEventListener(function()
            self.btnOk:setZoomScale(-0.1)
           
			--platformFacade:removeMediator("MsgBoxMediator")
            print("MsgBox ok")
            platformFacade:sendNotification(PlatformConstants.MSGBOX_OK)
            self:getViewComponent():setVisible(false)
		  end)
        end

	

    --获取中间确定按钮
    self.btnKnow = seekNodeByName(self.bgImg, "btn_know")
	if self.btnKnow then
		self.btnKnow:addClickEventListener(function()
            self.btnKnow:setZoomScale(-0.1)
            --[[
            if type(cancel_callback) == "function" then
                    cancel_callback()
            end
            --]]

			--platformFacade:removeMediator("MsgBoxMediator")
            --print("MsgBox Code:" .. tostring(self.code))
            platformFacade:sendNotification(PlatformConstants.MSGBOX_KNOW)
            self:getViewComponent():setVisible(false)
		end)
	end

    self.btnLeft = seekNodeByName(self.bgImg,"txtOK")
    self.btnRight = seekNodeByName(self.bgImg,"txtCancel")

    
    self.tipmessage = seekNodeByName(self.bgImg,"text_message")
    print("self.msg:" ,self.msg)
    self.tipmessage:setString(self.msg)

    if 1 == self.mType then
        print("self.mType = 1")
        self.btnCancel:setVisible(false)
        self.btnOk:setVisible(false)
        self.btnKnow:setVisible(true)
    else
        self.btnCancel:setVisible(true)
        self.btnOk:setVisible(true)
        self.btnKnow:setVisible(false)
    end
    
end

function MsgBoxMediator:handleNotification(notification)
    local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local msgProxy = platformFacade:retrieveProxy("MsgBoxProxy")  --msgbox数据模型
    -- local userinfo = platformFacade:retrieveProxy("UserInfoProxy")  --
    --print("name-------------",name)



    if name == PlatformConstants.START_LOGOUT then
		--platformFacade:removeMediator("MsgBoxMediator")
        print("LogOut")
        
    elseif name == PlatformConstants.CLOSE_MSGBOX then
        self:getViewComponent():setVisible(false)
    elseif name == PlatformConstants.UPDATE_MSGBOX then
        print("start show msgbox")
        self:getViewComponent():stopAllActions()
        self:getViewComponent():setVisible(true)
        self.tipmessage:setString(body)
        --[[
        self:getViewComponent():runAction(cc.Sequence:create(
            cc.DelayTime:create(0.5), 
            cc.CallFunc:create(function()
                self:getViewComponent():setVisible(false)
            end)))
        --]]
    elseif name == PlatformConstants.UPDATE_MSGBOX_EX then
        print("UPDATE_MSGBOX_EX")
        self:getViewComponent():stopAllActions()
        self:getViewComponent():setVisible(true)
       -- {message, confirmCallback, confirmText, cancelCallback, cancelText}
        local tMsg = body --local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = func}
        dump(tMsg, "MsgBox Ex")

        --根据传入的参数修改左右按钮上面的文字
        for n,m in pairs(tMsg) do 
            if n == "leftText" then
                self.btnLeft:setString(m)
            elseif n == "rightText" then
                self.btnRight:setString(m)
            end
        end


        if tMsg.mType == 1 then
           self.mType = 1
           print("self.mType = 1")
           self.btnCancel:setVisible(false)
           self.btnOk:setVisible(false)
           self.btnKnow:setVisible(true)
        elseif tMsg.mType == 2 then
           self.mType = 1
           self.btnCancel:setVisible(true)
           self.btnOk:setVisible(true)
           self.btnKnow:setVisible(false)
        end
        
        msgProxy:getData().code = tMsg.code
        self.tipmessage:setString(tMsg.msg)

        --监听确定按钮
        if self.btnOk then
		    self.btnOk:addClickEventListener(function()
                self.btnOk:setZoomScale(-0.1)
                print("MsgBox ok")
                if tMsg.okCallback~=nil then --添加自定义的回调函数
                   tMsg.okCallback()
                end
                platformFacade:sendNotification(PlatformConstants.MSGBOX_OK)
                self:getViewComponent():setVisible(false)
                self.btnLeft:setString("确定")
		    end)
        end
        --监听取消按钮
        if self.btnCancel then
            self.btnCancel:addClickEventListener(function()
                self:getViewComponent():setVisible(false)
                self.btnRight:setString("取消")
            end)
        end
	end

end

function MsgBoxMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	--platformFacade:removeCommand(PlatformConstants.REQUEST_BINDMOBILE)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return MsgBoxMediator
--endregion

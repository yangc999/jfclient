--region *.lua
--Date
--弹出框

local Mediator = cc.load("puremvc").Mediator
local MsgBoxMediator = class("MsgBoxMediator", Mediator)

local NoticeBox          = 1      -----提示  只有 知道了 按钮 点玩关闭
local NormalBox        = 2     -----普通msgBox 确定 取消 

function MsgBoxMediator:ctor(mType, msgText, scene,okcall)

	MsgBoxMediator.super.ctor(self, "MsgBoxMediator")
    self.mType = mType
    self.msg = msgText
    self.okcall = okcall   --确定按钮的回调函数
    self.scene = scene

end

function MsgBoxMediator:listNotificationInterests()
	local GameConstants = cc.exports.GameConstants
	return {
		GameConstants.UPDATE_MSGBOX,
        GameConstants.UPDATE_MSGBOX_EX,
        GameConstants.EXIT_GAME,
	}
end

function MsgBoxMediator:onRegister()
	print("GameMsgBoxMediator:onRegister")
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants

    local ui = cc.CSLoader:createNode("hall_res/messageTip/tipGameLayer.csb")  --设置UI的csb
	self:setViewComponent(ui)
    self:getViewComponent():setZOrder(1000)

    self.bgImg = seekNodeByName(ui, "Panel_1"):getChildByName("bg")--背景
    self:getViewComponent():setVisible(false)
    self.scene:addChild(self:getViewComponent()) --获取大厅的Mediator，加载这个公告场景
    
    self.titleImg = seekNodeByName(self.bgImg, "Image_title")

    --获取关闭按钮
    self.btnClose = seekNodeByName(self.bgImg, "btn_close")
    --获取取消按钮
    self.btnCancel = seekNodeByName(self.bgImg, "btn_refuse")
    --获取接受按钮
    self.btnOk = seekNodeByName(self.bgImg, "btn_accept")
    --获取中间确定按钮
    self.btnKnow = seekNodeByName(self.bgImg, "btn_confirm")
    self.tipmessage = seekNodeByName(self.bgImg,"text_message")
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
-- 设置标题类型
function MsgBoxMediator:setTitleType(mType)
    if(self.titleImg)then
        if mType==1 then
            self.titleImg:loadTexture("platform_res/messagebox/ui_res/tishi.png")
            self.titleImg:setContentSize(107,50)
        elseif mType==2 then
            self.titleImg:loadTexture("platform_res/messagebox/ui_res/js.png")
            self.titleImg:setContentSize(192,50)
        end
    end
end

function MsgBoxMediator:handleNotification(notification)

    local name = notification:getName()
	local body = notification:getBody()
    print("GameMsgBoxMediator:handleNotification()"..name)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local GameConstants = cc.exports.GameConstants
    local msgProxy = gameFacade:retrieveProxy("MsgBoxProxy")  --msgbox数据模型


    if name == GameConstants.EXIT_GAME then
        print("LogOut")

    elseif name == GameConstants.UPDATE_MSGBOX then
        print("start show msgbox")
       
    elseif name == GameConstants.UPDATE_MSGBOX_EX then
        print("UPDATE_MSGBOX_EX")
        self:getViewComponent():stopAllActions()
        self:getViewComponent():setVisible(true)
        local tMsg = body --local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = func}
        dump(tMsg, "MsgBox Ex")
        
        if tMsg.mType == 1 then
           self.mType = 1
           self:setTitleType(true)
           print("self.mType = 1")
           self.btnCancel:setVisible(false)
           self.btnOk:setVisible(false)
           self.btnKnow:setVisible(true)
        elseif tMsg.mType == 2 then
           self:setTitleType(false)
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
                gameFacade:sendNotification(GameConstants.MSGBOX_OK)
                self:getViewComponent():setVisible(false)
                -- self.btnLeft:setString("确定")
            end)
        end
        --监听取消按钮
        if self.btnCancel then
            self.btnCancel:addClickEventListener(function()
                print("MsgBox btnCancel")
                self:getViewComponent():setVisible(false)
                -- self.btnRight:setString("取消")
            end)
        end
        --知道按钮
        if self.btnKnow then
            self.btnKnow:addClickEventListener(function()
                print("MsgBox btnKnow")
                self:getViewComponent():setVisible(false)
            end)
        end
        --监听关闭按钮
        if self.btnClose then
            self.btnClose:addClickEventListener(function()
                print("MsgBox btnClose")
                self:getViewComponent():setVisible(false)
            end)
        end
	end

end

function MsgBoxMediator:onRemove()
	local gameFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)
end

return MsgBoxMediator

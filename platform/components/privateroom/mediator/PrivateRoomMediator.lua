
local PrivateTitleMediator = import(".PrivateTitleMediator")

local Mediator = cc.load("puremvc").Mediator
local PrivateRoomMediator = class("PrivateRoomMediator", Mediator)

function PrivateRoomMediator:ctor()
	PrivateRoomMediator.super.ctor(self, "PrivateRoomMediator")
end	

function PrivateRoomMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.START_LOGOUT,
        PlatformConstants.UPDATE_PRIVATEROOM_STATE, 
	}
end

function PrivateRoomMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    self.userStateProxy = platformFacade:retrieveProxy("UserStateProxy")
	local PlatformConstants = cc.exports.PlatformConstants
    local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
	platformFacade:registerCommand(PlatformConstants.SHOW_ROOMCREATE, cc.exports.ShowCreateRoomCommand)
	platformFacade:registerCommand(PlatformConstants.SHOW_ROOMJOIN, cc.exports.ShowJoinRoomCommand)
    --platformFacade:registerCommand(PlatformConstants.START_MATCHRECORDSLAYER, cc.exports.StartMatchRecordsCommand)

	local ui = cc.CSLoader:createNode("hall_res/openRoom/openRoomLayer.csb")
	self:setViewComponent(ui)
	local scene = platformFacade:retrieveMediator("HallMediator").scene
	scene:addChild(self:getViewComponent())

    --[[
    local animator = seekNodeByName(ui, "shangcheng_animal")
	local animation = cc.CSLoader:createTimeline("hall_res/hall/shangcheng2/shangcheng.csb")
	animation:gotoFrameAndPlay(0, true)
	animator:runAction(animation)
    --]]

	local btn_back = seekNodeByName(ui, "btn_back")
    print("privateroomjay btn_back:",btn_back)
	if btn_back then
		btn_back:setZoomScale(-0.1)
		btn_back:addClickEventListener(function()
			platformFacade:removeMediator("PrivateRoomMediator")
		end)
	end
    local imgFangKa=seekNodeByName(ui,"img_fangka_bg")
    self.txtCard = seekNodeByName(imgFangKa, "userfangka")
    print("privateroomjay self.txtCard:",self.txtCard)
    if userinfo:getData().roomCard then
        self.txtCard:setString(userinfo:getData().roomCard)
    end

    local imgDiamond=seekNodeByName(ui,"img_diamond_bg")
    self.txtDiamond = seekNodeByName(imgDiamond, "userdiamond")
    print("privateroomjay self.txtDiamond:",self.txtDiamond)
    if userinfo:getData().diamond then
        print("privateroomjay 玩家身上的钻石:" .. userinfo:getData().diamond)
        local diamondStr = cc.exports.formatLongNum(userinfo:getData().diamond)
        self.txtDiamond:setString(diamondStr)
    else
        self.txtDiamond:setString(0)
    end

	self.btn_create = seekNodeByName(ui, "btn_create")
    print("privateroomjay  start stateType:",self.userStateProxy:getData().stateType)
	if self.btn_create then
        if self.userStateProxy:getData().stateType == 0 then  
            self.btn_create:loadTextureNormal("platform_res/hall/openroom/003.png",0)
        else
            self.btn_create:loadTextureNormal("platform_res/hall/openroom/002.png",0)
        end
		self.btn_create:setZoomScale(-0.05)
		self.btn_create:addClickEventListener(function()
            -- 判断是否已经在房间，不在房间创建，在房间直接进入
            self.userStateProxy = platformFacade:retrieveProxy("UserStateProxy")
            if self.userStateProxy:getData().stateType==0 then
                platformFacade:sendNotification(PlatformConstants.SHOW_ROOMCREATE)
                print("privateroomjay 创建房间")
            elseif self.userStateProxy:getData().stateType==1 then
                local roomID = self.userStateProxy:getData().roomID
                print("privateroomjay  roomID:",roomID)
                local gameFacade = cc.load("puremvc").Facade.getInstance("game")
                local GameConstants = cc.exports.GameConstants
                local function sendMsgCallback()
                    print("JoinPrivateRoom timeout")
                    platformFacade:sendNotification(PlatformConstants.CLR_ROOMKEY)
                end
                cc.exports.showLoadingAnim("正在进入房间...","进入房间失败",sendMsgCallback,5)
                gameFacade:sendNotification(GameConstants.REQUEST_PRVCONNECT,{sRoomKey=roomID})
            end

		end)
	end

	local btn_join = seekNodeByName(ui, "btn_join")
	if btn_join then
		btn_join:setZoomScale(-0.05)
		btn_join:addClickEventListener(function()
			platformFacade:sendNotification(PlatformConstants.SHOW_ROOMJOIN)
		end)
	end

	local imgTitle = seekNodeByName(ui, "FileNode_top")

    self:buttonListener(ui) --监听工具栏按钮

	platformFacade:registerMediator(PrivateTitleMediator.new(imgTitle))
end

--工具栏监听
function PrivateRoomMediator:buttonListener(ui)
    print("PrivateRoomMediator:buttonListener")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

    local btn_bank = seekNodeByName(ui,"btn_baoxianxiang")
    if btn_bank then
        btn_bank:addClickEventListener(function()
            print("click btn_bank")
            platformFacade:sendNotification(PlatformConstants.START_BANKLAYER)  --银行开关
        end)
    end
    --
    local btn_Activity = seekNodeByName(ui,"btn_message")
    if btn_Activity then
        btn_Activity:addClickEventListener(function()
            print("click btn_Activity")
            platformFacade:sendNotification(PlatformConstants.START_ANNOUNCELIST)  --公告开关
        end)
    end
    --商城开关
    local btn_Shop = seekNodeByName(ui,"btn_mark")
    if btn_Shop then
        btn_Shop:addClickEventListener(function()
            print("click btn_Shop")
            platformFacade:sendNotification(PlatformConstants.START_SHOPLAYER)  --商城开关
        end)
    end

    --每日赚金
    local btn_task = seekNodeByName(ui,"btn_task")
    if btn_task ~= nil then
        btn_task:addClickEventListener(function()
            print("click btn_task")
            local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
--            platformFacade:sendNotification(PlatformConstants.START_BENEFITS)  --每日赚金
            platformFacade:sendNotification(PlatformConstants.SHOW_BENEFITS)
        end)
    else
        print("btn_Activity is nil")
    end

    local btn_huodong = seekNodeByName(ui, "btn_huodong")
    if btn_huodong then
        btn_huodong:addClickEventListener(function()
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
        end)
    end

    local btn_paihang = seekNodeByName(ui, "btn_paihang")
    if btn_paihang then
            btn_paihang:addClickEventListener(function()
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
        end)
    end

    local btn_zhanji = seekNodeByName(ui, "btn_zhanji")   --战绩按钮
    if btn_zhanji then
        btn_zhanji:addClickEventListener(function()
            platformFacade:sendNotification(PlatformConstants.START_MATCHRECORDSLAYER)
        end)
    end

    local Button_wanfa = seekNodeByName(ui, "Button_wanfa")
    if Button_wanfa then
        Button_wanfa:addClickEventListener(function()
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "功能待开放")
        end)
    end
end

function PrivateRoomMediator:onRemove()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	platformFacade:removeMediator("PrivateTitleMediator")

	platformFacade:removeCommand(PlatformConstants.SHOW_ROOMCREATE)
	platformFacade:removeCommand(PlatformConstants.SHOW_ROOMJOIN)
    --platformFacade:removeCommand(PlatformConstants.START_MATCHRECORDSLAYER)

	self:getViewComponent():removeFromParent()
	self:setViewComponent(nil)	
end

function PrivateRoomMediator:handleNotification(notification)
	local name = notification:getName()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    
    print("privateroomjay:handleNotification() name="..name)
	if name == PlatformConstants.START_LOGOUT then
		platformFacade:removeMediator("PrivateRoomMediator")
    elseif name == PlatformConstants.UPDATE_PRIVATEROOM_STATE then
        self.userStateProxy = platformFacade:retrieveProxy("UserStateProxy")
        print("privateroomjay:handleNotification() stateType="..self.userStateProxy:getData().stateType,self.userStateProxy:getData().roomID)
        if self.userStateProxy:getData().stateType == 0 then  
            self.btn_create:loadTextureNormal("platform_res/hall/openroom/003.png",0)
        else
            self.btn_create:loadTextureNormal("platform_res/hall/openroom/002.png",0)
        end
	end
end

return PrivateRoomMediator
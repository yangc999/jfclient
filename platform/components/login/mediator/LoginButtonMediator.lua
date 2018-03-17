
local Mediator = cc.load("puremvc").Mediator
local MsgBoxMediator = import("....components.message.mediator.MsgBoxMediator")
local LoginButtonMediator = class("LoginButtonMediator", Mediator)

function LoginButtonMediator:ctor(root)
	LoginButtonMediator.super.ctor(self, "LoginButtonMediator")
	self.root = root
end

function LoginButtonMediator:listNotificationInterests()
	return {}
end

function LoginButtonMediator:onRegister()	
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	
	platformFacade:registerCommand(PlatformConstants.REQUEST_LOGIN, cc.exports.RequestLoginCommand)
	platformFacade:registerCommand(PlatformConstants.REQUEST_LOGINWX, cc.exports.RequestWxLoginCommand)

	local node = cc.Node:create()
	self.root:addChild(node)
	self:setViewComponent(node)

	local proxy = platformFacade:retrieveProxy("LoadProxy")

	local posx = {400, 880}
	for i,method in ipairs(proxy:getData().loginMethod) do
		if method == "guest" then
			local BtnVisitor = ccui.Button:create("platform_res/login/btn_visitorlogin_normal.png")
			BtnVisitor:setScale(0.9)
			BtnVisitor:setAnchorPoint(cc.p(0.5, 0.5))
			BtnVisitor:setPosition(posx[i], 180) --270
			BtnVisitor:setEnabled(true)
			BtnVisitor:setZoomScale(-0.1)
			BtnVisitor:addClickEventListener(function()
                print("click BtnVistor")
                local sAgree = cc.UserDefault:getInstance():getStringForKey("useragree", "true")
                if sAgree == "false" then --不同意用户协议，弹出对话框，询问用户是否勾选还是直接退出游戏
                    local PlatformConstants = cc.exports.PlatformConstants
                    local strMsg = "您没有点击同意用户协议，是否退出游戏吗?"
                    local function okCall()  --确定按钮回调
                         cc.Director:getInstance():endToLua()
                    end 
                    local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
                    platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
                    --platformFacade:registerMediator(MsgBoxMediator.new(2, strMsg, nil, okCall))
                	--cc.Director:getInstance():endToLua()
                else
					local load = platformFacade:retrieveProxy("LoadProxy")
			    	platformFacade:sendNotification(PlatformConstants.REQUEST_LOGIN)
                end
			end)
			node:addChild(BtnVisitor)
		elseif method == "wx" then
			local BtnWeLogin = ccui.Button:create("platform_res/login/btn_welogin_normal.png")
			BtnWeLogin:setScale(0.9)
			BtnWeLogin:setAnchorPoint(cc.p(0.5, 0.5))
			BtnWeLogin:setPosition(posx[i], 180)
			BtnWeLogin:setEnabled(true)
			BtnWeLogin:setZoomScale(-0.1)
			BtnWeLogin:addClickEventListener(function()
                local sAgree = cc.UserDefault:getInstance():getStringForKey("useragree", "true")
                if sAgree == "false" then --不同意用户协议，弹出对话框，询问用户是否勾选还是直接退出游戏
                    local PlatformConstants = cc.exports.PlatformConstants
                    local strMsg = "您没有点击同意用户协议，是否退出游戏吗?"
                    local function okCall()  --确定按钮回调
                         cc.Director:getInstance():endToLua()
                    end 
                    local tMsg = {mType = 2, code = 1, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
                    platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
                else
					platformFacade:sendNotification(PlatformConstants.REQUEST_LOGINWX)
                end
			end)
			node:addChild(BtnWeLogin)
		end
	end
end

function LoginButtonMediator:onRemove()
end

function LoginButtonMediator:handleNotification(notification)
end

return LoginButtonMediator
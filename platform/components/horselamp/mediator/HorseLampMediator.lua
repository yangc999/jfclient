
local Mediator = cc.load("puremvc").Mediator
local HorseLampMediator = class("HorseLampMediator", Mediator)

local bgMoveDist = -802  --背景移动的距离

function HorseLampMediator:ctor(root)
	HorseLampMediator.super.ctor(self, "HorseLampMediator", root)
end

function HorseLampMediator:listNotificationInterests()
	local PlatformConstants = cc.exports.PlatformConstants
	return {
		PlatformConstants.UPDATE_HORSELAMP, 
        PlatformConstants.START_LOGOUT, 
	}
end

function HorseLampMediator:onRegister()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local userinfo = platformFacade:retrieveProxy("UserInfoProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")

	local ui = self:getViewComponent()
	self.bg = seekNodeByName(ui, "Image_bg")
	self.Text_Horse_Lamp = seekNodeByName(ui, "Text_Horse_Lamp")

    platformFacade:registerCommand(PlatformConstants.REQUEST_HORSELAMP, cc.exports.RequestHorseLampCommand)

    --2秒之后出现跑马灯
     performWithDelay(self:getViewComponent() , function() 
        print("performWithDelay display horselamp")
        platformFacade:sendNotification(PlatformConstants.REQUEST_HORSELAMP)
     end, 2)
end

function HorseLampMediator:update()
    print("horseLamp update")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    --platformFacade:sendNotification(PlatformConstants.REQUEST_HORSELAMP)
end

function HorseLampMediator:startCountDown()
    self.schedulerID = cc.Director:getInstance():getScheduler():scheduleScriptFunc( handler(self , self.update ) , 180.0 ,false)
end

function HorseLampMediator:stopCountDown()
    print("关闭跑马灯 ")
    if self.schedulerID then
        cc.Director:getInstance():getScheduler():unscheduleScriptEntry( self.schedulerID )
        self.schedulerID = nil
    end
end 

function HorseLampMediator:onRemove()
    self:stopCountDown()
end

function HorseLampMediator:getTextLength(text)
    local count = 0
    for uchar in string.gfind(text, "([%z\1-\127\194-\244][\128-\191]*)") do 
        if #uchar ~= 1 then
            count = count +2
        else
            count = count +1
        end
    end 
    return count * 30
end

function HorseLampMediator:handleNotification(notification)
	local name = notification:getName()
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
	if name == PlatformConstants.UPDATE_HORSELAMP then
        --print("horsemap text:" .. tostring(body) )
        local strHose = tostring(body)
        if #strHose<=0 then  --服务器发来的字符串为空，则不会弹出跑马灯
           return
        end
        self.bg:setVisible(true)  --设置初始位置
        self.bg:setPosition(800, 0)
        self.bg:stopAllActions()

        self.Text_Horse_Lamp:setVisible(true)
        self.Text_Horse_Lamp:stopAllActions()
        self.Text_Horse_Lamp:setPosition(cc.p(900, 18))
		self.Text_Horse_Lamp:setString(body)

        local length = self:getTextLength(body) + 854
        local count = length / 30 

        local moveToLeft = cc.MoveBy:create(1.8,cc.p(bgMoveDist, 0))  --跑马灯背景入场从右到左进来
        self.bg:setVisible(true)
        self.bg:runAction(moveToLeft)
        --文本框先移动
        local move = cc.MoveBy:create(0.25 * count,cc.p(-length,0))
        local callback = cc.CallFunc:create(function() 
            --self.bg:setVisible(false)
            --self.Text_Horse_Lamp:setVisible(false)
          --延迟0.2秒背景再移
          performWithDelay( self:getViewComponent() , function()
            local moveToLeftbg = cc.MoveBy:create(1.8,cc.p(bgMoveDist, 0))
            --self.tableView:reloadData()
            self.bg:runAction(moveToLeftbg)
          end , 0.2)
        end )
        local seq = cc.Sequence:create(move,callback)
        self.Text_Horse_Lamp:runAction(seq)
        self:startCountDown()

         
    elseif name == PlatformConstants.START_LOGOUT then
        platformFacade:removeMediator("HorseLampMediator")
	end	
end

return HorseLampMediator

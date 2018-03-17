--region *.lua
--Date
--每天第一次显示公告
local AnnounceProxy = import("..proxy.AnnounceProxy")
local AnnounceListMediator = import("..mediator.AnnounceListMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartFirstShowAnnounceCommand = class("StartFirstShowAnnounceCommand", SimpleCommand)

function StartFirstShowAnnounceCommand:execute(notification)
    print("StartFirstShowAnnounceCommand:execute")
    dump(notification,"StartFirstShowAnnounceCommand notification")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	
	--上一次的登录时间
    self.m_nextLoginDay = cc.UserDefault:getInstance():getIntegerForKey("next_login_time")    
    --当前系统时间(天)
    local day = tonumber(os.date("*t").day)
    cc.UserDefault:getInstance():setIntegerForKey("next_login_time",day)
    local dayNum = day - self.m_nextLoginDay
    print("dayNum = " .. dayNum)
     if dayNum >=1 then  --如果是当天第一次登录      
	   platformFacade:registerProxy(AnnounceProxy.new())  --启动公告界面
	   platformFacade:registerMediator(AnnounceListMediator.new())
     end
end

return StartFirstShowAnnounceCommand


--endregion

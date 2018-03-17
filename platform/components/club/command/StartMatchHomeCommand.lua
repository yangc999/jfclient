--region *.lua
--Date
--显示比赛首页的命令

local MatchProxy = import("..proxy.MatchProxy")
local MatchHomeMediator = import("..mediator.MatchHomeMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartMatchHomeCommand = class("StartMatchHomeCommand", SimpleCommand)

function StartMatchHomeCommand:execute(notification)
    print("StartMatchHomeCommand:execute")
    --dump(notification,"StartAnnounceListCommand notification")
	--local root = notification:getBody()
   -- print("root:"..root)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(MatchProxy.new())
	platformFacade:registerMediator(MatchHomeMediator.new())
end

return StartMatchHomeCommand
--endregion

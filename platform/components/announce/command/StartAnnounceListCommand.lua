--region *.lua
--Date 2017 11 6
--yang yisong
--显示公告列表

local AnnounceProxy = import("..proxy.AnnounceProxy")
local AnnounceListMediator = import("..mediator.AnnounceListMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartAnnounceListCommand = class("StartAnnounceListCommand", SimpleCommand)

function StartAnnounceListCommand:execute(notification)
    print("StartAnnounceListCommand:execute")
    --dump(notification,"StartAnnounceListCommand notification")
	--local root = notification:getBody()
   -- print("root:"..root)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(AnnounceProxy.new())
	platformFacade:registerMediator(AnnounceListMediator.new())
end

return StartAnnounceListCommand


--endregion

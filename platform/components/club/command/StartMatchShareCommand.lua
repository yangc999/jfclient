--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local MatchShareMediator = import("..mediator.MatchShareMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartMatchShareCommand = class("StartMatchShareCommand", SimpleCommand)

function StartMatchShareCommand:execute(notification)
    print("StartMatchShareCommand:execute")
    --dump(notification,"StartAnnounceListCommand notification")
	--local root = notification:getBody()
   -- print("root:"..root)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(MatchShareMediator.new())
end

return StartMatchShareCommand


--endregion

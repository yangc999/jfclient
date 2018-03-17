--region *.lua
--Date
--启动绑定好友验证码的UI
local BindInviteCodeProxy = import("..proxy.BindInviteCodeProxy")
local BindFriendInviteCodeMediator = import("..mediator.BindFriendInviteCodeMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartBindFriendInviteCodeCommand = class("StartBindFriendInviteCodeCommand", SimpleCommand)

function StartBindFriendInviteCodeCommand:execute(notification)
    print("StartBindFriendInviteCodeCommand:execute")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    --local root = notification:getBody()
    platformFacade:registerMediator(BindFriendInviteCodeMediator.new())
end

return StartBindFriendInviteCodeCommand


--endregion

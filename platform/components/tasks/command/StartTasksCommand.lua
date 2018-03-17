--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local TaskProxy = import("..proxy.TaskProxy")
local TaskShareMediator = import("..mediator.TaskShareMediator")
local BindCodeProxy = import("....components.banginvitecode.proxy.BindInviteCodeProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartTasksCommand = class("StartTaskCommand", SimpleCommand)

function StartTasksCommand:execute(notification)
    print("StartTaskCommand:execute")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local root = notification:getBody()
    platformFacade:registerMediator(TaskShareMediator.new(root))
    platformFacade:registerProxy(BindCodeProxy.new())
end

return StartTasksCommand


--endregion

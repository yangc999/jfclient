--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

local LoadingMediator = import("..mediator.LoadingMediator")
--local MsgBoxProxy = import("..proxy.MsgBoxProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local CreateLoadingAnimCommand = class("CreateLoadingAnimCommand", SimpleCommand)

function CreateLoadingAnimCommand:execute(notification)
    print("CreateLoadingAnimCommand:execute")
    --dump(notification,"CreateLoadingAnimCommand notification")

    local scene = notification:getBody()
    dump(body,"scene")

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    --platformFacade:registerProxy(MsgBoxProxy.new())
	platformFacade:registerMediator(LoadingMediator.new(scene))
end

return CreateLoadingAnimCommand

--endregion

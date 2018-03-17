--region *.lua  create msgbox
--Date 2018/1/2
--penghua

local MsgBoxMediator = import("..mediator.MsgBoxMediator")
local MsgBoxProxy = import("..proxy.MsgBoxProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartCreateMsgBoxCommand = class("StartCreateMsgBoxCommand", SimpleCommand)

function StartCreateMsgBoxCommand:execute(notification)
    print("StartCreateMsgBoxCommand:execute")
    dump(notification,"StartCreateMsgBoxCommand notification")

    local body = notification:getBody()
    dump(body)
    local msg = body.msg
    local scene = body.scene
    print("",msg,scene)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    platformFacade:registerProxy(MsgBoxProxy.new())
	platformFacade:registerMediator(MsgBoxMediator.new(1,msg,scene))
end

return StartCreateMsgBoxCommand

--endregion

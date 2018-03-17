--region *.lua  create msgbox
--Date 2018/1/2
--penghua

local MsgBoxMediator = import("..mediator.MsgBoxMediator")
local MsgBoxProxy = import("..proxy.MsgBoxProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartCreateGameMsgBoxCommand = class("StartCreateGameMsgBoxCommand", SimpleCommand)

function StartCreateGameMsgBoxCommand:execute(notification)
    print("StartCreateGameMsgBoxCommand:execute")
    dump(notification,"StartCreateGameMsgBoxCommand notification")

    local body = notification:getBody()
    dump(body)
    local msg = body.msg
    local scene = body.scene
    print("",msg,scene)
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
    gameFacade:registerProxy(MsgBoxProxy.new())
	gameFacade:registerMediator(MsgBoxMediator.new(1,msg,scene))
end

return StartCreateGameMsgBoxCommand

--endregion


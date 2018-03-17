--region *.lua
--Date
--带有用户附加数据的Msgbox
local MsgBoxMediator = import("..mediator.MsgBoxMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartGameMsgBoxCommandEx = class("StartGameMsgBoxCommandEx", SimpleCommand)

function StartGameMsgBoxCommandEx:execute(notification)
    print("StartGameMsgBoxCommandEx:execute")
    dump(notification,"StartGameMsgBoxCommandEx notification")
    local body = notification:getBody()
    local msg = body.msg
    if msg == nil then
      msg = "no message"   --消息提示
    end
    local code = body.code   --附加码，为了确定用户弹出的不同弹出框
    local mType = body.mType  --1为只有一个确定按钮， 2为确定取消按钮
    if mType == nil then
       mType = 1
    end
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	gameFacade:registerMediator(MsgBoxMediator.new(mType, msg, code))
end

return StartGameMsgBoxCommandEx


--endregion

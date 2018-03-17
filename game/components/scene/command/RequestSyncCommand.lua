
local TcpMediator = import("..mediator.TcpMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestSyncCommand = class("RequestSyncCommand", SimpleCommand)

function RequestSyncCommand:execute(notification)

end

return RequestSyncCommand
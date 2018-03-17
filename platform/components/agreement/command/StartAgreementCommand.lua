--region *.lua
--Date
--启动用户协议的界面

local AgreementMediator = import("..mediator.AgreementMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartAgreementCommand = class("StartAgreementCommand", SimpleCommand)

function StartAgreementCommand:execute(notification)
    print("StartAgreementCommand:execute")
    local scene = notification:getBody()
    dump(notification,"StartAgreementCommand notification")
	--local root = notification:getBody()
   -- print("root:"..root)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(AnnounceProxy.new())
	platformFacade:registerMediator(AgreementMediator.new(scene))
end

return StartAgreementCommand

--endregion

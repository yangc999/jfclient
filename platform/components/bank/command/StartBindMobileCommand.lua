--region *.lua
--Date
--开始启动绑定手机号界面
local BandMobileProxy = import("..proxy.BandMobileProxy")
local BindMobileMediator = import("..mediator.BindMobileMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartBindMobileCommand = class("StartBindMobileCommand", SimpleCommand)

function StartBindMobileCommand:execute(notification)
    print("StartBindMobileCommand:execute")
    local root = notification:getBody()  --获取根结点
    dump(notification,"StartBindMobileCommand notification")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    platformFacade:registerProxy(BandMobileProxy.new())   --注册BankProxy
	platformFacade:registerMediator(BindMobileMediator.new(root))   --注册BindMobileMediator
end

return StartBindMobileCommand


--endregion

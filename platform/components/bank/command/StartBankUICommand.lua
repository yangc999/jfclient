--region *.lua  启动初始化银行页面
--Date 2017/11/10
--yangyisong

local BankProxy = import("..proxy.BankProxy")
local BankMediator = import("..mediator.BankMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartBankUICommand = class("StartBankUICommand", SimpleCommand)

function StartBankUICommand:execute(notification)
    print("StartBankUICommand:execute")
    dump(notification,"StartBankUICommand notification")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(BankProxy.new())   --注册BankProxy
	platformFacade:registerMediator(BankMediator.new())   --注册BankMediator
end

return StartBankUICommand

--endregion

--region *.lua
--Date 2017/11/14
--yang

local BankProxy = import("..proxy.BankProxy")
local SetBankPassMediator = import("..mediator.SetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartSetBankPassUICommand = class("StartSetBankPassUICommand", SimpleCommand)

function StartSetBankPassUICommand:execute(notification)
    print("StartSetBankPassUICommand:execute")
    local root = notification:getBody()  --获取根结点
    dump(notification,"StartSetBankPassUICommand notification")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(BankProxy.new())   --注册BankProxy
	platformFacade:registerMediator(SetBankPassMediator.new(root))   --注册SetBankPassMediator
end

return StartSetBankPassUICommand



--endregion

--region *.lua
--Date
--此文件由[BabeLua]启动修改密码对话框 

local BankProxy = import("..proxy.BankProxy")
local ModifyBankPassMediator = import("..mediator.ModifyBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartModifyBankPassUICommand = class("StartModifyBankPassUICommand", SimpleCommand)

function StartModifyBankPassUICommand:execute(notification)
    print("StartSetBankPassUICommand:execute")
    local root = notification:getBody()  --获取根结点
    dump(notification,"ModifyBankPassMediator notification")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(BankProxy.new())   --注册BankProxy
	platformFacade:registerMediator(ModifyBankPassMediator.new(root))   --注册SetBankPassMediator
end

return StartModifyBankPassUICommand



--endregion

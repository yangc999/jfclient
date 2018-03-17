--region *.lua
--Date
--显示找回银行密码的UI
local BankProxy = import("..proxy.BankProxy")
local ForgetBankPassMediator = import("..mediator.ForgetBankPassMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartForgetBankPassUICommand = class("StartForgetBankPassUICommand", SimpleCommand)

function StartForgetBankPassUICommand:execute(notification)
    print("StartForgetBankPassUICommand:execute")
    local root = notification:getBody()  --获取根结点
    dump(notification,"StartForgetBankPassUICommand notification")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(ForgetBankPassMediator.new(root))   --注册BindMobileMediator
end

return StartForgetBankPassUICommand


--endregion

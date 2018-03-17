--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BankProxy = import("..proxy.BankProxy")
local InputPasswordMediator = import("..mediator.InputPasswordMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartInputPassUICommand = class("StartInputPassUICommand", SimpleCommand)

function StartInputPassUICommand:execute(notification)
    print("StartInputPassUICommand:execute")
    local root = notification:getBody()  --获取根结点
    dump(notification,"StartSetBankPassUICommand notification")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(BankProxy.new())   --注册BankProxy
	platformFacade:registerMediator(InputPasswordMediator.new(root))   --注册SetBankPassMediator
end

return StartInputPassUICommand


--endregion

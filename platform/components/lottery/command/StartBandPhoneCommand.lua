--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local BandPhoneMediator = import("..mediator.BandPhoneMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartBandPhoneCommand = class("StartBandPhoneCommand", SimpleCommand)

function StartBandPhoneCommand:execute(notification)
    print("StartBandPhoneCommand:execute")
    local root = notification:getBody()  --获取根结点
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerMediator(BandPhoneMediator.new(root))
end

return StartLotteryCommand


--endregion

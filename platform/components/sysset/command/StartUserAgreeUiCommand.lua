--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local UserPrivacyMediator = import("....components.help.mediator.UserPrivacyMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartUserAgreeUiCommand = class("StartUserAgreeUiCommand", SimpleCommand)

function StartUserAgreeUiCommand:execute(notification)
    --dump(notification,"StartShopLayerCommand notification")
    local typeId = notification:getBody()
    print("StartUserAgreeUiCommand:execute() typeId=",typeId)

	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(ShopProxy.new())
	platformFacade:registerMediator(UserPrivacyMediator.new(typeId))
end

return StartUserAgreeUiCommand


--endregion

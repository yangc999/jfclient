--region *.lua
--Date
--启动商城UI
local ShopProxy = import("..proxy.ShopProxy")
local ShopMediator = import("..mediator.ShopMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartShopLayerCommand = class("StartShopLayerCommand", SimpleCommand)

function StartShopLayerCommand:execute(notification)
    print("StartShopLayerCommand:execute")
    dump(notification, "notification")
    local typeId = 2  --默认打开钻石购买栏
    local body = notification:getBody()
    if body ~= nil then
       typeId = body
    end
    --dump(notification,"StartShopLayerCommand notification")
	
    print("typeId:"..typeId)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	--platformFacade:registerProxy(ShopProxy.new())
	platformFacade:registerMediator(ShopMediator.new(typeId))
end

return StartShopLayerCommand


--endregion

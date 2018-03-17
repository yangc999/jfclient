--region *.lua
--Date
--此文件由[BabeLua]插件自动生成
local ShopProxy = import("..proxy.ShopProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartShopProxyCommand = class("StartShopProxyCommand", SimpleCommand)

function StartShopProxyCommand:execute(notification)
    print("StartShopProxyCommand:execute")
	local root = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	platformFacade:registerProxy(ShopProxy.new())
end

return StartShopProxyCommand


--endregion

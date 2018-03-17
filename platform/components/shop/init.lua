--region *.lua
--Date
--此文件由[BabeLua]插件自动生成

cc.exports.StartShopLayerCommand = import(".command.StartShopLayerCommand")     --显示商品UI
cc.exports.RequestShopListCommand = import(".command.RequestShopListCommand")   --请求商品列表

cc.exports.RequestDiamondOrderCommand = import(".command.RequestDiamondOrderCommand")  --请求钻石购买  
cc.exports.StartPayChoiceCommand = import(".command.StartPayChoiceCommand")  --请求打开支付方式UI

cc.exports.LoopCheckCommand = import(".command.LoopCheckCommand")
cc.exports.CheckOrderCommand = import(".command.CheckOrderCommand")

cc.exports.RequestAliOrderCommand = import(".command.RequestAliOrderCommand")
cc.exports.RequestAliPaymentCommand = import(".command.RequestAliPaymentCommand")

cc.exports.RequestWxOrderCommand = import(".command.RequestWxOrderCommand")
cc.exports.RequestWxPaymentCommand = import(".command.RequestWxPaymentCommand")

cc.exports.StartShopProxyCommand = import(".command.StartShopProxyCommand")   --启动商城Proxy

local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
local PlatformConstants = cc.exports.PlatformConstants

platformFacade:registerCommand("ali_order", cc.exports.RequestAliOrderCommand)
platformFacade:registerCommand("ali_pay", cc.exports.RequestAliPaymentCommand)
platformFacade:registerCommand("wx_order", cc.exports.RequestWxOrderCommand)
platformFacade:registerCommand("wx_pay", cc.exports.RequestWxPaymentCommand)
platformFacade:registerCommand("loop", cc.exports.LoopCheckCommand)
platformFacade:registerCommand("check", cc.exports.CheckOrderCommand)

--endregion

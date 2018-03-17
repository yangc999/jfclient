
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestAliPaymentCommand = class("RequestAliPaymentCommand", SimpleCommand)

function RequestAliPaymentCommand:execute(notification)
	print("RequestAliPaymentCommand execute")
	local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local shop = platformFacade:retrieveProxy("ShopProxy")

	local ali = plugin.PluginManager:getInstance():loadPlugin("IAPAlipay")	
	if ali then
		ali:setDebugMode(true)
		ali:configDeveloperInfo({})
		ali:payForProduct({OrderInfo=body}, function(code, msg)
			if code == 0 then
				platformFacade:sendNotification("loop")
				--platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, msg)
				platformFacade:sendNotification(PlatformConstants.ALIPAY_OK)
			else
				--这是购买失败
				platformFacade:sendNotification(PlatformConstants.ALIPAY_FAILED)
			end
		end)
	end

end

return RequestAliPaymentCommand
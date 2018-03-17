
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestWxPaymentCommand = class("RequestWxPaymentCommand", SimpleCommand)

function RequestWxPaymentCommand:execute(notification)
	local body = notification:getBody()
	dump("RequestWxPaymentCommand body:",body)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local shop = platformFacade:retrieveProxy("ShopProxy")

	local weixin = plugin.PluginManager:getInstance():loadPlugin("IAPWeixin")
	if weixin then
		weixin:setDebugMode(true)
		weixin:configDeveloperInfo({AppId="wx41d5f85d4cde056b"})
		weixin:payForProduct({
			PartnerId = body.sPartnerid, 
			PrepayId = body.sPrepayid, 
			NonceStr = body.sNoncestr, 
			TimeStamp = body.sTimestamp, 
			Sign = body.sSign, 
		}, 
		function(code, msg)
			print("RequestWxPaymentCommand code:", code)
			print("RequestWxPaymentCommand msg:", msg)
			if code == 0 then
				platformFacade:sendNotification("loop")
				--platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, msg)
				platformFacade:sendNotification(PlatformConstants.WXPAY_OK)
			else
				--这是购买失败
				platformFacade:sendNotification(PlatformConstants.WXPAY_FAILED)
			end
		end)
	end
end

return RequestWxPaymentCommand
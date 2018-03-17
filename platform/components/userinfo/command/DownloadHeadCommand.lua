
local SimpleCommand = cc.load("puremvc").SimpleCommand
local DownloadHeadCommand = class("DownloadHeadCommand", SimpleCommand)

function DownloadHeadCommand:execute(notification)
    local body = notification:getBody()
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local login = platformFacade:retrieveProxy("LoginProxy")
	local userinfo = platformFacade:retrieveProxy("UserInfoProxy")

	local xhr = cc.XMLHttpRequest:new()	
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", body)
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			if not cc.FileUtils:getInstance():isDirectoryExist(string.format("%s/head/", cc.FileUtils:getInstance():getWritablePath())) then
				cc.FileUtils:getInstance():createDirectory(string.format("%s/head/", cc.FileUtils:getInstance():getWritablePath()))
			end
			local path = string.format("%s/head/%s.ico", cc.FileUtils:getInstance():getWritablePath(), os.time())
			cc.FileUtils:getInstance():writeStringToFile(xhr.response, path)
			cc.UserDefault:getInstance():setStringForKey(string.format("save_%d", login:getData().uid), path)
			userinfo:getData().headStr = path
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

return DownloadHeadCommand
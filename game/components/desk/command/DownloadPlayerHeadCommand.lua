
local SimpleCommand = cc.load("puremvc").SimpleCommand
local DownloadPlayerHeadCommand = class("DownloadPlayerHeadCommand", SimpleCommand)

function DownloadPlayerHeadCommand:execute(notification)
    local body = notification:getBody()
    local tp = notification:getType()
	local gameFacade = cc.load("puremvc").Facade.getInstance("game")

	local desk = gameFacade:retrieveProxy("DeskProxy")

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
			cc.UserDefault:getInstance():setStringForKey(string.format("save_%d", tp), path)
			local player = clone(desk:getData().player)
			for k,v in pairs(player) do
				if v.uid == tp then
					v.head = path
				end
			end
			desk:getData().player = player
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            gameFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")            

		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

return DownloadPlayerHeadCommand
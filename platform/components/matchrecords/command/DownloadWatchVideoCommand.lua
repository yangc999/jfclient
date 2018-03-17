
local SimpleCommand = cc.load("puremvc").SimpleCommand
local DownloadWatchVideoCommand = class("DownloadWatchVideoCommand", SimpleCommand)

function DownloadWatchVideoCommand:execute(notification)
    print("DownloadWatchVideoCommand")
    local body = notification:getBody()
    local downloadUrl = body.url
    local index = body.index

    local gameFacade = cc.load("puremvc").Facade.getInstance("game")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local GameConstants = cc.exports.GameConstants
	local matchRecord = platformFacade:retrieveProxy("MatchRecordsProxy"):getData()
    --dump(matchRecord,"matchRecord",10)
	print("录像地址："..downloadUrl)
	local xhr = cc.XMLHttpRequest:new()	
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("GET", downloadUrl)
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			if xhr.response then
				matchRecord.watchVideo=xhr.response
				print("录像数据:",#matchRecord.watchVideo)
                local body = {
                    sRoomKey = matchRecord.vRecordList[index].sRoomKey,
                    gameId =  matchRecord.vRecordList[index].iGameID
                }
				gameFacade:sendNotification(GameConstants.REQUEST_VIDEOCREATE,body)
			else
				platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "录像资源下载失败")
			end
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")            
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)
	xhr:send()
end

return DownloadWatchVideoCommand
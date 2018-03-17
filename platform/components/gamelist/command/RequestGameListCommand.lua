
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestGameListCommand = class("RequestGameListCommand", SimpleCommand)

--显示loading进度条
function RequestGameListCommand:showLoading()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --重新请求游戏列表
    local function retryReqGameList()
         local strMsg = "游戏列表请求失败,是否重试?"
         local function okCall()  --确定按钮回调
            self:execute()
         end
         local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
         platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
    end
    --显示转圈条
    cc.exports.showLoadingAnim("正在请求游戏列表...","游戏列表请求失败", retryReqGameList, 5)
end

--重新请求游戏列表
function RequestGameListCommand:retryReqGameList()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local strMsg = "游戏列表请求失败,是否重试?"
    local function okCall()  --确定按钮回调
       self:execute()
    end 
    local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
    platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
end

function RequestGameListCommand:execute(notification)
    print("RequestGameListCommand:execute")
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local gameList = platformFacade:retrieveProxy("GameListProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."config")

    --显示loading
    self:showLoading()

	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "systemconfig::ListGameRoomClientResp")
			dump(res3, "gamelist游戏列表  result:")

            --隐藏loading界面
            cc.exports.hideLoadingAnim()

			local private = {}
			local public = {}
			local quick = {}
			local champion = {}
			for _,v in ipairs(res3.gameRoomClientList) do
				if v.gameType == 1 then
					table.insert(private, v)
				elseif v.gameType == 2 then
					if not public[v.gameId] then
						public[v.gameId] = {}
					end
					table.insert(public[v.gameId], v)
				elseif v.gameType == 3 then
					if not quick[v.gameId] then
						quick[v.gameId] = {}
					end
					table.insert(quick[v.gameId], v)
				elseif v.gameType == 4 then
					table.insert(champion, v)
				end
			end
			for k,v in pairs(public) do
				table.sort(v, function(a, b)
					return a.minGold < b.minGold
				end)
			end
			for k,v in pairs(quick) do
				table.sort(v, function(a, b)
					return a.minGold < b.minGold
				end)
			end
			gameList:getData().private = private
			gameList:getData().public = public
			gameList:getData().quick = quick
			gameList:getData().champion = champion
			platformFacade:sendNotification(PlatformConstants.SHOW_GAMELIST)
		else
			print("网络异常，请求游戏列表失败")
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请求游戏列表失败，请重新检查网络后尝试重新连接（如有问题请联系客服）")            
            --self:retryReqGameList()
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		gameIdList = load:getData().availableGame, 
	}
	local req1 = tarslib.encode(pak1, "systemconfig::ListGameRoomClientReq")
	local pak2 = {
		actionName = 4, 
		reqBodyBytes = req1, 
	}
	local req2 = tarslib.encode(pak2, "commonstruct::CommonReqHead")
	local pak3 = {
		iVer = load:getData().version, 
		iSeq = load:getData().sequence, 
		stUid = {
			lUid = login:getData().uid, 
			sToken = login:getData().token, 
		}, 
		vecData = req2, 
	}
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
end

return RequestGameListCommand
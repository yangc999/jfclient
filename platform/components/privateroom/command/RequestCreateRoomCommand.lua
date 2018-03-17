
local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestCreateRoomCommand = class("RequestCreateRoomCommand", SimpleCommand)

function RequestCreateRoomCommand:execute(notification)
	local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants

	local load = platformFacade:retrieveProxy("LoadProxy")
	local login = platformFacade:retrieveProxy("LoginProxy")
	local roomCfg = platformFacade:retrieveProxy("RoomConfigProxy")
	local gameList = platformFacade:retrieveProxy("GameListProxy")

	local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	xhr:open("POST", load:getData().serviceUrl.."privateroom")
    --显示网络请求转圈的UI
    cc.exports.showLoadingAnim("正在请求创建房间...","创建房间请求失败")
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
			local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "privateroom::TRoomServiceMsg")
			local _, res3 = tarslib.decode(res2.vecData, "privateroom::RspCreateRoom")
			dump(res3, "res3",10)

			if res3.iresult == 0 then
				local gameFacade = cc.load("puremvc").Facade.getInstance("game")
				local GameConstants = cc.exports.GameConstants
                local default = {}
				for i,v in ipairs(res3.info.vConfigList.vConfigList) do
                    local optionType=#res3.info.vConfigList.vConfigList[i].optionList
                    if optionType>=2 then
                    optionType=2
                    end
						local column = {
							id = v.id, 
							code = v.optionCode, 
							tp = optionType, 
							choice = v.optionList, 
						}
						table.insert(default, column)
                end
				--roomCfg:getData().choice = default     -- 这句就是在创建文档后所有已选配置清空
                dump(default,"roomCFG",10)
				gameFacade:sendNotification(GameConstants.REQUEST_PRVCONNECT, res3.info)
			elseif res3.iresult == 403 then
				platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "房卡不足，创建房间失败")
				platformFacade:sendNotification(PlatformConstants.HIDE_LOADINGANIM)
			end
		else
			print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            cc.exports.hideLoadingAnim()
			platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）") 
		end
		xhr:unregisterScriptHandler()
	end
	xhr:registerScriptHandler(onReadyStateChange)

	local configs = {
		vConfigList = {}, 
	}
	for _,v in ipairs(roomCfg:getData().config) do
		local cfg = {
			id = v.id, 
			optionCode = v.optionCode, 
			optionName = v.optionName, 
			optionList = {}, 
		}
		table.insert(configs.vConfigList, cfg)
	end
	for i,v in ipairs(roomCfg:getData().choice) do
		local optionTemp
		for _,c in ipairs(roomCfg:getData().config) do
			if c.id == v.id then
				optionTemp = c.optionList
			end
		end
		local choice = {}
		if v.tp == 1 then
			for _,t in ipairs(optionTemp) do
				if t.optionId == v.choice then
					table.insert(choice, clone(t))
				end
			end
		elseif v.tp == 2 then
			for _,s in ipairs(v.choice) do
				for _,t in ipairs(optionTemp) do
					if t.optionId == s then
						table.insert(choice, clone(t))
					end
				end
			end
		end
		configs.vConfigList[i].optionList = choice
	end

	local tarslib = cc.load("jfutils").Tars
	
	local cheating = 0
	if roomCfg:getData().iAntiCheating then
		cheating = 1
	end
	print("==============>",cheating)
	local pak1 = {
		GameID = gameList:getData().private[roomCfg:getData().select].gameId, 
		MasterUserID = login:getData().uid, 
		configList = configs, 
		sRoomId = gameList:getData().private[roomCfg:getData().select].roomId,
		iAntiCheating = cheating
	}
	local req1 = tarslib.encode(pak1, "privateroom::ReqCreateRoom")
	local pak2 = {
		eAct = 0, 
		vecData = req1, 
	}
	local req2 = tarslib.encode(pak2, "privateroom::TRoomServiceMsg")
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

return RequestCreateRoomCommand
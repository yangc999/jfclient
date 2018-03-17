--region *.lua
--Date
--请求战绩详情的命令
local MatchRecordsProxy = import("..proxy.MatchRecordsProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestRecordDetailCommand = class("RequestRecordDetailCommand", SimpleCommand)

function RequestRecordDetailCommand:execute(notification)
    print("RequestRecordDetailCommand:execute")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local roomDetail = notification:getBody()
    dump(roomDetail, "房间详细信息")
    local roomNo = roomDetail.roomNo
    local userRecords = roomDetail.vecRecord

    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy") 

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --/activities
	xhr:open("POST", load:getData().serviceUrl.."standings")

     --显示网络请求转圈的UI
    cc.exports.showLoadingAnim("正在请求战绩详情...","战绩详情请求失败")

    --请求战绩数量的服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "standings::TStandingsMsg")
			local _, res3 = tarslib.decode(res2.vecData, "standings::TRspRoundRecordList")
            local vTotalList = {}     --用户战局列表

            cc.exports.hideLoadingAnim()

            --dump(res1,"res1:")
            --dump(res1,"res1:")
            --dump(res2,"res2结果")
            dump(res3, "res3战局列表结果:")
            if res3 == nil then
               print("服务器未返回数据 res3 = nil")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "服务器未返回数据")
               return
            end
            if res3.iRetCode==0 then --返回结果成功
                print("当前战局列表返回成功")
                --填充战局列表 
                for _,v in ipairs(res3.eRoundInfo) do
				    table.insert(vTotalList, v)
			    end
                 --设置当前战局列表
                matchRecordProxy:getData().vCurRoundList = vTotalList --战绩列表
                matchRecordProxy:getData().vCurRecordDetail = userRecords
                matchRecordProxy:getData().sRoomNo=roomNo  --详情房间ID

                platformFacade:sendNotification(PlatformConstants.GET_MATCHRECORDDETAIL, true)  --发送显示战绩详情页面
            else
                print("战绩详情返回失败! 结果码：" .. res3.iRetCode)
                platformFacade:sendNotification(PlatformConstants.GET_MATCHRECORDDETAIL, false)
                --platformFacade:registerMediator(MsgBoxMediator.new(1,"战绩详情返回失败! 结果码：" .. res3.iRetCode))
            end
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            cc.exports.hideLoadingAnim()
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)

     --发送请求战局详情请求
    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		  sRoomNo = roomNo,   --请求的用户ID
	}
    local req1 = tarslib.encode(pak1, "standings::TReqRoundRecordList")
    local pak2 = {
		  eAct = 2,    --E_A_PRIV_ROUNDLIST=2,         	//私人房战绩局数列表
		  vecData = req1, 
	}
    --下面是拼Http头，写法都是固定
	local req2 = tarslib.encode(pak2, "standings::TStandingsMsg")
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
	 xhr:send(req3)  --发送请求
     print("xhr:send 请求私人房战绩局数列表")
end

function RequestRecordDetailCommand:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    
    

    self:getViewComponent():removeFromParent()
    self:setViewComponent(nil)
end

return RequestRecordDetailCommand
--endregion

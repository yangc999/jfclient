--region *.lua
--Date
--请求战绩详情的命令
local MatchRecordsProxy = import("..proxy.MatchRecordsProxy")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestVideoUrlComman = class("RequestVideoUrlComman", SimpleCommand)

function RequestVideoUrlComman:execute(notification)
    print("RequestVideoUrlComman:execute")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    platformFacade:registerCommand(PlatformConstants.REQUEST_MATCHRECORDVIDEODATA, cc.exports.DownloadWatchVideoCommand) --请求战绩列表
    --TODO  请求内容
    local reqVideo = notification:getBody()
    dump(reqVideo, "请求录像地址参数")
    local roomNo = reqVideo.roomNo
    local roundNo = reqVideo.roundNo

    local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
	local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy") 

    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --/activities
    local httpUrl = load:getData().serviceUrl.."standings"
	xhr:open("POST",httpUrl )
    print("请求录像 httpUrl:",httpUrl)

     --显示网络请求转圈的UI
    cc.exports.showLoadingAnim("正在请求回放数据...","回放数据请求失败")

    --请求回放数据的服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "standings::TStandingsMsg")
			local _, res3 = tarslib.decode(res2.vecData, "standings::TRspWatchVideo")
            local vTotalList = {}     --用户战局列表

            cc.exports.hideLoadingAnim()

            dump(res3, "res3录像回放地址返回:")
            if res3 == nil then
               print("录像回放地址返回数据 res3 = nil")
               platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "服务器未返回数据")
               return
            end
            if res3.iRetCode==0 then --返回结果成功
                matchRecordProxy:getData().sVideoPath = res3.sVideoPath --战绩列表
                print("录像回放地址返回成功url:",matchRecordProxy:getData().sVideoPath)
                local videoPath = matchRecordProxy:getData().sVideoPath
                local curIndex = matchRecordProxy:getData().curIndex
                platformFacade:sendNotification(PlatformConstants.REQUEST_MATCHRECORDVIDEODATA,{url = videoPath,index = curIndex})
            else
                print("录像回放地址返回失败! 结果码：" .. res3.iRetCode)
                if res3.iRetCode==505 then
                    platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "没有找到相关录像信息")
                else 
                    platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "录像回放获取失败")    
                end
            end
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            cc.exports.hideLoadingAnim()
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)

     --发送请求录像地址
    local tarslib = cc.load("jfutils").Tars
	local pak1 = {
		  sRoomNo = roomNo,   --请求房间ID
          iRoundNo= roundNo, --回合数
	}
    dump(pak1,"请求录像")
    local req1 = tarslib.encode(pak1, "standings::TReqWatchVideo")
    local pak2 = {
		  eAct = 4,    --E_A_WATCH_VIDEO=4,         	//查看录像
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
     print("xhr:send 请求录像回放下载地址")
end

function RequestVideoUrlComman:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    
    platformFacade:removeCommand(PlatformConstants.REQUEST_MATCHRECORDVIDEODATA)

    self:getViewComponent():removeFromParent()
    self:setViewComponent(nil)
end

return RequestVideoUrlComman
--endregion

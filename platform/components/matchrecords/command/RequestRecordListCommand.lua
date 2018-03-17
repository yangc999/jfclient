--region *.lua
--Date
--请求战绩列表

local MatchRecordsProxy = import("..proxy.MatchRecordsProxy")
local MatchRecordsMediator = import("..mediator.MatchRecordsMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestRecordListCommand = class("RequestRecordListCommand", SimpleCommand)

function RequestRecordListCommand:execute(notification)
    print("RequestRecordListCommand:execute")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants
   -- local vecIndex = notification:getBody()  --请求的下标数组
    --dump(vecIndex, "vecIndex")
    local tIndexs = notification:getBody() --请求最小最大的战绩下标
    dump(tIndexs, "最小和最大战绩index")

    local minIndex = tIndexs.min   --请求的最小战绩Index
    local maxIndex = tIndexs.max  --请求的最大战绩index

  	local load = platformFacade:retrieveProxy("LoadProxy")
    local login = platformFacade:retrieveProxy("LoginProxy")
  	local matchRecordProxy = platformFacade:retrieveProxy("MatchRecordsProxy")

    

    local xhr = cc.XMLHttpRequest:new()
  	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING --/activities
  	xhr:open("POST", load:getData().serviceUrl.."standings")

     --显示网络请求转圈的UI
    cc.exports.showLoadingAnim("正在请求战绩列表...","战绩列表请求失败")

    --请求战绩列表的服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
        		local str = xhr.response
        		local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
        		local _, res2 = tarslib.decode(res1.vecData, "standings::TStandingsMsg")
        		local _, res3 = tarslib.decode(res2.vecData, "standings::TRspRoomRecordList")
            local vTotalList = {}     --用户战绩列表

            cc.exports.hideLoadingAnim()
            --dump(res1,"res1:")
            --dump(res2,"res2结果")
            dump(res3, "res3战绩列表结果:")
            if res3 == nil then
                print("服务器未返回数据 res3 = nil")
                --matchRecordProxy:getData().vIndexList = {}
                platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "服务器未返回数据")
                return
            end
            if res3.iRetCode==0 then --返回结果成功
                print("战绩列表返回成功")
                --隐藏loading界面
                 
                --matchRecordProxy:getData().nRecordNum = res3.iRowCount
                --填充免费抽奖奖品列表 
                for _,v in ipairs(res3.vecRoomInfo) do
				            table.insert(vTotalList, v)
			          end

                local vRecordList = matchRecordProxy:getData().vRecordList
                dump(vRecordList, "当前战绩")

                local lenRe = #vRecordList
                local indexT = 0
                local indexRe = 0

                if lenRe == 0 then
                    print("战绩列表为空")
                    vRecordList = vTotalList
                else
                    print("不为空，搜索插入")
                    -- dump(vRecordList, "当前刷新战绩")
                    -- dump(vTotalList, "服务器发来战绩")
                    local lenTo = #vTotalList
                    local canInsert = true
                    for i=1, lenTo do
                        indexT = vTotalList[i].iIndex
                        canInsert = true
                        for j=1, lenRe do
                            indexRe = vRecordList[j].iIndex
                            if indexRe == indexT then  --若发现服务器发来的数据里已经有相同的数据，就不在插入了
                                print("indexRe:" .. indexRe)
                                print("indexT:" .. indexT)
                                canIsert = false
                                break
                            end --endif        
                        end -- end for j=1,lenRe do
                        if canInsert==true then
                          table.insert(vRecordList, vTotalList[i])
                        end
                    end
                end

                dump(vRecordList, "插入后最终战绩")
                 --设置战绩
                matchRecordProxy:getData().vRecordList = vRecordList --战绩列表
                matchRecordProxy:getData().nMinIndex = minIndex
                matchRecordProxy:getData().nMaxIndex = maxIndex

                platformFacade:sendNotification(PlatformConstants.UPDATE_MATCHRECORDLIST, true)  --发送更新显示抽奖列表的信息
            else
               print("战绩总行数返回失败! 结果码：" .. res3.iRetCode)
               matchRecordProxy:getData().vIndexList ={}
               platformFacade:sendNotification(PlatformConstants.UPDATE_MATCHRECORDLIST, false)
            end
        else
            print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
            cc.exports.hideLoadingAnim()      
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)

    --发送请求抽奖列表请求
    local tarslib = cc.load("jfutils").Tars
    
  	local pak1 = {
  		  lUid = login:getData().uid,   --请求的用户ID
        iGameID = 0,
        iStartIndex = minIndex,  --最小索引
        iEndIndex = maxIndex,   --最大索引
  	}
      local req1 = tarslib.encode(pak1, "standings::TReqRoomRecordList")
      dump(req1, "战绩 req1")
      local pak2 = {
  		  eAct = 1,    --E_A_PRIV_ROOMLIST=1,
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
     print("xhr:send 请求战绩列表")
end

function RequestRecordListCommand:onRemove()
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local PlatformConstants = cc.exports.PlatformConstants
    
    

    self:getViewComponent():removeFromParent()
    self:setViewComponent(nil)
end

return RequestRecordListCommand
--endregion

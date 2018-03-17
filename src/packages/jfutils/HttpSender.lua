local HttpSender=class("HttpSender")

function HttpSender:ctor()
end
-- proto 协议 1.请求头（tars模块名） 2.接口名 3.actionName
-- sendData 要发送的数据
-- callback 回掉  解包后的数据作为参数
function HttpSender:post(proto,sendData,callback)
    print(proto[1]..proto[2],"HttpSend")
    local xhr = cc.XMLHttpRequest:new()
	xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
    local loadproxy=platformFacade:retrieveProxy("LoadProxy")
    local loginproxy=platformFacade:retrieveProxy("LoginProxy")
	xhr:open("POST", loadproxy:getData().serviceUrl..proto[1])
	local function onReadyStateChange()
		if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
        	local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
 
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, proto[1].."::"..proto[2].."Resp")
            dump(res3,"revData",10)
            if callback and res3~=nil then 
            callback(res3)
            end
		end
		xhr:unregisterScriptHandler()
	end
    xhr:registerScriptHandler(onReadyStateChange)
    local tarslib = cc.load("jfutils").Tars
	local pak1 =sendData

	local req1 = tarslib.encode(pak1, proto[1].."::"..proto[2].."Req")
	local pak2 = {
		actionName = proto[3], 
		reqBodyBytes = req1, 
	}
	local req2 = tarslib.encode(pak2, "commonstruct::CommonReqHead")
	local pak3 = {
		iVer = loadproxy:getData().version, 
		iSeq = loadproxy:getData().sequence, 
		stUid = {
			lUid = loginproxy:getData().uid, 
			sToken = loginproxy:getData().token, 
		}, 
		vecData = req2,
	}
	local req3 = tarslib.encode(pak3, "JFGame::THttpPackage")
	xhr:send(req3)
end
return HttpSender
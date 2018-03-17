--region *.lua
--Date
--请求商品列表

local ShopProxy = import("..proxy.ShopProxy")
local ShopMediator = import("..mediator.ShopMediator")

local SimpleCommand = cc.load("puremvc").SimpleCommand
local RequestShopListCommand = class("RequestShopListCommand", SimpleCommand)

--显示loading进度条
function RequestShopListCommand:showLoading(notification)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    --重新请求游戏列表
    local function retryReqShopList()
         local strMsg = "商品列表请求失败,是否重试?"
         local function okCall()  --确定按钮回调
            self:execute(notification)
         end
         local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
         platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
    end
    --显示转圈条
    cc.exports.showLoadingAnim("正在请求商品列表...","商品列表请求失败", retryReqShopList, 5)
end

--重新请求商品列表
function RequestShopListCommand:retryReqShopList(notification)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local strMsg = "商品列表请求失败,是否重试?"
    local function okCall()  --确定按钮回调
       self:execute(notification)
    end 
    local tMsg = {mType = 2, msg = strMsg, okCallback = okCall} --类型为2，code无用，msg为显示的描述，okCallback为按确定按钮的回调函数
    platformFacade:sendNotification(PlatformConstants.UPDATE_MSGBOX_EX, tMsg)  --弹出MsgBox，等用户确定。真正的购买请求在MSGBOX_OK消息处理里
end

function RequestShopListCommand:execute(notification)
    local nGainType = notification:getBody()  --获取请求的购买商品类型：1人民币(单位:分),2钻石,3房卡,4金币
    print("RequestShopListCommand:execute: nGainType:" .. nGainType)
	  local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	  local PlatformConstants = cc.exports.PlatformConstants

	  local load = platformFacade:retrieveProxy("LoadProxy")
      local login = platformFacade:retrieveProxy("LoginProxy")
	  local shopProxy = platformFacade:retrieveProxy("ShopProxy")

      local xhr = cc.XMLHttpRequest:new()
	  xhr.responseType = cc.XMLHTTPREQUEST_RESPONSE_STRING
	  xhr:open("POST", load:getData().serviceUrl.."config")   --设定请求地址 local testUrl = "http://192.168.0.242:18890/" 在LoadProxy.lua文件中

      --显示loading
     self:showLoading(notification)

    --请求商品列表服务器返回的回调函数
    local function onReadyStateChange()
        if xhr.readyState == 4 and xhr.status >= 200 and xhr.status < 207 then
            local tarslib = cc.load("jfutils").Tars
			local str = xhr.response
			local _, res1 = tarslib.decode(str, "JFGame::THttpPackage")
			local _, res2 = tarslib.decode(res1.vecData, "commonstruct::CommonRespHead")
			local _, res3 = tarslib.decode(res2.respBodyBytes, "systemconfig::ListShopOrderConfByGainTypeResp")
			local shoplist = {}   --商品列表
            dump(res2,"res2商品列表结果码:")
            if res2.resultCode == 0 then

              --隐藏loading界面
              cc.exports.hideLoadingAnim()

              --填充商品列表
              for _,v in ipairs(res3.shopOderConfList) do
				        table.insert(shoplist, v)
			        end
            else
               print("获取商品列表失败!")
            end

            --dump(shoplist,"shopList")
            --设置商品列表
            shopProxy:getData().reqType = nGainType   --当前请求的商品类型
            shopProxy:getData().curlist = shoplist   --设置商品当前列表
            if nGainType == 2 then --钻石列表
              --shopProxy:getData().diamondlist = {}  --先置为空
              shopProxy:getData().diamondlist = shoplist
              --dump(shopProxy:getData().diamondlist, "Req shopProxy:getData().diamondlist")
            elseif nGainType == 3 then --房卡列表
              --shopProxy:getData().fangkalist = {}
              shopProxy:getData().fangkalist = shoplist
              --dump(shopProxy:getData().fangkalist, "Req shopProxy:getData().fangkalist")
            elseif nGainType == 4 then --金币列表
             -- shopProxy:getData().coinlist = {}
              shopProxy:getData().coinlist = shoplist
              --dump(shopProxy:getData().coinlist, "Req shopProxy:getData().coinlist")
            end        
            platformFacade:sendNotification(PlatformConstants.SHOW_SHOPLIST)  --更新显示商品
      else
          print("网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
          --platformFacade:sendNotification(PlatformConstants.UPDATE_MESSAGE, "网络异常，请重新检查网络后尝试重新连接（如有问题请联系客服）")
          --self:retryReqShopList(notification)
        end
        xhr:unregisterScriptHandler()
    end
    xhr:registerScriptHandler(onReadyStateChange)

    --发送商品列表请求
    local tarslib = cc.load("jfutils").Tars
	  local pak1 = {
		  gainType = nGainType,   --请求的商品类型
          position = 0,   --请求的商城类型  0 大厅商城 1 游戏内快捷商城
	  }
	  local req1 = tarslib.encode(pak1, "systemconfig::ListShopOrderConfByGainTypeReq")
    local pak2 = {
		  actionName = 8,    --CONF_LIST_SHOP_ORDER_BY_GAIN_TYPE=8,     //  根据购买类型获取商城订单配置     在CommonStruct.tars文件里
		  reqBodyBytes = req1, 
	  }
    --下面是拼Http头，写法都是固定
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
	  xhr:send(req3)  --发送请求
end

return RequestShopListCommand

--endregion

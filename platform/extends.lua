
cc.exports.seekNodeByName = function(parent, name)
	if not parent then
		return
	end
	if name == parent.name then
		return parent
	end
	local findNode
	local children = parent:getChildren()
	local childCount = parent:getChildrenCount()
	if childCount < 1 then
		return
	end
	for i=1, childCount do
		if "table" == type(children) then
			parent = children[i]
		elseif "userdata" == type(children) then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			if name == parent:getName() then
				return parent
			end
		end
	end
	for i=1, childCount do
		if "table" == type(children) then
			parent = children[i]
		elseif "userdata" == type(children) then
			parent = children:objectAtIndex(i - 1)
		end

		if parent then
			findNode = seekNodeByName(parent, name)
			if findNode then
				return findNode
			end
		end
	end
	return
end

cc.exports.getImei = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getIMEI", {}, "()Ljava/lang/String;")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "000000"
	end
end

cc.exports.getNetworkType = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getNetworkType", {}, "()Ljava/lang/String;")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "000000"
	end
end

cc.exports.getNetworkStrength = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getNetworkStrength", {}, "()I")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "000000"
	end	
end

cc.exports.getBatteryLevel = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getBatteryLevel", {}, "()F")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "000000"
	end
end

cc.exports.getLocation = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, longitude = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getLongitude", {}, "()F")
		local _, latitude = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "getLatitude", {}, "()F")
		return {longitude=longitude, latitude=latitude}
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "000000"
	end	
end

cc.exports.isGpsEnabled = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "isGpsEnabled", {}, "()Z")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "000000"
	end	
end

cc.exports.openGps = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lua/AppActivity", "openGps", {}, "()V")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "000000"
	end
end

cc.exports.openUrl = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "openURL", {}, "(Ljava/lang/String;)Z")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "0.0.0.0"
	end
end

cc.exports.getVersionName = function()
	if device.platform == "android" then
		local luaj = require("cocos.cocos2d.luaj")
		local _, ret = luaj.callStaticMethod("org/cocos2dx/lib/Cocos2dxHelper", "getVersion", {}, "()Ljava/lang/String;")
		return ret
	elseif device.platform == "ios" then
		local luaoc = require("cocos.cocos2d.luaoc")
		local _, ret = luaoc.callStaticMethod()
		return ret
	elseif device.platform == "windows" then
		return "1.0.0.0"
	end
end

--检测手机号是不是全数字
-- phone：手机号，string
cc.exports.phoneIsNum = function(phone)
	if not phone then
		return false
	else
		local func_itor = string.gmatch(phone,"%d+")
		local res = ""
		while true do
			local ret = func_itor()
			if ret ~= nil then
			  res = res..ret
			else
			  break
			end
		end
		return res
	end
end

cc.exports.isPhoneValid = function(phone)
	--校检手机号前三位
	local phone_list = {133,149,153,173,177,180,181,189,199,130,131,132,145,155,156,166,175,176,185,186,134,135,136,137,138,139,147,150,151,152,157,158,159,178,182,183,184,187,188,198}
	--print("=================>",phone,type(phone))

	if not phone then
		return false
	elseif #phone ~= 11 then
		return false
	else
		local count = 0
		local three_num = string.sub(phone,1,3)
		three_num = tonumber(three_num)
		--print("three_num:",three_num,type(three_num))
		for k,v in pairs(phone_list) do
			if v == three_num then
				return true
			end
			count = count+1

		end
		if count == #phone_list then
			return false
		end
	end
end

--微信分享好友
--strUrl = "http://share.game4588.com"
--strTitle = "分享好友"
--strDesc = "请来看我玩的最牛最火的卡牌游戏"
--strImgPath = cc.FileUtils:getInstance():fullPathForFilename("platform_res/share/task-4.png")
--strScene = “0” 分享好友  “1”分享朋友圈
cc.exports.wxShareFriends = function(strUrl, strTitle, strDesc, strImgPath, strScene) --分享好友
    print("分享好友开始 shareFriends")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local weixin = plugin.PluginManager:getInstance():loadPlugin("ShareWeixin")
    local tVisit = {
        url = strUrl,
        title = strTitle,
        desc = strDesc,
        imgPath =  strImgPath,
        scene = strScene,  --0是分享好友，1是朋友圈
    }
	if weixin then
		weixin:setDebugMode(true)
		weixin:configDeveloperInfo({AppId="wx41d5f85d4cde056b"})
		weixin:share(tVisit, function(code, msg)
			if code == 0 then
                print("分享朋友成功")
                platformFacade:sendNotification(PlatformConstants.RESULT_WEIXINSHARE, 0) --微信分享成功
           else
               print("code = " .. code)
               platformFacade:sendNotification(PlatformConstants.RESULT_WEIXINSHARE, code) --微信分享失败
               print("分享失败")
			end
		end)
	end
end

--判断是不是汉字
--str  传入的字符串
--return true是汉字，false 不是汉字
cc.exports.isHanzi = function(str)
  local lenInByte = #str
  local i=1
  while i<=lenInByte do
      local curByte = string.byte(str, i)
      --local byteCount = 1;
      if curByte<224 or curByte>=239 then
          --byteCount = 3     --不是汉字
          print("不是汉字",curByte)
          return false
      else
      	  i= i+3
      end
      --local char = string.sub(str, i, i+byteCount-1)
      --print(i,curByte,char,byteCount)
  end
  return true
end

--展示获得物品的动画
--传入的ui就是各个界面的self:getViewComponent()
cc.exports.showGetAnimation = function(ui)
	local animator = seekNodeByName(ui, "get_animal")
	local animation = cc.CSLoader:createTimeline("hall_res/qiandao/qiandao.csb")
	---提示创建动画并启动
	print("start create animation")

	animation:gotoFrameAndPlay(0, false)
	animator:setVisible(true)
	animator:runAction(animation)
	--延后2秒再调用一次，防止滚动时numberOfCellsInTableView获得的格子数还是老数据造成崩crash
	--[[  --不能用这种方法，可能这个ui已经为空了
	performWithDelay( ui, function()
		print("animator:stopAction(animation)")                       
		animator:stopAction(animation)
		animator:setVisible(false)
	end , 2)
	--]]
	animation:setLastFrameCallFunc( function()
		--最后一帧放完后自动执行这个方法
        animator:stopAction(animation)
		animator:setVisible(false)
    end)
end

--显示Loading加载动画
--message: 加载的文本提示
--outtimetip: 超时提示
--call_back:超时回调
--超时时间
cc.exports.showLoadingAnim = function(message,outtimetip,call_back,time)
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    local tMsg = {msg = message, outtip = outtimetip, callback = call_back, time = time}
    platformFacade:sendNotification(PlatformConstants.SHOW_LOADINGANIM, tMsg)
end

--关闭Loading动画
cc.exports.hideLoadingAnim = function()
    print("cc.exports.hideLoadingAnim")
    local platformFacade = cc.load("puremvc").Facade.getInstance("platform")
	local PlatformConstants = cc.exports.PlatformConstants
    platformFacade:sendNotification(PlatformConstants.HIDE_LOADINGANIM)
end

--格式化输出金币长数字
cc.exports.formatLongNum = function(num)
    print("cc.exports.formatLongNum")
    local number = tonumber(num)
    if number == nil then
      print("不能转换为数字")    
      return
    end

    if number<=9999 then  --4位数
      return tostring(number)
    elseif number <= 99999 then  --5位数
      local n1 = number/10000

      local strResult =  string.format("%.3f", n1) .. "万"  --显示1.324W形式
      return strResult
    elseif number <= 999999 then  --6位数
       local n1 = number/10000

      local strResult =  string.format("%.2f", n1) .. "万"   --显示1.32W形式
      return strResult
    elseif number <= 9999999 then    --7位数
      local n1 = number/10000

      local strResult =  string.format("%.1f", n1) .. "万"   --显示1.32W形式
      return strResult
    elseif number <= 99999999 then  --8位数
      local n1 = math.floor(number/10000)
      local strResult =  tostring(n1) .. "万"
      return strResult
    elseif number <= 999999999 then  --9位数
       local n1 = number/100000000

      local strResult =  string.format("%.1f", n1) .. "亿"
      return strResult
    else
      local n1 = math.floor(number/1000000000)
      local strResult =  tostring(n1) .. "亿"
      local n2 = number - n1 * 1000000000
      n2 = math.floor(n2/10000)
      if n2>=1 then
        strResult = strResult .. tostring(n2) .. "万"
      end
      return strResult
    end
end

--返回游戏名
cc.exports.getProductName = function ()
    return "同桌游"
end

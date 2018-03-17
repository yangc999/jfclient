
local SimpleCommand = cc.load("puremvc").SimpleCommand
local StartInitWeiXinCommand = class("StartInitWeiXinCommand", SimpleCommand)

function StartInitWeiXinCommand:execute(notification)
	print("exec Wx Init")
    if plugin then
	    local weixin = plugin.PluginManager:getInstance():loadPlugin("UserWeixin")
		weixin:setDebugMode(true)
		weixin:configDeveloperInfo({AppId="wx41d5f85d4cde056b"})
    end
end

return StartInitWeiXinCommand
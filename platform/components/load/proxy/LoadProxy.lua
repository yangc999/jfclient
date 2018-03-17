
local ProxyData = cc.load("jfutils").ProxyData

local Proxy = cc.load("puremvc").Proxy
local LoadProxy = class("LoadProxy", Proxy)

function LoadProxy:ctor()
	self.super:ctor("LoadProxy")
	local data = ProxyData.new()
	data:prop("serviceUrl")
	data:prop("serverIp")
	data:prop("serverPort")
	data:prop("loginMethod")
	data:prop("payMethod")
	data:prop("availableGame")
	data:prop("deviceCode")
	data:prop("version")
	data:prop("sequence")
	data:prop("officialPhoneNum")
	data:prop("officialWxAccount")
	self:setData(data)

	local testUrl = device.platform == "windows" and "192.168.0.242" or "jfys.bzw.cn"
	--local testUrl = "jfys.bzw.cn"
--	local testUrl = "192.168.0.242"
	local addrinfo, err = socket.dns.getaddrinfo(testUrl)
	local testIp = testUrl
 	for i,v in ipairs(addrinfo) do
    	if v.family == "inet6" then
    		testIp = v.addr
        	break
       	else
       		testIp = v.addr
     	end
 	end
	local testPort = 18891
	--local loginMethod = {"wx", "guest"}
	--local availableGame = {10003300, 30601800}
	local payMethod = {"wx", "ali"}
	local deviceCode = cc.exports.getImei()
	print("deviceCode:", deviceCode)
	local version = 0
	local sequence = 0

	self:getData().serviceUrl = string.format("http://%s:%d/", testIp, 18890)
	print("serviceUrl", self:getData().serviceUrl)
	self:getData().serverIp = testIp
	self:getData().serverPort = testPort
	self:getData().payMethod = payMethod
	--self:getData().loginMethod = loginMethod
	--self:getData().availableGame = availableGame
	self:getData().deviceCode = deviceCode
	self:getData().version = version
	self:getData().sequence = sequence
end

function LoadProxy:onRegister()
	local tarslib = cc.load("jfutils").Tars
	local path1 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/load/tars/JFGameHttpProto.tars")
	tarslib.register(path1)
	local path2 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/load/tars/CommonStruct.tars")
	tarslib.register(path2)
	local path3 = cc.FileUtils:getInstance():fullPathForFilename("platform/components/load/tars/SysConfProto.tars")
	tarslib.register(path3)
end

function LoadProxy:onRemove()
end

return LoadProxy
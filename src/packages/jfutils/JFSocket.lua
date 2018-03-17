
local SOCKET_TICK_TIME = 0.1 			-- check socket data interval
local SOCKET_RECONNECT_TIME = 5			-- socket reconnect try interval
local SOCKET_CONNECT_FAIL_TIMEOUT = 3	-- socket failure timeout

local STATUS_CLOSED = "closed"
local STATUS_NOT_CONNECTED = "Socket is not connected"
local STATUS_ALREADY_CONNECTED = "already connected"
local STATUS_ALREADY_IN_PROGRESS = "Operation already in progress"
local STATUS_TIMEOUT = "timeout"

local scheduler = cc.Director:getInstance():getScheduler()
local socket = require "socket"

local JFSocket = class("JFSocket")

JFSocket.EVENT_DATA = "SOCKET_TCP_DATA"
JFSocket.EVENT_CLOSE = "SOCKET_TCP_CLOSE"
JFSocket.EVENT_CLOSED = "SOCKET_TCP_CLOSED"
JFSocket.EVENT_CONNECTED = "SOCKET_TCP_CONNECTED"
JFSocket.EVENT_CONNECT_FAILURE = "SOCKET_TCP_CONNECT_FAILURE"

JFSocket._VERSION = socket._VERSION
JFSocket._DEBUG = socket._DEBUG

function JFSocket.getTime()
	return socket.gettime()
end

function JFSocket:ctor(__host, __port, __retryConnectWhenFailure)
	self.event = cc.load("event").new()
	self.event:bind(self)

    self.host = __host
    self.port = __port
	self.tickScheduler = nil			-- timer for data
	self.reconnectScheduler = nil		-- timer for reconnect
	self.connectTimeTickScheduler = nil	-- timer for connect timeout
	self.name = "JFSocket"
	self.tcp = nil
	self.isRetryConnect = __retryConnectWhenFailure
	self.isConnected = false
end

function JFSocket:setName(__name)
	self.name = __name
	return self
end

function JFSocket:setTickTime(__time)
	SOCKET_TICK_TIME = __time
	return self
end

function JFSocket:setReconnTime(__time)
	SOCKET_RECONNECT_TIME = __time
	return self
end

function JFSocket:setConnFailTime(__time)
	SOCKET_CONNECT_FAIL_TIMEOUT = __time
	return self
end

function JFSocket:connect(__host, __port, __retryConnectWhenFailure)
	if __host then self.host = __host end
	if __port then self.port = __port end
	if __retryConnectWhenFailure ~= nil then self.isRetryConnect = __retryConnectWhenFailure end
	assert(self.host or self.port, "Host and port are necessary!")

 	local isipv6_only = false
 	local addrv4, addrv6
 	local addrinfo, err = socket.dns.getaddrinfo(self.host)
 	for i,v in ipairs(addrinfo) do
    	if v.family == "inet6" then
    		addrv6 = v.addr
        	isipv6_only = true
        	break
       	else
       		addrv4 = v.addr
     	end
 	end
 	print("isipv6_only", isipv6_only)
	if isipv6_only then
    	self.tcp = socket.tcp6()
    	self.host = addrv6
 	else
    	self.tcp = socket.tcp()
    	self.host = addrv4
 	end	
	self.tcp:settimeout(0)

	local function __checkConnect()
		local __succ = self:_connect()
		if __succ then
			self:_onConnected()
		end
		return __succ
	end

	if not __checkConnect() then
		-- check whether connection is success
		-- the connection is failure if socket isn't connected after SOCKET_CONNECT_FAIL_TIMEOUT seconds
		local __connectTimeTick = function ()
			print(string.format("%s.connectTimeTick", self.name))
			if self.isConnected then return end
			self.waitConnect = self.waitConnect or 0
			self.waitConnect = self.waitConnect + SOCKET_TICK_TIME
			if self.waitConnect >= SOCKET_CONNECT_FAIL_TIMEOUT then
				self.waitConnect = nil
				self:close()
				self:_connectFailure()
			end
			__checkConnect()
		end
		self.connectTimeTickScheduler = scheduler:scheduleScriptFunc(__connectTimeTick, SOCKET_TICK_TIME, false)
	end
end

function JFSocket:send(__data)
	assert(self.isConnected, self.name .. " is not connected.")
	self.tcp:send(__data)
end

function JFSocket:close( ... )
	print(string.format("%s.close", self.name))
	self.tcp:close()
	if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end
	if self.tickScheduler then scheduler:unscheduleScriptEntry(self.tickScheduler) end
	self:dispatchEvent({name=JFSocket.EVENT_CLOSE})
end

-- disconnect on user's own initiative.
function JFSocket:disconnect()
	self:_disconnect()
	self.isRetryConnect = false -- initiative to disconnect, no reconnect.
end

--------------------
-- private
--------------------

--- When connect a connected socket server, it will return "already connected"
-- @see: http://lua-users.org/lists/lua-l/2009-10/msg00584.html
function JFSocket:_connect()
	print(string.format("%s._connect", self.name))
	print(string.format("%s:%d", self.host, self.port))
	local __succ, __status = self.tcp:connect(self.host, self.port)
	print("JFSocket._connect:", __succ, __status)
	return __succ == 1 or __status == STATUS_ALREADY_CONNECTED
end

function JFSocket:_disconnect()
	self.isConnected = false
	self.tcp:shutdown()
	self:dispatchEvent({name=JFSocket.EVENT_CLOSED})
end

function JFSocket:_onDisconnect()
	print(string.format("%s._onDisConnect", self.name))
	self.isConnected = false
	self:dispatchEvent({name=JFSocket.EVENT_CLOSED})
	self:_reconnect()
end

-- connecte success, cancel the connection timerout timer
function JFSocket:_onConnected()
	print(string.format("%s._onConnectd", self.name))
	self.isConnected = true
	self:dispatchEvent({name=JFSocket.EVENT_CONNECTED})
	if self.connectTimeTickScheduler then scheduler:unscheduleScriptEntry(self.connectTimeTickScheduler) end

	local __tick = function()
		while true do
			-- if use "*l" pattern, some buffer will be discarded, why?
			local __body, __status, __partial = self.tcp:receive("*a")	-- read the package body
			--print("body:", __body, "__status:", __status, "__partial:", __partial)
    	    if __status == STATUS_CLOSED or __status == STATUS_NOT_CONNECTED then
		    	self:close()
		    	if self.isConnected then
		    		self:_onDisconnect()
		    	else
		    		self:_connectFailure()
		    	end
		   		return
	    	end
		    if 	(__body and string.len(__body) == 0) or
				(__partial and string.len(__partial) == 0)
			then return end
			if __body and __partial then __body = __body .. __partial end
			self:dispatchEvent({name=JFSocket.EVENT_DATA, data=(__partial or __body), partial=__partial, body=__body})
		end
	end

	-- start to read TCP data
	self.tickScheduler = scheduler:scheduleScriptFunc(__tick, SOCKET_TICK_TIME, false)
end

function JFSocket:_connectFailure(status)
	print(string.format("%s._connectFailure", self.name))
	self:dispatchEvent({name=JFSocket.EVENT_CONNECT_FAILURE})
	self:_reconnect()
end

-- if connection is initiative, do not reconnect
function JFSocket:_reconnect(__immediately)
	if not self.isRetryConnect then return end
	print(string.format("%s._reconnect", self.name))
	if __immediately then self:connect() return end
	if self.reconnectScheduler then scheduler:unscheduleScriptEntry(self.reconnectScheduler) end
	local __doReConnect = function ()
		self:connect()
	end
	self.reconnectScheduler = scheduler:scheduleScriptFunc(__doReConnect, SOCKET_RECONNECT_TIME, true)
end

return JFSocket

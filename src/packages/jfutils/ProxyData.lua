
local ProxyData = {}

ProxyData.mt = {
	__cname = "ProxyData", 
	__reserve = {
		prop = function(inst, name, defaultValue, facade, notificationName, notificationType)
			local prop = rawget(inst, "__prop")
			if not prop[name] then
				prop[name] = {
					data = defaultValue, 
					facade = facade, 
					notificationName = notificationName, 
					notificationType = notificationType
				}
			else
				error("already register property")
			end
		end
	}, 
	__index = function(inst, name)
		if ProxyData.mt.__reserve[name] then 
			return ProxyData.mt.__reserve[name]
		end
		local prop = rawget(inst, "__prop")
		if prop[name] then
			return prop[name].data
		end
		return nil
	end, 
	__newindex = function(inst, name, value)
		if ProxyData.mt.__reserve[name] then 
			error("cannot relocate reserve function")
		end
		local prop = rawget(inst, "__prop")
		if prop[name] then
			prop[name].data = value
			local facade = prop[name].facade
			local notificationName = prop[name].notificationName
			local notificationType = prop[name].notificationType
			if facade and notificationName then
				facade:sendNotification(notificationName, value, notificationType)
			end
		else
			error("cannot operate restricted object")
		end
	end
}

function ProxyData.new()
	local inst = {__prop = {}}
	setmetatable(inst, ProxyData.mt)
	return inst
end

return ProxyData

local Tars = {}
Tars.prototype = {}

local Tags = {
	TagInt1 = 0, --紧跟1个字节整型数据
	TagInt2 = 1, --紧跟2个字节整型数据
	TagInt4 = 2, --紧跟4个字节整型数据
	TagInt8 = 3, --紧跟8个字节整型数据
	TagFloat = 4, --紧跟4个字节浮点型数据
	TagDouble = 5, --紧跟8个字节浮点型数据
	TagString1 = 6, --紧跟1个字节长度，再跟内容
	TagString4 = 7, --紧跟4个字节长度，再跟内容
	TagMap = 8, --紧跟一个整型数据表示Map的大小，再跟[key, value]对列表
	TagList = 9, --紧跟一个整型数据表示List的大小，再跟元素列表
	TagStructBegin = 10, --自定义结构开始标志
	TagStructEnd = 11, --自定义结构结束标志，Tag为0
	TagZero = 12, --表示数字0，后面不跟数据
	TagSimpleList = 13, 
}

local function makeHead(type, tag)
	if tag < 15 then
		return string.pack("b", tars.writeHead(type, tag))
	else
		local t1 = string.pack("b", tars.writeHead(type, 15))
		local t2 = string.pack("b", tag)
		return t1 .. t2
	end
end

local function readHead(str, pos)
	local typeId, tag
	local nextPos, bit = string.unpack(str, "b", pos)
	if bit then
		typeId, tag = tars.readHead(bit)
		if tag == 15 then
			nextPos, tag = string.unpack(str, "b", nextPos)
		end
	end
	print("read tag:", table.keyof(Tags, typeId), tag)
	return nextPos, typeId, tag
end

------------------------call register----------------------

function Tars.register(path)
	print("load tars:", path)
	local data = cc.FileUtils:getInstance():getStringFromFile(path)
	local tempPath = cc.FileUtils:getInstance():getWritablePath() .. "temp.tars"
	cc.FileUtils:getInstance():writeStringToFile(data, tempPath)
	local output = tars.parse(tempPath)
	for _,v in pairs(output) do
		table.sort(v, function(a, b)
			return a.tag < b.tag
		end)
	end
	table.merge(Tars.prototype, output)
	cc.FileUtils:getInstance():removeFile(tempPath)
end

-----------------------serialize support-------------------

function tars.obj2boolean(obj, tag)
	if type(obj) ~= "boolean" then
		return nil
	end
	return tars.obj2int8(obj and 1 or 0, tag)
end

function tars.obj2int8(obj, tag)
	if type(obj) ~= "number" then
		return nil
	end
	if obj == 0 then
		return makeHead(Tags.TagZero, tag)
	else
		local head = makeHead(Tags.TagInt1, tag)
		local body = string.pack("c", obj)
		return head .. body
	end
end

function tars.obj2int16(obj, tag)
	if type(obj) ~= "number" then
		return nil
	end
	if obj >= -128 and obj <= 127 then
		return tars.obj2int8(obj, tag)
	else
		local head = makeHead(Tags.TagInt2, tag)
		local body = string.pack(">h", obj)
		return head .. body
	end
end

function tars.obj2int32(obj, tag)
	if type(obj) ~= "number" then
		return nil
	end
	if obj >= -32768 and obj <= 32767 then
		return tars.obj2int16(obj, tag)
	else
		local head = makeHead(Tags.TagInt4, tag)
		local body = string.pack(">i", obj)
		return head .. body
	end
end

function tars.obj2int64(obj, tag)
	if type(obj) ~= "number" then
		return nil
	end
	if obj >= -2147483648 and obj <= 2147483647 then
		return tars.obj2int32(obj, tag)
	else
		local head = makeHead(Tags.TagInt8, tag)
		local body = string.pack(">y", obj)
		return head .. body
	end
end

function tars.obj2float(obj, tag)
	if type(obj) ~= "number" then
		return nil
	end
	local head = makeHead(Tags.TagFloat, tag)
	local body = string.pack(">f", obj)
	return head .. body
end

function tars.obj2double(obj, tag)
	if type(obj) ~= "number" then
		return nil
	end
	local head = makeHead(Tags.TagDouble, tag)
	local body = string.pack(">d", obj)
	return head .. body
end

function tars.obj2string(obj, tag)
	if type(obj) ~= "string" then
		return nil
	end
	local length = string.len(obj)
	if length > 255 then
		local head = makeHead(Tags.TagString4, tag)
		local len = string.pack(">I", length)
		local body = string.pack("A", obj)
		return head .. len .. body
	else
		local head = makeHead(Tags.TagString1, tag)
		local len = string.pack("b", length)
		local body = string.pack("A", obj)
		return head .. len .. body
	end
end

function tars.obj2simplelist(obj, tag)
	if type(obj) ~= "string" then
		return nil
	end
	local head = makeHead(Tags.TagSimpleList, tag)
	local sub = makeHead(Tags.TagInt1, 0)
	local len = tars.obj2int32(string.len(obj), 0)
	local body = string.pack("A", obj)
	return head .. sub .. len .. body
end

function tars.tab2vector(tab, classType, tag)
	if type(tab) ~= "table" then
		return nil
	end
	local head = makeHead(Tags.TagList, tag)
	local len = tars.obj2int32(#tab, 0)
	local body = ""
	for _,v in ipairs(tab) do
		local str = tars.obj2str(v, classType, true, 0)
		if not str then
			return nil
		end
		body = body .. str
	end
	return head .. len .. body	
end

function tars.tab2map(tab, classType, tag)
	if type(tab) ~= "table" then
		return nil
	end
	local _, _, lType, rType = string.find(classType, "(.-),(.*)")
	local head = makeHead(Tags.TagMap, tag)
	local len = tars.obj2int32(#tab, 0)
	local body = ""
	for _,v in ipairs(tab) do
		local kstr = tars.obj2str(v[1], lType, true, 0)
		local vstr = tars.obj2str(v[2], rType, true, 1)
		if not kstr or not vstr then
			return nil
		end
		body = body .. kstr .. vstr
	end
	return head .. len .. body
end

function tars.tab2struct(tab, classType, tag)
	if type(tab) ~= "table" then
		return nil
	end
	local head = makeHead(Tags.TagStructBegin, tag)
	local body = Tars.encode(tab, classType)
	local tail = makeHead(Tags.TagStructEnd, 0)
	if body then
		return head .. body .. tail
	else
		return nil
	end
end

function tars.obj2str(obj, classType, isRequired, tag)
	if obj == nil then
		return nil
	end
	if classType == "bool" then
		return tars.obj2boolean(obj, tag)
	elseif classType == "char" then
		return tars.obj2int8(obj, tag)
	elseif classType == "short" then
		return tars.obj2int16(obj, tag)
	elseif classType == "int32" then
		return tars.obj2int32(obj, tag)
	elseif classType == "int64" then
		return tars.obj2int64(obj, tag)
	elseif classType == "float" then
		return tars.obj2float(obj, tag)
	elseif classType == "double" then
		return tars.obj2double(obj, tag)
	elseif classType == "string" then
		return tars.obj2string(obj, tag)
	else
		local _, _, vesselType, elementType = string.find(classType, "(.-)<(.*)>")
		if vesselType == "list" then
			if elementType == "char" then
				return tars.obj2simplelist(obj, tag)
			else
				return tars.tab2vector(obj, elementType, tag)
			end
		elseif vesselType == "map" then
			return tars.tab2map(obj, elementType, tag)
		elseif vesselType == "struct" then
			return tars.tab2struct(obj, elementType, tag)
		elseif vesselType == "enum" then
			return nil
		end
	end
	return nil
end

function Tars.encode(tab, className)
	if type(tab) ~= "table" then
		return nil
	end
	if not className or className == "" or not Tars.prototype[className] then
		print(string.format("prototype %s not register yet", className))
		return nil
	end	
	local str = ""
	local prototype = Tars.prototype[className]
	for i,pattern in ipairs(prototype) do
		local bytes = tars.obj2str(tab[pattern.name], pattern.classType, pattern.isRequired, pattern.tag)
		print(string.format("serialize string of %s within %s : %s", pattern.name, pattern.classType, bytes))
		if bytes then
			str = str .. bytes
		else
			if pattern.isRequired then
				print(string.format("cannot find required member %s", pattern.name))
				return nil
			end
		end
	end
	return str
end

----------------------unserialize support------------------

function tars.str2boolean(str, pos, tag)
	local nextPos, value = tars.str2int8(str, pos, tag)
	if value then
		return nextPos, (value == 1 and true or false)
	end
	return pos, nil
end

function tars.str2int8(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagZero then
			print("tag zero")
			return nextPos, 0
		else
			nextPos, value = string.unpack(str, "c", nextPos)
			print("tag int1")
			return nextPos, value
		end
	end
	return pos, nil
end

function tars.str2int16(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagInt2 then
			nextPos, value = string.unpack(str, ">h", nextPos)
			return nextPos, value
		else
			nextPos, value = tars.str2int8(str, pos, tag)
			return nextPos, value
		end
	end
	return pos, nil
end

function tars.str2int32(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagInt4 then
			nextPos, value = string.unpack(str, ">i", nextPos)
			return nextPos, value
		else
			nextPos, value = tars.str2int16(str, pos, tag)
			return nextPos, value
		end
	end
	return pos, nil
end

function tars.str2int64(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagInt8 then
			nextPos, value = string.unpack(str, ">y", nextPos)
			return nextPos, value
		else
			nextPos, value = tars.str2int32(str, pos, tag)
			return nextPos, value
		end
	end
	return pos, nil
end

function tars.str2float(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagFloat then
			nextPos, value = string.unpack(str, ">f", nextPos)
			return nextPos, value
		end
	end
	return pos, nil
end

function tars.str2double(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagDouble then
			nextPos, value = string.unpack(str, ">d", nextPos)
			return nextPos, value
		end
	end
	return pos, nil
end

function tars.str2string(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagString1 then
			local len = 0
			nextPos, len = string.unpack(str, "b", nextPos)
			nextPos, value = string.unpack(str, "A" .. len, nextPos)
			return nextPos, value
		elseif tagType == Tags.TagString4 then
			local len = 0
			nextPos, len = string.unpack(str, ">I", nextPos)
			nextPos, value = string.unpack(str, "A" .. len, nextPos)
			return nextPos, value			
		end
	end
	return pos, nil
end

function tars.str2simplelist(str, pos, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local value = nil
	if tagId == tag then
		if tagType == Tags.TagSimpleList then
			local eTagType, eTagId
			nextPos, eTagType, eTagId = readHead(str, nextPos)
			if eTagType == Tags.TagInt1 and eTagId == 0 then
				local len = nil
				nextPos, len = tars.str2int32(str, nextPos, 0)
				if len then
					nextPos, value = string.unpack(str, "A" .. len, nextPos)
					return nextPos, value
				end
			end
		end
	end
	return pos, nil
end

function tars.str2vector(str, pos, classType, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	local tab = {}
	if tagId == tag then
		if tagType == Tags.TagList then
			local len = 0
			nextPos, len = tars.str2int32(str, nextPos, 0)
			for i=1,len do
				local value = nil
				nextPos, value = tars.str2obj(str, nextPos, classType, 0)
				if value ~= nil then
					table.insert(tab, value)
				else
					return pos, nil
				end
			end
			return nextPos, tab
		end
	end
	return pos, nil
end

function tars.str2map(str, pos, classType, tag)
	local _, _, lType, rType = string.find(classType, "(.-),(.*)")
	local nextPos, tagType, tagId = readHead(str, pos)
	local tab = {}
	if tagId == tag then
		if tagType == Tags.TagMap then
			local len = 0
			nextPos, len = tars.str2int32(str, nextPos, 0)
			for i=1,len do
				local set = {}
				local lvalue, rvalue
				nextPos, lvalue = tars.str2obj(str, nextPos, lType, 0)
				nextPos, rvalue = tars.str2obj(str, nextPos, rType, 1)
				if lvalue ~= nil and rvalue ~= nil then
					set = {lvalue, rvalue}
					table.insert(tab, set)
				else
					return pos, nil
				end
			end
			return nextPos, tab
		end
	end
	return pos, nil
end

function tars.str2struct(str, pos, classType, tag)
	local nextPos, tagType, tagId = readHead(str, pos)
	if tagId == tag then
		if tagType == Tags.TagStructBegin then
			local substr = string.sub(str, nextPos)
			local sublen, tab = Tars.decode(substr, classType)
			if tab ~= nil then
				nextPos = nextPos + sublen - 1
				local eTagType, eTagId
				nextPos, eTagType, eTagId = readHead(str, nextPos)
				if eTagType == Tags.TagStructEnd and eTagId == 0 then
					return nextPos, tab
				else
					print("no endtag")
					return pos, nil
				end
			else
				return pos, nil
			end
		end
	end
	return pos, nil
end

function tars.str2obj(str, pos, classType, tag)
	if classType == "bool" then
		return tars.str2boolean(str, pos, tag)
	elseif classType == "char" then
		return tars.str2int8(str, pos, tag)
	elseif classType == "short" then
		return tars.str2int16(str, pos, tag)
	elseif classType == "int32" then
		return tars.str2int32(str, pos, tag)
	elseif classType == "int64" then
		return tars.str2int64(str, pos, tag)
	elseif classType == "float" then
		return tars.str2float(str, pos, tag)
	elseif classType == "double" then
		return tars.str2double(str, pos, tag)
	elseif classType == "string" then
		return tars.str2string(str, pos, tag)
	else
		local _, _, vesselType, elementType = string.find(classType, "(.-)<(.*)>")
		if vesselType == "list" then
			if elementType == "char" then
				return tars.str2simplelist(str, pos, tag)
			else
				return tars.str2vector(str, pos, elementType, tag)
			end
		elseif vesselType == "map" then
			return tars.str2map(str, pos, elementType, tag)
		elseif vesselType == "struct" then
			return tars.str2struct(str, pos, elementType, tag)
		elseif vesselType == "enum" then
			return nil
		end
	end
	return nil
end

function Tars.decode(str, className)
	if not str or str == "" then
		return nil
	end
	if not className or className == "" or not Tars.prototype[className] then
		return nil
	end
	local tab = {}
	local pos = 1
	local prototype = Tars.prototype[className]
	for i,pattern in ipairs(prototype) do
		local obj = nil
		print(string.format("read type %s", pattern.classType))
		print(string.format("read string start pos %d", pos))
		pos, obj = tars.str2obj(str, pos, pattern.classType, pattern.tag)
		dump(obj, "obj")
		print(string.format("read string end pos %d", pos))
		if obj ~= nil then
			tab[pattern.name] = obj
		else
			if pattern.isRequired then
				print(string.format("cannot unserialize member %s", pattern.name))
				return pos, nil
			end
		end
	end
	return pos, tab
end

return Tars
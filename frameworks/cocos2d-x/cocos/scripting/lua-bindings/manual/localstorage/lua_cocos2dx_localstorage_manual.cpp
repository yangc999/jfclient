/****************************************************************************
 Copyright (c) 2013-2017 Chukong Technologies Inc.
 
 http://www.cocos2d-x.org
 
 Permission is hereby granted, free of charge, to any person obtaining a copy
 of this software and associated documentation files (the "Software"), to deal
 in the Software without restriction, including without limitation the rights
 to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 copies of the Software, and to permit persons to whom the Software is
 furnished to do so, subject to the following conditions:
 
 The above copyright notice and this permission notice shall be included in
 all copies or substantial portions of the Software.
 
 THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 THE SOFTWARE.
 ****************************************************************************/
#include "scripting/lua-bindings/manual/localstorage/lua_cocos2dx_localstorage_manual.h"
#include "scripting/lua-bindings/manual/tolua_fix.h"
#include "scripting/lua-bindings/manual/LuaBasicConversions.h"
#include "storage/local-storage/LocalStorage.h"

int lua_cocos2dx_localstorage_setItem(lua_State* L)
{
	int argc = 0;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertable(L,1,"cc.LocalStorage",0,&tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(L) - 1;
	if (argc == 2)
	{
#if COCOS2D_DEBUG >= 1
		if (!tolua_isstring(L, 2, 0, &tolua_err) ||
			!tolua_isstring(L, 3, 0, &tolua_err))
			goto tolua_lerror;
#endif
		std::string key = tolua_tostring(L, 2, "");
		//std::string value = tolua_tostring(L, 3, "");
		size_t size = 0;
		const char* data = (const char*)lua_tolstring(L, 3, &size);
		std::string value(data, size);
		localStorageSetItem(key, value);
		return 0;
	}
    return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_localstorage_setItem'.",&tolua_err);
    return 0;
#endif  
}

int lua_cocos2dx_localstorage_getItem(lua_State* L)
{
	int argc = 0;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertable(L,1,"cc.LocalStorage",0,&tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(L) - 1;
	if (argc == 1)
	{
#if COCOS2D_DEBUG >= 1
		if (!tolua_isstring(L, 2, 0, &tolua_err))
			goto tolua_lerror;
#endif
		std::string key = tolua_tostring(L, 2, "");
		std::string value;
		localStorageGetItem(key, &value);
		lua_pushlstring(L, value.c_str(), value.length());
		return 1;
	}
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_localstorage_getItem'.",&tolua_err);
    return 0;
#endif   
}

int lua_cocos2dx_localstorage_removeItem(lua_State* L)
{
	int argc = 0;
#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
    if (!tolua_isusertable(L,1,"cc.LocalStorage",0,&tolua_err)) goto tolua_lerror;
#endif

	argc = lua_gettop(L) - 1;
	if (argc == 1)
	{
#if COCOS2D_DEBUG >= 1
		if (!tolua_isstring(L, 2, 0, &tolua_err))
			goto tolua_lerror;
#endif
		std::string key = tolua_tostring(L, 2, "");
		localStorageRemoveItem(key);
		return 0;
	}
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
    tolua_error(L,"#ferror in function 'lua_cocos2dx_localstorage_removeItem'.",&tolua_err);
    return 0;
#endif    
}

int lua_cocos2dx_localstorage_clear(lua_State* L)
{
	int argc = 0;
#if COCOS2D_DEBUG >= 1
	tolua_Error tolua_err;
	if (!tolua_isusertable(L, 1, "cc.LocalStorage", 0, &tolua_err)) goto tolua_lerror;
#endif
	
	argc = lua_gettop(L) - 1;
	if (argc == 0)
	{
		localStorageClear();
		return 0;
	}
	return 0;

#if COCOS2D_DEBUG >= 1
tolua_lerror:
	tolua_error(L, "#ferror in function 'lua_cocos2dx_localstorage_removeItem'.", &tolua_err);
	return 0;
#endif    
}

int lua_register_cocos2dx_localstorage(lua_State* L)
{
    tolua_usertype(L,"cc.LocalStorage");
    tolua_cclass(L,"LocalStorage","cc.LocalStorage","",nullptr);

    tolua_beginmodule(L,"LocalStorage");
        tolua_function(L, "setItem", lua_cocos2dx_localstorage_setItem);
        tolua_function(L, "getItem", lua_cocos2dx_localstorage_getItem);
        tolua_function(L, "removeItem", lua_cocos2dx_localstorage_removeItem);
		tolua_function(L, "clear", lua_cocos2dx_localstorage_clear);
    tolua_endmodule(L);
    std::string typeName = "localStorage";
    g_luaType[typeName] = "cc.LocalStorage";
    g_typeCast["LocalStorage"] = "cc.LocalStorage";
    return 1;
}

int register_all_cocos2dx_localstorage(lua_State* L)
{
    tolua_open(L);
    
    tolua_module(L,"cc",0);
    tolua_beginmodule(L,"cc");

    lua_register_cocos2dx_localstorage(L);

    tolua_endmodule(L);
    return 1;
}

int register_localstorage_module(lua_State* L)
{
    lua_getglobal(L, "_G");
    if (lua_istable(L,-1))//stack:...,_G,
    {
        register_all_cocos2dx_localstorage(L);
    }
    lua_pop(L, 1);
    return 1;
}



#include "tars.h"
#include "parse.h"
#include <cassert>
#include <string>


std::string toClassName(const TypePtr &pPtr);

std::string tostrVector(const VectorPtr &pPtr)
{
	std::string s = std::string("list<") + toClassName(pPtr->getTypePtr()) + ">";
	return s;
}

std::string tostrMap(const MapPtr &pPtr)
{	
	std::string s = std::string("map<") + toClassName(pPtr->getLeftTypePtr()) + "," + toClassName(pPtr->getRightTypePtr()) + ">";
	return s;
}

std::string tostrStruct(const StructPtr &pPtr)
{
	std::string s = std::string("struct<") + pPtr->getSid() + ">";
	return s;
}

std::string tostrEnum(const EnumPtr &pPtr)
{
	std::string s = "int32";
	return s;
}

std::string toClassName(const TypePtr &pPtr)
{
    std::string s;
    BuiltinPtr bPtr = std::dynamic_pointer_cast<Builtin>(pPtr);
    if (bPtr)
    {
        switch (bPtr->kind())
        {
            case Builtin::KindBool:     s = "bool";     break;
            case Builtin::KindByte:     s = "char";     break;
            case Builtin::KindShort:    s = "short";    break;
            case Builtin::KindInt:      s = "int32";    break;
            case Builtin::KindLong:     s = "int64";    break;
            case Builtin::KindFloat:    s = "float";    break;
            case Builtin::KindDouble:   s = "double";   break;
            case Builtin::KindString:   s = "string";   break;
            default:                    assert(false);  break;
        }
        return s;
    }

	VectorPtr vPtr = std::dynamic_pointer_cast<Vector>(pPtr);
    if (vPtr) return tostrVector(vPtr);

	MapPtr mPtr = std::dynamic_pointer_cast<Map>(pPtr);
    if (mPtr) return tostrMap(mPtr);

	StructPtr sPtr = std::dynamic_pointer_cast<Struct>(pPtr);
	if (sPtr) return tostrStruct(sPtr);

	EnumPtr ePtr = std::dynamic_pointer_cast<Enum>(pPtr);
	if (ePtr) return tostrEnum(ePtr);

    if (!pPtr) return "void";

    assert(false);
    return "";
}

extern "C"
{

#include "lua.h"
#include "lauxlib.h"

static int l_tars_formatMember(const TypeIdPtr& pMember, lua_State *L)
{
	lua_newtable(L);
	lua_pushstring(L, "name");
	lua_pushstring(L, pMember->getId().c_str());
	lua_settable(L, -3);
	lua_pushstring(L, "classType");
	lua_pushstring(L, toClassName(pMember->getTypePtr()).c_str());
	lua_settable(L, -3);
	lua_pushstring(L, "isRequired");
	lua_pushboolean(L, pMember->isRequire() ? 1 : 0);
	lua_settable(L, -3);
	lua_pushstring(L, "tag");
	lua_pushnumber(L, pMember->getTag());
	lua_settable(L, -3);
	lua_pushstring(L, "isUnsigned");
	BuiltinPtr pBuiltin = std::dynamic_pointer_cast<Builtin>(pMember->getTypePtr());
	if (pBuiltin)
	{
		lua_pushboolean(L, pBuiltin->isUnsigned() ? 1 : 0);
	}
	else
	{
		lua_pushboolean(L, 0);
	}
	lua_settable(L, -3);
	return 1;
}

static int l_tars_formatStruct(const StructPtr& pPtr, lua_State *L)
{
	lua_newtable(L);
	vector<TypeIdPtr>& member = pPtr->getAllMemberPtr();
	for (size_t j = 0; j < member.size(); j++)
	{
		lua_pushinteger(L, j + 1);
		l_tars_formatMember(member[j], L);
		lua_settable(L, -3);
	}
	return 1;
}

static int l_tars_parse(lua_State *L)
{
	if (lua_isstring(L, 1))
	{
		std::string path = lua_tostring(L, 1);
		g_parse->parse(path);
		lua_newtable(L);
		const std::vector<ContextPtr>& contexts = g_parse->getContexts();
		for (size_t i = 0; i < contexts.size(); i++)
		{
			const vector<NamespacePtr>& namespaces = contexts[i]->getNamespaces();
			for (size_t j = 0; j < namespaces.size(); j++)
			{
				vector<StructPtr>& structs = namespaces[j]->getAllStructPtr();
				for (size_t m = 0; m < structs.size(); m++)
				{
					lua_pushstring(L, structs[m]->getSid().c_str());
					l_tars_formatStruct(structs[m], L);
					lua_settable(L, -3);
				}
			}
		}
		return 1;
	}
	else
	{
		return 0;
	}
}

static int l_tars_readHead(lua_State *L)
{
	int top = lua_gettop(L);
	if (top == 1)
	{
		unsigned char head = (unsigned char)lua_tointeger(L, 1);
		lua_pushinteger(L, head & 0x0F);
		lua_pushinteger(L, head >> 4);
		return 2;
	}
	else
	{
		return 0;
	}
}

static int l_tars_writeHead(lua_State *L)
{
	int top = lua_gettop(L);
	if (top == 2)
	{
		unsigned char type = (unsigned char)lua_tointeger(L, 1);
		unsigned char tag = (unsigned char)lua_tointeger(L, 2);
		if (type <= 15 && tag <= 15)
		{
			unsigned char head = 0;
			head |= (tag << 4);
			head |= type;
			lua_pushinteger(L, head);
			return 1;
		}
		else
		{
			return 0;
		}
	}
	else
	{
		return 0;
	}
}

static const luaL_Reg func[] = {
	{ "parse", l_tars_parse }, 
	{ "readHead", l_tars_readHead }, 
	{ "writeHead", l_tars_writeHead }, 
	{ NULL, NULL }
};

void open_base(lua_State *L)
{
	luaL_openlib(L, "tars", func, 0);
	lua_pop(L, 1);
}

void luaopen_tars(lua_State *L)
{
	open_base(L);
}

}
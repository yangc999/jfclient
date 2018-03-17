#ifndef LPACK_H
#define LPACK_H

#if __cplusplus
extern "C" {
#endif

#include "lua.h"

int luaopen_pack(lua_State *L);

#if __cplusplus
}
#endif

#endif /* LPACK_H */
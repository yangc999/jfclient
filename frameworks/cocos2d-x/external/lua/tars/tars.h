#ifndef LTARS_H
#define LTARS_H

#if __cplusplus
extern "C" {
#endif

#include "lua.h"

void luaopen_tars(lua_State *L);

#if __cplusplus
}
#endif

#endif /* LTARS_H */
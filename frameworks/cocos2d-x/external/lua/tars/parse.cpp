/**
 * Tencent is pleased to support the open source community by making Tars available.
 *
 * Copyright (C) 2016THL A29 Limited, a Tencent company. All rights reserved.
 *
 * Licensed under the BSD 3-Clause License (the "License"); you may not use this file except 
 * in compliance with the License. You may obtain a copy of the License at
 *
 * https://opensource.org/licenses/BSD-3-Clause
 *
 * Unless required by applicable law or agreed to in writing, software distributed 
 * under the License is distributed on an "AS IS" BASIS, WITHOUT WARRANTIES OR 
 * CONDITIONS OF ANY KIND, either express or implied. See the License for the 
 * specific language governing permissions and limitations under the License.
 */

#include "parse.h"
#include "tars.tab.hpp"
#include <errno.h>
#include <fstream>
#include <string.h>
#include <memory>
#include "cocos2d.h"

TarsParsePtr g_parse = std::make_shared<TarsParse>();

void yyerror(char const *msg)
{
    g_parse->error(msg);
}

TarsParse::TarsParse()
{
    _itab = 0;
    initScanner();
}

void TarsParse::clear()
{
    while(!_contexts.empty()) _contexts.pop();
    while(!_contains.empty()) _contains.pop();
    _vcontexts.clear();
    _structs.clear();
    _enums.clear();
    _namespaces.clear();
}

void TarsParse::parse(const string& sFileName)
{
    {
        clear();

        _contains.push(std::make_shared<Container>(""));
        if(!(yyin = fopen(sFileName.c_str(), "r")))
        {
            error("open file '" + sFileName + "' error :" + string(strerror(errno)));
        }

        pushFile(sFileName);

        yyparse();

		fclose(yyin);
    }
}

void TarsParse::pushFile(const string &file)
{
    ContextPtr c = std::make_shared<Context>(file);
    _contexts.push(c);
    _vcontexts.push_back(c);
}

ContextPtr TarsParse::popFile()
{
    ContextPtr c = _contexts.top();
    _contexts.pop();
    return c;
}

bool TarsParse::getFilePath(const string &s, string &file)
{
	if (!cocos2d::FileUtils::getInstance()->isFileExist(s))
		return false;
	file = cocos2d::FileUtils::getInstance()->fullPathForFilename(s);
    return true;
}

void TarsParse::nextLine()
{
   _contexts.top()->nextLine();
}

ContextPtr TarsParse::currentContextPtr()
{
    return _contexts.top();
}

void TarsParse::error(const string &msg)
{
    cerr <<  _contexts.top()->getFileName() << ": " << _contexts.top()->getCurrLine() << ": error: " << msg << endl;
    exit(-1);
}

int TarsParse::checkKeyword(const string& s)
{
    std::map<std::string, int>::const_iterator it = _keywordMap.find(s);
    if(it != _keywordMap.end())
    {
        return it->second;
    }

    return TARS_IDENTIFIER;
}

void TarsParse::initScanner()
{
    _keywordMap["void"]     = TARS_VOID;
    _keywordMap["struct"]   = TARS_STRUCT;
    _keywordMap["bool"]     = TARS_BOOL;
    _keywordMap["byte"]     = TARS_BYTE;
    _keywordMap["short"]    = TARS_SHORT;
    _keywordMap["int"]      = TARS_INT;
    _keywordMap["double"]   = TARS_DOUBLE;
    _keywordMap["float"]    = TARS_FLOAT;
    _keywordMap["long"]     = TARS_LONG;
    _keywordMap["string"]   = TARS_STRING;
    _keywordMap["vector"]   = TARS_VECTOR;
    _keywordMap["map"]      = TARS_MAP;
    _keywordMap["key"]      = TARS_KEY;
    _keywordMap["routekey"] = TARS_ROUTE_KEY;
    _keywordMap["module"]   = TARS_NAMESPACE;
    _keywordMap["interface"]= TARS_INTERFACE;
    _keywordMap["out"]      = TARS_OUT;
    _keywordMap["require"]  = TARS_REQUIRE;
    _keywordMap["optional"] = TARS_OPTIONAL;
    _keywordMap["false"]    = TARS_FALSE;
    _keywordMap["true"]     = TARS_TRUE;
    _keywordMap["enum"]     = TARS_ENUM;
    _keywordMap["const"]    = TARS_CONST;
    _keywordMap["unsigned"] = TARS_UNSIGNED;
}

string TarsParse::getTab()
{
    ostringstream s;
    for(int i = 0; i < _itab; i++)
    {
        s << "    ";
    }

    return s.str();
}

BuiltinPtr TarsParse::createBuiltin(Builtin::Kind kind,bool isUnsigned)
{
    return std::make_shared<Builtin>(kind,isUnsigned);
}

VectorPtr TarsParse::createVector(const TypePtr &ptr)
{
    return std::make_shared<Vector>(ptr);
}

MapPtr TarsParse::createMap(const TypePtr &pleft, const TypePtr &pright)
{
    return std::make_shared<Map>(pleft, pright);
}

void TarsParse::addNamespacePtr(const NamespacePtr &nPtr)
{
    _namespaces.push_back(nPtr);
}

NamespacePtr TarsParse::findNamespace(const string &id)
{
    for(size_t i = 0; i < _namespaces.size(); i++)
    {
        if(_namespaces[i]->getId() == id)
        {
            return _namespaces[i];
        }
    }

    return NULL;
}

NamespacePtr TarsParse::currentNamespace()
{
    return _namespaces.back();
}

void TarsParse::addStructPtr(const StructPtr &sPtr)
{
    _structs.push_back(sPtr);
}

void TarsParse::addEnumPtr(const EnumPtr &ePtr)
{
    _enums.push_back(ePtr);
}

StructPtr TarsParse::findStruct(const string &sid)
{
    string ssid = sid;

    //在当前namespace中查找
    NamespacePtr np = currentNamespace();
    if(ssid.find("::") == string::npos)
    {
        ssid = np->getId() + "::" + ssid;
    }

    for(size_t i = 0; i < _structs.size(); i++)
    {
        if(_structs[i]->getSid() == ssid)
        {
            return _structs[i];
        }
    }

    return NULL;
}

EnumPtr TarsParse::findEnum(const string &sid)
{
    string ssid = sid;

    //在当前namespace中查找
    NamespacePtr np = currentNamespace();
    if(ssid.find("::") == string::npos)
    {
        ssid = np->getId() + "::" + sid;
    }

    for(size_t i = 0; i < _enums.size(); i++)
    {
        if(_enums[i]->getSid() == ssid)
        {
            return _enums[i];
        }
    }

    return NULL;
}

bool TarsParse::checkEnum(const string &idName)
{
    for(size_t i = 0; i < _enums.size(); i++)
    {
        vector<TypeIdPtr> & list = _enums[i]->getAllMemberPtr();
	
        for (size_t j = 0; j < list.size(); j++)
        {
            if (list[j]->getId() == idName)
            {
                return true;
            }
        }
    }

    return false;
}
void TarsParse::checkConflict(const string &sid)
{
    //是否和枚举重名
    if(findEnum(sid))
    {
        error("conflicts with enum '" + sid + "'");
    }

    //是否和结构重名
    if(findStruct(sid))
    {
        error("conflicts with struct '" + sid + "'");
    }
}

TypePtr TarsParse::findUserType(const string &sid)
{
    StructPtr sPtr = findStruct(sid);
    if(sPtr) return sPtr;

    EnumPtr ePtr = findEnum(sid);
    if(ePtr) return ePtr;

    return NULL;
}

ContainerPtr TarsParse::currentContainer()
{
    return _contains.top();
}

void TarsParse::pushContainer(const ContainerPtr &c)
{
    _contains.push(c);
	NamespacePtr np = std::dynamic_pointer_cast<Namespace>(c);
    if(np)
    {
        addNamespacePtr(np);
    }
}

ContainerPtr TarsParse::popContainer()
{
    ContainerPtr c = _contains.top();
    _contains.pop();

    return c;
}

void TarsParse::checkTag(int i)
{
    if(i >= 256)
    {
        error("struct memeber tag can't beyond 256");
    }
    if(i < 0)
    {
        error("struct memeber tag can't less then 0");
    }
}

void TarsParse::checkSize(int i)
{
    if(i >= 1024*1024)
    {
        error("struct memeber size can't beyond 1M");
    }
    if(i < 1)
    {
        error("struct memeber size can't less than 1");
    }
}

void TarsParse::checkArrayVaid(TypePtr &tPtr,int size)
{
    checkSize(size);
    //只有string/vector可以为array类型
    //vector不可以嵌套array类型 例如不允许vector<string:8>:2; 

	VectorPtr vPtr = std::dynamic_pointer_cast<Vector>(tPtr);
    if(vPtr )
    {
        if(vPtr->getTypePtr()->isArray())
        {
            error("fixed array type can not be nested");
        }
        return; 
    }
	BuiltinPtr bPtr = std::dynamic_pointer_cast<Builtin>(tPtr);
    if(bPtr && bPtr->kind() == Builtin::KindString)
    {
       return;
    }
    error("only string or vector can use fix array");
}

void TarsParse::checkPointerVaid(TypePtr &tPtr)
{
    //必须为vector<Byte>类型

	VectorPtr vPtr = std::dynamic_pointer_cast<Vector>(tPtr);
    if(vPtr)
    {
		BuiltinPtr bPtr = std::dynamic_pointer_cast<Builtin>(vPtr->getTypePtr());
        if( bPtr && bPtr->kind() == Builtin::KindByte) 
        return; 
    }  
    error("only 'byte *' can  be pointer type");
}

void TarsParse::checkConstValue(TypeIdPtr &tPtr, int c)
{
    //只有内建类型才能有缺省值
	BuiltinPtr bPtr = std::dynamic_pointer_cast<Builtin>(tPtr->getTypePtr());
	EnumPtr ePtr = std::dynamic_pointer_cast<Enum>(tPtr->getTypePtr());
    if(!bPtr && !ePtr)
    {
        error("only base/enum type can have default value");
    }

    if (ePtr)
    {
        if (c != ConstGrammar::VALUE && c != ConstGrammar::ENUM)
        {
            error("default value of enum only be int or enum_type");
        }

        return ;
	}

    int b = bPtr->kind();

    if(c == ConstGrammar::VALUE)
    {
        if(b == Builtin::KindBool)
        {
            error("default value of bool can only be true or false");
        }
        if(b == Builtin::KindString)
        {
            error("default value of string can only be \"string\"");
        }
    }
    else if(c == ConstGrammar::BOOL)
    {
        if(b != Builtin::KindBool)
        {
            error("only bool type can be true or false");
        }
    }
    else if(c == ConstGrammar::STRING)
    {
        if(b != Builtin::KindString)
        {
            error("only string type can be \"string\"");
        }
    }
}




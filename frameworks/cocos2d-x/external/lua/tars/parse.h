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

#ifndef __TARS_PARSE_H_
#define __TARS_PARSE_H_

#include <iostream>
#include <string>
#include <vector>
#include <algorithm>
#include <iterator>
#include <map>
#include <stack>
#include <sstream>
#include <sys/types.h>
#include <sys/stat.h>
#include "element.h"

using namespace std;

/**
 * Tars文件解析类
 *
 */
class TarsParse
{
public:
    /**
     * 构造函数
     */
    TarsParse();

    /**
     * 解析某一个文件
     * @param sFileName
     */
    void parse(const string &sFileName);

    /**
     * 错误提示
     * @param msg
     */
    void error(const string &msg);

    /**
     * 检查关键字
     * @param s
     *
     * @return int
     */
    int  checkKeyword(const string &s);

    /**
     * 下一行
     */
    void nextLine();

    /**
     * tab
     *
     * @return string
     */
    string getTab();

    /**
     * 增加tab数
     */
    void incTab() { _itab++; }

    /**
     * 减少tab数
     */
    void delTab() { _itab--; }

    /**
     * 解析文件
     * @param file
     */
    void pushFile(const string &file);

    /**
     * 弹出解析文件
     */
    ContextPtr popFile();

    /**
     * 获取所有的上下文
     *
     * @return std::vector<ContextPtr>
     */
    std::vector<ContextPtr> getContexts() { return _vcontexts; }

    /**
     * 获取目前的容器
     *
     * @return ContainerPtr
     */
    ContainerPtr currentContainer();

    /**
     * push容器
     * @param c
     */
    void pushContainer(const ContainerPtr &c);

    /**
     * 目前的上下文
     *
     * @return ContextPtr
     */
    ContextPtr currentContextPtr();

    /**
     * 弹出容器
     *
     * @return ContainerPtr
     */
    ContainerPtr popContainer();

    /**
     * 生成Builtin元素
     * @param kind
     *
     * @return BuiltinPtr
     */
    BuiltinPtr createBuiltin(Builtin::Kind kind,bool isUnsigned = false);

    /**
     * 生成Vector元素
     * @param ptr
     *
     * @return VectorPtr
     */
    VectorPtr createVector(const TypePtr &ptr);

    /**
     * 生成Map元素
     * @param pleft
     * @param pright
     *
     * @return MapPtr
     */
    MapPtr createMap(const TypePtr &pleft, const TypePtr &pright);

    /**
     * 添加结构元素
     * @param sPtr
     */
    void addStructPtr(const StructPtr &sPtr);

    /**
     * 查找结构
     * @param id
     *
     * @return StructPtr
     */
    StructPtr findStruct(const string &sid);

    /**
     * 添加枚举元素
     * @param ePtr
     */
    void addEnumPtr(const EnumPtr &ePtr);

    /**
     * 查找结构
     * @param id
     *
     * @return EnumPtr
     */
    EnumPtr findEnum(const string &sid);

    /**
     * 检查冲突
     * @param id
     */
    void checkConflict(const string &sid);

    /**
     * 查找自定义类型
     * @param sid
     *
     * @return TypePtr
     */
    TypePtr findUserType(const string &sid);

    /**
     * 查找名字空间
     * @param id
     *
     * @return NamespacePtr
     */
    NamespacePtr findNamespace(const string &id);

    /**
     * 目前的名字空间
     *
     * @return NamespacePtr
     */
    NamespacePtr currentNamespace();

    /**
     * 检查tag的合法性
     * @param i
     */
    void checkTag(int i);

    
    /**
     * 检查szie的合法性
     * @param i
     */
    void checkSize(int i);

    /**
     * 检查array的合法性
     * @param i
     */
    void checkArrayVaid(TypePtr &tPtr,int size);

    /**
     * 检查pointer的合法性
     * @param i
     */
    void checkPointerVaid(TypePtr &tPtr);

    /**
     * 检查常量类型和值是否一致
     * @param c
     * @param b
     */
    void checkConstValue(TypeIdPtr &tPtr, int b);

    /**
     * 获取文件名
     * @param s
     *
     * @return string
     */
    bool getFilePath(const string &s, string &file);

    void setKeyStruct(const StructPtr& key)
    {
        _key = key;
    }

    StructPtr getKeyStruct()
    {
        return _key;
    }

    /**
     * 判断当前的标识符是否是枚举变量
     */
    bool checkEnum(const string &idName);
    
protected:
    /**
     * 添加名字空间
     * @param nPtr
     */
    void addNamespacePtr(const NamespacePtr &nPtr);

    /**
     * 初始化
     */
    void initScanner();

    /**
     * 清除
     */
    void clear();

protected:
    std::map<std::string, int>      _keywordMap;
    int                             _itab;
    StructPtr                       _key;
    std::stack<ContextPtr>          _contexts;
    std::stack<ContainerPtr>        _contains;
    std::vector<ContextPtr>         _vcontexts;
    std::vector<StructPtr>          _structs;
    std::vector<EnumPtr>            _enums;
    std::vector<NamespacePtr>       _namespaces;
    std::vector<string>             _vIncludePath;
};

extern int yyparse();
extern int yylex();
extern FILE *yyin, *yyout;

typedef std::shared_ptr<TarsParse> TarsParsePtr;

extern TarsParsePtr g_parse;

#endif



# TypeScriptToLua如何支持循环引用

## Usage

RequireTest_ts 为 TypeScript 编写的脚本

RequireTest_lua 为 TypeScriptToLua 生成的 lua代码

RequireMain.lua 是程序入口文件，直接执行会发现循环引用的报错。

拷贝 circle_require4tsxxx.lua 到 RequireTest_lua 目录，并添加 require

## 循环引用

循环引用（Circular Require, Circular dependencies），在lua环境中，指的是这样的情况：

有两个lua文件A和B，文件A中require了B，文件B中require了A，这样在lua解析时会陷入死循环。

很容易想到，在文件require（也就是加载）的时候，应该有三种状态。
1. 未加载
2. 加载中
3. 加载完成

但是lua原生的代码 package.loaded 仅支持1、3两种状态。
1. LOADED[name] = nil
3. LOADED[name] = loader返回值 / true

```c
/**
 * package.loaded[name] 有三种情况 nil loader的返回值 TRUE(1)
 * 1. nil 表示文件未加载
 * 2. 如果loader有返回值，会赋值；否则，LOADED[name]为TRUE
 * 
 * 考虑下循环引用的问题
 * 1. load文件a require b时，b require a，此时package.loaded没有a，会陷入循环
 *  这个问题可以通过标记解决
 * 2. require获取返回值的问题
 * 3. 热更新的问题
*/
static int ll_require (lua_State *L) {
  //1. 如果LOADED[name]不为false，则不做处理
  const char *name = luaL_checkstring(L, 1);
  lua_settop(L, 1);  /* LOADED table will be at index 2 */
  lua_getfield(L, LUA_REGISTRYINDEX, LUA_LOADED_TABLE);
  lua_getfield(L, 2, name);  /* LOADED[name] */
  if (lua_toboolean(L, -1))  /* is it there? */
    return 1;  /* package is already loaded */
  /* else must load package */
  lua_pop(L, 1);  /* remove 'getfield' result */

  //2. 加载文件，赋值LOADED[name]
  findloader(L, name);
  lua_pushstring(L, name);  /* pass name as argument to module loader */
  lua_insert(L, -2);  /* name is 1st argument (before search data) */
  lua_call(L, 2, 1);  /* run loader to load module */
  if (!lua_isnil(L, -1))  /* non-nil return? */
    lua_setfield(L, 2, name);  /* LOADED[name] = returned value */

  if (lua_getfield(L, 2, name) == LUA_TNIL) {   /* module set no value? */
    lua_pushboolean(L, 1);  /* use true as result */
    lua_pushvalue(L, -1);  /* extra copy to be returned */
    lua_setfield(L, 2, name);  /* LOADED[name] = true */
  }
  return 1;
}
```

阅读ll_require代码可知，这个全局的C函数，仅做了两件事情：

1. 读取LOADED[name]，如果为有效值，则直接返回该值。

lua_toboolean最终会走到!l_isfalse宏

```c
#define l_isfalse(o)	(ttisnil(o) || (ttisboolean(o) && bvalue(o) == 0))
```
2. 如果LOADED[name]无效，加载文件，设置LOADED[name]

这里很明显没有处理【加载文件】操作中，存在循环引用的问题。

即A文件加载途中的时候requireB文件，此时B文件requireA文件，LOADED[A]判断为空，又会走到加载A文件的逻辑，从而陷入死循环。

## 解决循环引用

解决方法，是在两个操作之间，设置一个LOADED[name]的临时标记阻断死循环。
也就是说，LOADED[name]会赋值两次。伪代码如下

```lua
function require(name)
    if not package.loaded[name] then
        local loader = findloader(name)
        if loader == nil then
            error("unable to load module " .. name)
        end
        
        package.loaded[name] = true
        local res = loader(name)
        if res ~= nil then
            package.loaded[name] = res
        end
    end
    return package.loaded[name]
```

### module的做法

这样的做法在【module时代】是可行的，所以在erro信息里你会看到"unable to load module "字眼。

也就是说，所有的require操作，按照依赖关系，统一放到一个init.lua文件中。

module的概念，是在执行完module操作后，在_G存在一个全局table，用来记录模块信息（变量、函数）。一个文件中可以有多个module调用，获取_G[module_name]，写在module调用下方的代码用来填充模块。一个module也可以放到多个文件中进行填充。而且通常这些module文件，没有全局的返回值，LOADED[name] = true。

这样看来，module很像namespace的概念，一个全局环境中的作用域table。

要获得module，也可以在init.lua执行完之后，从_G环境中获取。LOADED[name]设置临时标记确实奏效。但是lua新版本干掉module之后，很多文件获取一个全局环境中的作用域table是这么做的：

local a = require("xxx")

这在发生循环引用时，hold在该文件中的局部变量是个LOADED[name]的临时标记（上例中为true），而非该文件的实际返回值。

### local require的做法

参考TypeScriptToLua的做法，B文件requireA文件，并获取A文件中的CClassA类定义，翻译后会变成如下格式：

RequireB.lua
```lua
-- ____exports：B文件返回值(LOADED[nameB])
-- CClassB：B文件定义的CClassB类
local ____exports = {}
____exports.CClassB = {}

-- ____RequireA:A文件返回值(LOADED[nameA])
-- CClassA：A文件定义的CClassA类
local ____RequireA = require("Game.RequireTest.RequireA")
local CClassA = ____RequireA.CClassA

local CClassB = ____exports.CClassB
CClassB.name = "CClassB"
CClassB.__index = CClassB
CClassB.prototype = {}
CClassB.prototype.__index = CClassB.prototype
CClassB.prototype.constructor = CClassB
...

-- CClassB调用CClassA的静态函数
function CClassB.prototype.showObj(self)
    if self.mem_obj then
        print(
            "name of obj from CClassB is " .. tostring(
                self.mem_obj:name()
            )
        )
    end
    print(
        "ClassA foo ",
        CClassA:foo()
    )
end
return ____exports
```

如上看来，____RequireA 和 ____RequireA.CClassA 在发生循环引用时，都会是临时的值。一个文件使用其他文件的定义时，使用了大量的local声明。虽然这样的操作可以提高虚拟机定位变量的效率，但是在发生循环引用时，读取到的临时的值，再访问其内容，可能会读到空值。

以上的例子，是在CClassB中调用CClassA的静态方法foo。

RequireB.ts
```typescript
import { CClassA } from "./RequireA";

export class CClassB {
    mem_name: string;
    mem_obj: CClassA | undefined;

    constructor() {
        this.mem_name = "Instance of B";
    }

    setObj(obj:CClassA): void {
        this.mem_obj = obj;
    }

    name():string {
        return this.mem_name;
    }
    
    showObj():void {
        if (this.mem_obj)
            console.log("name of obj from CClassB is " + this.mem_obj.name());
        console.log("ClassA foo ", CClassA.foo())
    }

    static foo(): string {
        return "hello B";
    }
}
```

其中____RequireA就是LOADED[nameA]。为了保证逻辑走通，需要重写require函数，做两个空表配合元表进行索引。为了方便通用性，在临时表里可以记下一些临时信息，把____RequireA 当成导出表exportTb，把____RequireA.CClassA当成类表classTb。索引顺序就成了

package.loaded[exportName][className][memberName]，也就是两级关系：

1. LOADED[name]临时空表。__index功能：找到LOADED[name]，获取Class。
当然，能走到__index就表示LOADED[name]未加载完，不可能得到实际的Class，所以这里返回的是第二个空表。
2. Class临时空表。__index功能：找到LOADED[name]，获取Class，找到Class的成员。
为了__index方便。这里的空表不是真的空，记录了一些临时的值：__exportName __className 

```lua
local _require = _G.require

local mt_class_member = {
    __index = function(intermedia, memberName)
        local exportName = intermedia.__exportName
        local className = intermedia.__className
        local exportTb = package.loaded[exportName]
        if exportTb and type(exportTb) == "table" then
            local classTb = exportTb[className]
            if classTb and type(classTb) == "table" then
                return classTb[memberName]
            end
        end
        return nil
    end
}

_G.require = function(name)
    if not package.loaded[name] then
        local filename = package.searchpath(name, package.path)
        if filename == nil then
            error("unable to load file " .. name)
        end
        
        local __exports = {}
        local mt = {
            __index = function(exports, className)
                local intermedia = {
                    __exportName = name,
                    __className = className,
                }
                setmetatable(intermedia, mt_class_member)
                return intermedia
            end,
        }
        setmetatable(__exports, mt)
        package.loaded[name] = __exports

        __exports = loadfile(filename)()
        if __exports ~= nil then
            package.loaded[name] = __exports
        else
            package.loaded[name] = true
        end
     end
     return package.loaded[name]
end
```

### local require 实现的继承关系

上面实现了在循环引用中，实现了B文件类访问A文件类。继承的实现会更加复杂，涉及到类的元表prototype（提供给实例化和子类）。这里举例B文件中有个D类继承自A文件的A类，我们来看一下 TypeScriptToLua 之后的结果

RequireB.lua
```lua
____exports.CClassD = {}
local CClassD = ____exports.CClassD
CClassD.name = "CClassD"
CClassD.__index = CClassD
CClassD.prototype = {}
CClassD.prototype.__index = CClassD.prototype
CClassD.prototype.constructor = CClassD
CClassD.____super = CClassA
setmetatable(CClassD, CClassD.____super)
setmetatable(CClassD.prototype, CClassD.____super.prototype)
...
```

关键在于这几句
```lua
CClassD.____super = CClassA
setmetatable(CClassD, CClassD.____super)
setmetatable(CClassD.prototype, CClassD.____super.prototype)
```

#### 两个新问题

1. CClassD.____super是CClassA，这里访问到了CClassA.prototype
较上例，这里多了一级关系 exportA -> CClassA -> CClassA.prototype
所以这里要准备三张临时空表和元表。

2. 这里会拿临时空表setmetatable。
我们知道临时空表是空的 {} --------> __index，我们给临时空表设置了__index，也方便它在外部local后能访问到正确的table中。也就是说表本身是没有元方法的。

也就是说上例的
```lua
setmetatable(CClassD, CClassD.____super)
```
实际上是
```lua
setmetatable(CClassD, {})，只是这个{}表有个metatable罢了
```
如果这里没有出现循环引用，其本意应该是
```lua
setmetatable(CClassD, {__index = ...})
```
CClassA声明时有一句
```lua
CClassA.__index = CClassA
```
所以这句的意思是，如果从CClassD找不到k-v，就去上层CClassA找。也就是CClassD[k]的访问。这样的情况，通常是类的new函数和静态函数。

同理
```lua
setmetatable(CClassD.prototype, CClassD.____super.prototype)
CClassA.prototype = {}
CClassA.prototype.__index = CClassA.prototype
```

做的是local obj = CClassD()后obj[k]的访问，也就是类的成员函数都写到prototype里了。
这个问题的关键就在于，我们如何将一张临时的空表，变成原来的CClassA.prototype。也就是说，需要重写setmetatable，如果元表mt是一张加载中的表，在__index中重新设置元表。

示例见 circle_require4ts0.lua


### 优化

上例代码中，发生一次循环引用，创建的临时空表和元表加起来要6张，空间复杂度过高。

这里使用将两张表合并成一张表的 luaer trick 做法，并且对于 prototype 临时表的处理避免修改 setmetatable。

最终成品见 circle_require4ts1.lua ，注释中【】的内容都是知识点。

## 总结

围绕循环引用，可以整理出一套面（tiao）试（xi）试（zhi）题（nan），来考察应聘者的专业等级：

1. 用 lua 脚本语言实现面向对象
2. 是否阅读过 lua 源码
3. require 机制是如何实现
4. 如何避免文件之间循环引用造成的死循环：A文件 require B文件，B文件 require A文件
5. 如何解决继承关系中出现的循环引用：上题环境中，B文件有个类 ClassB，其父类 ClassA 定义在A文件中。
6. 对于第5题给出的方案，评价空间复杂度，并尝试改进
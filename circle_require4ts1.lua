local __require = require
local checkLoading = {}

function require(path)
    if package.loaded[path] then
        -- 已加载
        return package.loaded[path]
    elseif checkLoading[path] then
        -- 加载中
        return checkLoading[path]
    else
        -- 未加载，创建临时表
        local __exports = get_table()
        -- 【在不修改原生 LOADED[name] 的基础上进行修改，这样才能保证原生 require 的正常调用】
        checkLoading[path] = __exports
        
        local r = __require(path)
        
        -- 【在循环引用发生时，对于 require 返回非 table 的 local 值的延迟定位表示无能为力】
        -- 此处应该是个 assert 才对。即编码规范要求：所有lua文件结尾都要 return 一张表。
        assert(type(r) == "table", "require(xxx) must return table!")

        -- 加载完，填充临时表
        for k, v in pairs(r) do
            __exports:set_cache(k, v)
        end
        __exports:reset()

		package.loaded[path] = __exports
		checkLoading[path] = nil
		return r
	end
end


--[[
    延迟定位：
    moduleTable 就是 require 文件过程中的临时表
    __cache 维护的是临时表中的内容，通常为 Class 所以会在索引时初始化 prototype。
    【moduleTable 的元表是其自身，这样可以节省一张表（luaer trick!）】
    发生循环引用时，临时表 moduleTable 会在 require 完成后填充，require 得到的表被弃用。
    三层关系 __exports -> ClassA -> prototype 在临时表中表现为
    moduleTable -> __cache[k] -> prototype
]]
function get_table()
    local moduleTable = {
        __cache = {},
        __index = function(t, k)
            if not t.__cache[k] then
                t.__cache[k] = {
                    prototype = {}
                }
            end
            return t.__cache[k]
        end,

        --[[
            这是从原生 require 读出的数据，实现临时表 __cache[k] 的 meta 中转
            k：类名
            tab：类表
        ]]
        set_cache = function(self, k, tab)
            self[k] = tab

            local t = self.__cache[k]
            if t then
                t.__index = tab
                setmetatable(t, t)

                t.prototype.__index = tab.prototype
                setmetatable(t.prototype, tab.prototype)
            end
        end,

        --[[
            reset 清空临时数据。
            之后 require 能拿到正常值。
            循环引用中的 local require 拿到的还是 moduleTable __cache[k] prototype 临时表
        ]]
        reset = function(self)
            self.__cache = nil
            self.__index = nil
            self.set_cache = nil
            self.reset = nil
            setmetatable(self, nil)
        end,
    }

    setmetatable(moduleTable, moduleTable)
    return moduleTable
end
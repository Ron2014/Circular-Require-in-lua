--[[ Generated with https://github.com/TypeScriptToLua/TypeScriptToLua ]]
-- Lua Library inline imports
function __TS__SourceMapTraceBack(fileName, sourceMap)
    _G.__TS__sourcemap = _G.__TS__sourcemap or {}
    _G.__TS__sourcemap[fileName] = sourceMap
    if _G.__TS__originalTraceback == nil then
        _G.__TS__originalTraceback = debug.traceback
        debug.traceback = function(thread, message, level)
            local trace = _G.__TS__originalTraceback(thread, message, level)
            local result = string.gsub(
                trace,
                "(%S+).lua:(%d+)",
                function(file, line)
                    local fileSourceMap = _G.__TS__sourcemap[tostring(file) .. ".lua"]
                    if fileSourceMap and fileSourceMap[line] then
                        return tostring(file) .. ".ts:" .. tostring(fileSourceMap[line])
                    end
                    return tostring(file) .. ".lua:" .. tostring(line)
                end
            )
            return result
        end
    end
end

__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["28"] = 1,["29"] = 1,["30"] = 3,["31"] = 3,["32"] = 3,["33"] = 3,["34"] = 3,["35"] = 3,["36"] = 3,["38"] = 3,["40"] = 3,["41"] = 3,["43"] = 8,["44"] = 7,["45"] = 11,["46"] = 12,["47"] = 11,["48"] = 15,["49"] = 16,["50"] = 15,["51"] = 19,["52"] = 20,["54"] = 21,["55"] = 21,["60"] = 22,["61"] = 22,["63"] = 19,["64"] = 25,["65"] = 26,["66"] = 25,["67"] = 30,["68"] = 30,["69"] = 30,["70"] = 30,["71"] = 30,["72"] = 30,["73"] = 30,["74"] = 30,["75"] = 30,["78"] = 30,["80"] = 30,["81"] = 30,["82"] = 31,["83"] = 32,["84"] = 31});
local ____exports = {}
local ____RequireB = require("RequireB")
local CClassB = ____RequireB.CClassB
____exports.CClassA = {}
local CClassA = ____exports.CClassA
CClassA.name = "CClassA"
CClassA.__index = CClassA
CClassA.prototype = {}
CClassA.prototype.__index = CClassA.prototype
CClassA.prototype.constructor = CClassA
function CClassA.new(...)
    local self = setmetatable({}, CClassA.prototype)
    self:____constructor(...)
    return self
end
function CClassA.prototype.____constructor(self)
    self.mem_name = "Instance of A"
end
function CClassA.prototype.setObj(self, obj)
    self.mem_obj = obj
end
function CClassA.prototype.name(self)
    return self.mem_name
end
function CClassA.prototype.showObj(self)
    if self.mem_obj then
        print(
            "name of obj from CClassA is " .. tostring(
                self.mem_obj:name()
            )
        )
    end
    print(
        "ClassB foo",
        CClassB:foo()
    )
end
function CClassA.foo(self)
    return "hello A"
end
____exports.CClassC = {}
local CClassC = ____exports.CClassC
CClassC.name = "CClassC"
CClassC.__index = CClassC
CClassC.prototype = {}
CClassC.prototype.__index = CClassC.prototype
CClassC.prototype.constructor = CClassC
CClassC.____super = CClassB
setmetatable(CClassC, CClassC.____super)
setmetatable(CClassC.prototype, CClassC.____super.prototype)
function CClassC.new(...)
    local self = setmetatable({}, CClassC.prototype)
    self:____constructor(...)
    return self
end
function CClassC.foo(self)
    return "hello C"
end
return ____exports

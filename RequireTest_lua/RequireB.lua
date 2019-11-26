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
local ____RequireA = require("RequireA")
local CClassA = ____RequireA.CClassA
____exports.CClassB = {}
local CClassB = ____exports.CClassB
CClassB.name = "CClassB"
CClassB.__index = CClassB
CClassB.prototype = {}
CClassB.prototype.__index = CClassB.prototype
CClassB.prototype.constructor = CClassB
function CClassB.new(...)
    local self = setmetatable({}, CClassB.prototype)
    self:____constructor(...)
    return self
end
function CClassB.prototype.____constructor(self)
    self.mem_name = "Instance of B"
end
function CClassB.prototype.setObj(self, obj)
    self.mem_obj = obj
end
function CClassB.prototype.name(self)
    return self.mem_name
end
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
function CClassB.foo(self)
    return "hello B"
end
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
function CClassD.new(...)
    local self = setmetatable({}, CClassD.prototype)
    self:____constructor(...)
    return self
end
function CClassD.foo(self)
    return "hello D"
end
return ____exports

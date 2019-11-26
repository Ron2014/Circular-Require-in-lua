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

__TS__SourceMapTraceBack(debug.getinfo(1).short_src, {["27"] = 1,["28"] = 1,["29"] = 2,["30"] = 2,["31"] = 4,["32"] = 5,["33"] = 7,["34"] = 8,["35"] = 10,["36"] = 11});
local ____RequireA = require("RequireA")
local CClassC = ____RequireA.CClassC
local ____RequireB = require("RequireB")
local CClassD = ____RequireB.CClassD
local b = CClassC.new()
local a = CClassD.new()
a:setObj(b)
b:setObj(a)
a:showObj()
b:showObj()

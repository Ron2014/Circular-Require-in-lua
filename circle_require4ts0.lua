local _require = _G.require
local _setmetatable = _G.setmetatable

_G.require = function(name)
    if not package.loaded[name] then
        local filename = package.searchpath(name, package.path)
        if filename == nil then
            error("unable to load file " .. name)
        end

        package.loaded[name] = get_table(name)

        local __exports = loadfile(filename)()
        if __exports ~= nil then
            package.loaded[name] = __exports
        else
            package.loaded[name] = true
        end
     end
     return package.loaded[name]
end

_G.setmetatable = function(tb, mt)
    if not mt.__isloading then
        return _setmetatable(tb, mt)
    end
    mt.__index = function(tb, k)
        local t = get_real_table(mt)
        assert(t, "can't find table!")
        setmetatable(tb, t)
        return tb[k]
    end
    _setmetatable(tb, mt)
end

function get_real_table(tb, class_name, member_name, field_name)
    local export_name = rawget(tb, "__export_name")
    local class_name = rawget(tb, "__class_name") or class_name
    local member_name = rawget(tb, "__member_name") or member_name

    local t = package.loaded[export_name]
    if not t or t.__isloading then
        return nil
    end

    if class_name then
        t = t[class_name]
    end
    if member_name then
        t = t[member_name]
    end
    if field_name then
        t = t[field_name]
    end
    return t
end

function member_find_field(member_tb, field_name)
    return get_real_table(member_tb, nil, nil, field_name)
end

function class_find_member(class_tb, member_name)
    local t = get_real_table(class_tb, nil, member_name)
    if t then return t end

    local ret = {
        __isloading = true,
        __export_name = class_tb.__export_name,
        __class_name = class_tb.__class_name,
        __member_name = member_name,
    }
    local mt = {
        __index = member_find_field,
    }
    setmetatable(ret, mt)
    return ret
end

function export_find_class(export_tb, class_name)
    local t = get_real_table(export_tb, class_name)
    if t then return t end

    local ret = {
        __isloading = true,
        __export_name = export_tb.__export_name,
        __class_name = class_name,
    }
    local mt = {
        __index = class_find_member,
    }
    setmetatable(ret, mt)
    return ret
end

function get_table(export_name)
    -- 此时 LOADED[name] 为 nil
    local ret = {
        __isloading = true,
        __export_name = export_name,
    }
    local mt = {
        __index = export_find_class,
    }
    setmetatable(ret, mt)
    return ret
end
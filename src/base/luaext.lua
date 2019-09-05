------------ 类型检查 ------------

-- 检查并尝试转换为数值，如果无法转换则返回 0
-- @param mixed value 要检查的值
-- @param [integer base] 进制，默认为十进制
function checknumber(value, base)
    return tonumber(value, base) or 0
end

-- 检查并尝试转换为整数，如果无法转换则返回 0
function checkint(value)
    return math.round(checknumber(value))
end

-- 检查并尝试转换为布尔值，除了 nil 和 false，其他任何值都会返回 true
function checkbool(value)
    return (value ~= nil and value ~= false)
end

-- 检查值是否是一个表格，如果不是则返回一个空表格
function checktable(value)
    if type(value) ~= "table" then value = {} end
    return value
end

-- 如果表格中指定 key 的值为 nil，或者输入值不是表格，返回 false，否则返回 true
-- @param table t 要检查的表格
-- @param mixed key 要检查的键名
function isset(t, key)
    local t = type(t)
    return (t == "table" or t == "userdata") and t[key] ~= nil
end


------------ table扩展 ------------

-- 返回table大小
function table.size(t)
	local count = 0
	for _ in pairs(t) do
		count = count + 1
	end
	return count
end

-- 判断table是否为空
function table.empty(t)
    return not next(t)
end

-- 返回table索引列表
function table.keys(t)
    local result = {}
    for k, v in pairs(t) do
        table.insert(result, k)
    end
    return result
end

-- 返回table值列表
function table.values(t)
    local result = {}
    for k, v in pairs(t) do
        table.insert(result, v)
    end
    return result
end

-- 合并table
-- @param table dest 目标表格
-- @param table src 来源表格
function table.merge(dest, src)
    for k, v in pairs(src) do
        dest[k] = v
    end
end

-- 从表格中查找指定值，返回其 key，如果没找到返回 nil
-- @param table hashtable 表格
-- @param mixed value 要查找的值
function table.keyof(t, value)
    for k, v in pairs(t) do
        if v == value then return k end
    end
    return nil
end

-- 对表格中每一个值执行一次指定的函数，并用函数返回值更新表格内容
-- @param table t 表格
-- @param function fn 函数
function table.map(t, fn)
    for k, v in pairs(t) do
        t[k] = fn(v, k)
    end
end

-- 对表格中每一个值执行一次指定的函数，但不改变表格内容
-- @param table t 表格
-- @param function fn 函数
function table.walk(t, fn)
    for k,v in pairs(t) do
        fn(v, k)
    end
end

-- 对表格中每一个值执行一次指定的函数，如果该函数返回 false，则对应的值会从表格中删除
-- @param table t 表格
-- @param function fn 函数
function table.filter(t, fn)
    for k, v in pairs(t) do
        if not fn(v, k) then t[k] = nil end
    end
end

-- 遍历表格，确保其中的值唯一（去重）
function table.unique(t)
    local check = {}
    local n = {}
    for k, v in pairs(t) do
        if not check[v] then
            n[k] = v
            check[v] = true
        end
    end
    return n
end

--比较两个table，相同返回true，不相同返回false
function table.compare(t1, t2)
    if type(t1) ~= "table" or type(t2) ~= "table" then return false end

    for i, v in pairs(t1) do
        if type(v) == "table" then
            if t2[i] then
                local rst = table.compare(v, t2[i])
                if not rst then return false end
            end
        else
            if t2[i] ~= v then return false end
        end
    end

    for i, v in pairs(t2) do
        if type(v) == "table" then
            if t1[i] then
                local rst = table.compare(v, t1[i])
                if not rst then return false end
            end
        else
            if t1[i] ~= v then return false end
        end
    end

    return true
end

-- 从数组中查找指定值，返回其索引，如果没找到返回 false
-- @param table a 数值
-- @param mixed value 要查找的值
-- @param [integer begin] 起始索引值
function table.indexof(a, value, begin)
    for i = begin or 1, #a do
        if a[i] == value then return i end
    end
    return false
end

-- 插入数组
-- @param table dest 目标数组
-- @param table src 来源数组
-- @param [integer begin] 插入位置
function table.insertto(dest, src, begin)
    begin = checkint(begin)
    if begin <= 0 then
        begin = #dest + 1
    end

    local len = #src
    for i = 0, len - 1 do
        dest[i + begin] = src[i + 1]
    end
end

-- 截取一个数组的一部分
-- @begin 起始下标（<0表示从后往前算）
-- @length 截取长度（nil表示后面所有）
function table.slice(a, begin, length)
    local part = {}

    local n = #a
    if n > 0 then
        begin = math.max(1, begin < 0 and n + begin + 1 or begin)
        length = length and math.min(n - begin + 1, length) or n - begin + 1
        for i = 1, length do
            part[i] = a[begin + i - 1]
        end
    end

    return part
end

-- 从数组中删除指定值，返回删除的值的个数
-- @param table a 数组
-- @param mixed value 要删除的值
-- @param [boolean removeall] 是否删除所有相同的值
function table.removebyvalue(a, value, removeall)
    local c, i, max = 0, 1, #a
    while i <= max do
        if a[i] == value then
            table.remove(a, i)
            c = c + 1
            i = i - 1
            max = max - 1
            if not removeall then break end
        end
        i = i + 1
    end
    return c
end

-- 数组翻转
function table.revert(a)
    local rt = {}
    local n = #a + 1
    for i, v in ipairs(a) do
        rt[n - i] = v
    end
    return rt
end

-- 产生一个[min, max]拿count个不重复的随机数组
function table.randomvalues(min, max, count)
    if (max < min) or (count > max - min + 1) then return end

    local rt = {}
    local arr = {}
    for i = min, max do table.insert(arr, i) end --生成一个[a, b]的数组

    local len = #arr
    for i = 1, count do
        if i < len then
            local j = math.random(i + 1, len)
            local tmp = arr[i]
            arr[i] = arr[j]
            arr[j] = tmp
        end

        table.insert(rt, arr[i])
    end

    return rt
end

-- weights概率权重表，如{10 ，30 ，40} ，count生成的随机序列个数,返回随机序列
function table.randomindexs(weights, count)
    local total = 0
    for k, v in pairs(weights) do
        total = total + v
    end

    local tb = {}
    for i = 1, count do
        local s = math.random(1, total)
        for k, v in pairs(weights) do
            if s <= v then
                table.insert(tb, k)
                break
            else
                s = s - v
            end
        end
    end
    return tb
end

-- 将一个数组内元素随机洗牌
function table.shuffle(a)
    local len = #a
    for i = len, 1, -1 do
        local j = math.random(1, len)
        a[i], a[j] = a[j], a[i]
    end

    return a
end


------------ string扩展 ------------

string._htmlspecialchars_set = {}
string._htmlspecialchars_set["&"] = "&amp;"
string._htmlspecialchars_set["\""] = "&quot;"
string._htmlspecialchars_set["'"] = "&#039;"
string._htmlspecialchars_set["<"] = "&lt;"
string._htmlspecialchars_set[">"] = "&gt;"

-- 将特殊字符转为 HTML 转义符
function string.htmlspecialchars(s)
    for k, v in pairs(string._htmlspecialchars_set) do
        s = string.gsub(s, k, v)
    end
    return s
end

 -- 将 HTML 转义符还原为特殊字符，功能与 string.htmlspecialchars() 正好相反
function string.restorehtmlspecialchars(s)
    for k, v in pairs(string._htmlspecialchars_set) do
        s = string.gsub(s, v, k)
    end
    return s
end

-- 将字符串中的 \n 换行符转换为 HTML 标记
function string.nl2br(s)
    return string.gsub(s, "\n", "<br />")
end

-- 将字符串中的特殊字符和 \n 换行符转换为 HTML 转移符和标记
function string.text2html(s)
    s = string.gsub(s, "\t", "    ")
    s = string.htmlspecialchars(s)
    s = string.gsub(s, " ", "&nbsp;")
    s = string.nl2br(s)
    return s
end

-- 用指定字符或字符串分割输入字符串，返回包含分割结果的数组
-- @param string s 输入字符串
-- @param string delimiter 分割标记字符或字符串
function string.split(s, delimiter)
    local split = {}
    local pattern = "[^" .. delimiter .. "]+"
    string.gsub(s, pattern, function(v)
        table.insert(split, v)
    end)
    return split
end

-- 去除输入字符串头部的空白字符，返回结果
function string.ltrim(s)
    return string.gsub(s, "^[ \t\n\r]+", "")
end

-- 去除输入字符串尾部的空白字符，返回结果
function string.rtrim(s)
    return string.gsub(s, "[ \t\n\r]+$", "")
end

-- 去掉字符串首尾的空白字符，返回结果
function string.trim(s)
    return string.rtrim(string.ltrim(s))
end

-- 将字符串的第一个字符转为大写，返回结果
function string.ucfirst(s)
    return string.upper(string.sub(s, 1, 1)) .. string.sub(s, 2)
end

-- 将字符串转换为符合 URL 传递要求的格式，并返回转换结果
function string.urlencode(s)
    -- convert line endings
    s = string.gsub(tostring(s), "\n", "\r\n")
    -- escape all characters but alphanumeric, '.' and '-'
    s = string.gsub(s, "([^%w%.%- ])", function (v)
        return "%" .. string.format("%02X", string.byte(v))
    end)
    -- convert spaces to "+" symbols
    return string.gsub(s, " ", "+")
end

-- 将 URL 中的特殊字符还原，并返回结果
function string.urldecode(s)
    s = string.gsub (s, "+", " ")
    s = string.gsub (s, "%%(%x%x)", function(v)
        return string.char(checknumber(v,16))
    end)
    s = string.gsub (s, "\r\n", "\n")
    return s
end

-- 计算 UTF8 字符串的长度，每一个中文算一个字符
function string.utf8len(s)
    local len  = string.len(s)
    local left = len
    local cnt  = 0
    local arr  = {0, 0xc0, 0xe0, 0xf0, 0xf8, 0xfc}
    while left ~= 0 do
        local tmp = string.byte(s, -left)
        local i   = #arr
        while arr[i] do
            if tmp >= arr[i] then
                left = left - i
                break
            end
            i = i - 1
        end
        cnt = cnt + 1
    end
    return cnt
end

-- 将数值格式化为包含千分位分隔符的字符串
-- @param number num 数值
function string.formatnumberthousands(num)
    local formatted = tostring(checknumber(num))
    local k
    while true do
        formatted, k = string.gsub(formatted, "^(-?%d+)(%d%d%d)", '%1,%2')
        if k == 0 then break end
    end
    return formatted
end

-- 字符串转16进制
-- @param string s 原字符串
-- @param number ln 换行位置（可选）
-- @param string sep 分隔符（可选）
--	string.tohex('abcdef', 4, ":") => '61:62:63:64\n65:66'
--	string.tohex('abcdef') => '616263646566'
function string.tohex(s, ln, sep)
	if #s == 0 then return "" end
	if not ln then -- no newline, no separator: do it the fast way!
		return (s:gsub('.',
			function(c) return string.format('%02x', string.byte(c)) end
			))
	end
	sep = sep or "" -- optional separator between each byte
	local t = {}
	for i = 1, #s - 1 do
		t[#t + 1] = string.format("%02x%s", s:byte(i),
				(i % ln == 0) and '\n' or sep)
	end
	-- last byte, without any sep appended
	t[#t + 1] = string.format("%02x", s:byte(#s))
	return string.concat(t)
end

-- 16进制转字符串
-- @param string hs 16进制串
-- @param bool unsafe 不安全（可选）
function string.hexto(hs, unsafe)
	local tonumber = tonumber
	if not unsafe then
		hs = string.gsub(hs, "%s+", "") -- remove whitespaces
		if string.find(hs, '[^0-9A-Za-z]') or #hs % 2 ~= 0 then
			error("invalid hex string")
		end
	end
	return hs:gsub(	'(%x%x)',
		function(c) return string.char(tonumber(c, 16)) end
		)
end


------------ math扩展 ------------

-- 对数值进行四舍五入，如果不是数值则返回 0
function math.round(num)
    return math.floor(num + 0.5)
end

-- 角度转弧度
function math.angle2radian(angle)
    return angle*math.pi/180
end

-- 弧度转角度
function math.radian2angle(radian)
    return radian/math.pi*180
end


------------ io扩展 ------------

-- 检查指定的文件或目录是否存在，如果存在返回 true，否则返回 false
function io.exists(path)
    local file = io.open(path, "r")
    if file then
        io.close(file)
        return true
    end
    return false
end

-- 读取文件内容，返回包含文件内容的字符串，如果失败返回 nil
function io.readfile(path)
    local file = io.open(path, "r")
    if file then
        local content = file:read("*a")
        io.close(file)
        return content
    end
    return nil
end

-- 以字符串内容写入文件，成功返回 true，失败返回 false
-- @param string path 文件完全路径
-- @param string content 要写入的内容
-- @param [string mode] 写入模式，默认值为 "w+b"
-- "w+" : 覆盖文件已有内容，如果文件不存在则创建新文件
-- "a+" : 追加内容到文件尾部，如果文件不存在则创建文件
-- 此外，还可以在 "写入模式" 参数最后追加字符 "b" ，表示以二进制方式写入数据，这样可以避免内容写入不完整。
-- Android 特别提示: 在 Android 平台上，文件只能写入存储卡所在路径，assets 和 data 等目录都是无法写入的。
function io.writefile(path, content, mode)
    mode = mode or "w+b"
    local file = io.open(path, mode)
    if file then
        if file:write(content) == nil then return false end
        io.close(file)
        return true
    else
        return false
    end
end

-- 拆分一个路径字符串，返回组成路径的各个部分
function io.pathinfo(path)
    local pos = string.len(path)
    local extpos = pos + 1
    while pos > 0 do
        local b = string.byte(path, pos)
        if b == 46 then -- 46 = char "."
            extpos = pos
        elseif b == 47 then -- 47 = char "/"
            break
        end
        pos = pos - 1
    end

    local dirname = string.sub(path, 1, pos)
    local filename = string.sub(path, pos + 1)
    extpos = extpos - pos
    local basename = string.sub(filename, 1, extpos - 1)
    local extname = string.sub(filename, extpos)
    return {
        dirname = dirname,
        filename = filename,
        basename = basename,
        extname = extname
    }
end

-- 返回指定文件的大小，如果失败返回 false
function io.filesize(path)
    local size = false
    local file = io.open(path, "r")
    if file then
        local current = file:seek()
        size = file:seek("end")
        file:seek("set", current)
        io.close(file)
    end
    return size
end


------------ 面向对象扩展 ------------

-- 创建一个类
function class(classname, super)
    local superType = type(super)
    local cls

    if superType ~= "function" and superType ~= "table" then
        superType = nil
        super = nil
    end

    if superType == "function" or (super and super.__ctype == 1) then
        -- inherited from native C++ Object
        cls = {}

        if superType == "table" then
            -- copy fields from super
            for k,v in pairs(super) do cls[k] = v end
            cls.__create = super.__create
            cls.super    = super
        else
            cls.__create = super
            cls.ctor = function() end
        end

        cls.__cname = classname
        cls.__ctype = 1

        function cls.new(...)
            local instance = cls.__create(...)
            -- copy fields from class to native object
            for k,v in pairs(cls) do instance[k] = v end
            instance.class = cls
            instance:ctor(...)
            return instance
        end

    else
        -- inherited from Lua Object
        if super then
            cls = {}
            setmetatable(cls, {__index = super})
            cls.super = super
        else
            cls = {ctor = function() end}
        end

        cls.__cname = classname
        cls.__ctype = 2 -- lua
        cls.__index = cls

        function cls.new(...)
            local instance = setmetatable({}, cls)
            instance.class = cls
            instance:ctor(...)
            return instance
        end
    end

    return cls
end

function iskindof(obj, classname)
    local t = type(obj)
    local mt
    if t == "table" then
        mt = getmetatable(obj)
    elseif t == "userdata" then
        mt = tolua.getpeer(obj)
    end

    while mt do
        if mt.__cname == classname then
            return true
        end
        mt = mt.super
    end

    return false
end

------------ 工具扩展 ------------

-- 将 Lua 对象及其方法包装为一个匿名函数
function handler(obj, method)
    return function(...)
        return method(obj, ...)
    end
end

-- 对象转字符串
function dump(obj)
    local getIndent, quoteStr, wrapKey, wrapVal, dumpObj
    getIndent = function(level)
        return string.rep("\t", level)
    end
    quoteStr = function(str)
        return '"' .. string.gsub(str, '"', '\\"') .. '"'
    end
    wrapKey = function(val)
        if type(val) == "number" then
            return "[" .. val .. "]"
        elseif type(val) == "string" then
            return "[" .. quoteStr(val) .. "]"
        else
            return "[" .. tostring(val) .. "]"
        end
    end
    wrapVal = function(val, level)
        if type(val) == "table" then
            return dumpObj(val, level)
        elseif type(val) == "number" then
            return val
        elseif type(val) == "string" then
            return quoteStr(val)
        else
            return tostring(val)
        end
    end
    dumpObj = function(obj, level)
        if type(obj) ~= "table" then
            return wrapVal(obj)
        end
        level = level + 1
        local tokens = {}
        tokens[#tokens + 1] = "{"
        for k, v in pairs(obj) do
            tokens[#tokens + 1] = getIndent(level) .. wrapKey(k) .. " = " .. wrapVal(v, level) .. ","
        end
        tokens[#tokens + 1] = getIndent(level - 1) .. "}"
        return table.concat(tokens, "\n")
    end
    return dumpObj(obj, 0)
end

-- 克隆对象
function clone(obj)
    local lookup_table = {}
    local function _copy(obj)
        if type(obj) ~= "table" then
            return obj
        elseif lookup_table[obj] then
            return lookup_table[obj]
        end
        local new_table = {}
        lookup_table[obj] = new_table
        for key, value in pairs(obj) do
            new_table[_copy(key)] = _copy(value)
        end
        return setmetatable(new_table, getmetatable(obj))
    end
    return _copy(obj)
end

-- 拷贝对象
function copy(obj)
    if not obj then return obj end
     local new = {}
     for k, v in pairs(obj) do
        local t = type(v)
        if t == "table" then
            new[k] = copy(v)
        elseif t == "userdata" then
            new[k] = copy(v)
        else
            new[k] = v
        end
     end
    return new
end
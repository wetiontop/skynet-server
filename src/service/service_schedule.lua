--author:liujinpeng
local skynet = require "skynet"
local nodename = skynet.getenv("nodename")

local CMD = {}

local schedule_configs = {}

local min_interval = 0.01 --skynet内定的最小时间间隔，0.01秒

local timer_interval = 1 --计时器tick间隔,单位秒(建议默认60秒)

local function split(inputstr, sep)
    if sep == nil then
        sep = "%s"
    end
    local t = {}
    local i = 1
    for str in string.gmatch(inputstr, "([^"..sep.."]+)") do
        t[i] = str
        i = i + 1
    end
    return t
end

local function parse_config(inputstr, limit_min, limit_max)
    if limit_min > limit_max then
        return {}
    end
    local set = {}
    local range_set = split(inputstr, ",")
    for _, str in pairs(range_set) do
        local limits = split(str, "-")
        if #limits >= 2 then
            local min = tonumber(limits[1])
            local max = tonumber(limits[2])
            if max > min and min >= limit_min and min <= limit_max and max >= limit_min and max <= limit_max then
                for i = min, max do
                    table.insert(set, i)
                end
            end
        elseif #limits == 1 then
            local value = tonumber(limits[1])
            if value >= limit_min and value <= limit_max then
                table.insert(set, value)
            end
        end
    end
    return set
end

local function parse_months_str(months)
    return parse_config(months, 1, 12)
end

local function parse_weeks_str(weeks)
    return parse_config(weeks, 1, 7)
end

local function parse_days_str(days)
    return parse_config(days, 1, 31)
end

local function parse_hours_str(hours)
    return parse_config(hours, 0, 23)
end

local function parse_minutes_str(minutes)
    return parse_config(minutes, 0, 59)
end

local function get_movements(schedule_config, now_time)
    if schedule_config == nil or next(schedule_config) == nil then
        return {}
    end

    if schedule_config.months == nil or
        schedule_config.weeks == nil or
        schedule_config.days == nil or
        schedule_config.hours == nil or
        schedule_config.minutes == nil then
        return {}
    end

    local next_movements = {}

    local now_date = os.date("*t", now_time)

    if #schedule_config.weeks > 0 then--星期模式
        assert(#schedule_config.months < 1 and #schedule_config.days < 1)
        local week_set = parse_weeks_str(schedule_config.weeks)
        if #week_set < 1 then
            return {}
        end
        for _, week in pairs(week_set) do
            local hour_set = parse_hours_str(schedule_config.hours)
            if #hour_set < 1 then
                return {}
            end
            for _, hour in pairs(hour_set) do
                local minute_set = parse_minutes_str(schedule_config.minutes)
                if #minute_set < 1 then
                    return {}
                end
                for _, minute in pairs(minute_set) do
                    local nt =
                    {
                        year = now_date.year,
                        month = now_date.month,
                        day = now_date.day + week - (now_date.wday - 1) % 7,
                        hour = hour,
                        min = minute,
                        sec = 0,
                    }
                    local next_movement = os.time(nt)
                    if next_movement < now_time then
                        nt.day = nt.day + 7
                        next_movement = os.time(nt)
                    end
                    table.insert(next_movements, next_movement)
                end
            end
        end
    else--普通模式
        local month_set = parse_months_str(schedule_config.months)
        if #month_set < 1 then
            return {}
        end
        for _, month in pairs(month_set) do
            local day_set = parse_days_str(schedule_config.days)
            if #day_set < 1 then
                return {}
            end
            for _, day in pairs(day_set) do
                local hour_set = parse_hours_str(schedule_config.hours)
                if #hour_set < 1 then
                    return {}
                end
                for _, hour in pairs(hour_set) do
                    local minute_set = parse_minutes_str(schedule_config.minutes)
                    if #minute_set < 1 then
                        return {}
                    end
                    for _, minute in pairs(minute_set) do
                        local nt =
                        {
                            year = now_date.year,
                            month = month,
                            day = day,
                            hour = hour,
                            min = minute,
                            sec = 0,
                        }
                        local next_movement = os.time(nt)
                        if next_movement < now_time then
                            nt.year = nt.year + 1
                            next_movement = os.time(nt)
                        end
                        table.insert(next_movements, next_movement)
                    end
                end
            end
        end
    end
    table.sort(next_movements)
    --[[--debug info
    for k, v in ipairs(next_movements) do
        skynet.error(string.format("k:%s, v:%s", k, v))
    end
    ]]
    return next_movements
end

local function get_start_index(schedule_config, movements, now_time)
    if movements == nil or next(movements) == nil then
        return -1
    else
        for i, time in pairs(movements) do
            if time > now_time then
                return i
            end
        end
        --应该重新计算时刻表
        movements = get_movements(schedule_config, now_time)
        if movements == nil or next(movements) == nil then
            return -1
        else
            for i, time in pairs(movements) do
                if time > now_time then
                    return i
                end
            end
        end
        return -1
    end
end

--返回id对应配置里面的下个时刻
local function next_time(id)
    if schedule_configs[id] then
        local index = schedule_configs[id].next_index;
        if index <= 0 then
            return 0
        end
        skynet.error(string.format("id: %s: movements index %s:",id, index))
        local count = #schedule_configs[id].movements
        skynet.error(string.format("id: %s: movements count %s:",id, count))
        if index > count then
            --重新更新时刻表，因为此时下个时刻可能已经不在当前周期了
            local now_time = math.floor(skynet.time())
            local movements = get_movements(schedule_configs[id].config, now_time)
            if movements == nil or next(movements) == nil then
                return 0
            end
            local index = get_start_index(schedule_configs[id].config, movements, now_time)
            schedule_configs[id].movements = movements
            schedule_configs[id].next_index = index
            if index < 0 then
                return 0
            end
        end
        if index > 0 and index <= #schedule_configs[id].movements then
            return schedule_configs[id].movements[index]
        end
    end
    return 0
end

--可用于测试或者调试，设置计时器间隔，单位为秒，默认1分钟，最小不能小于0.01秒
function CMD.set_interval(interval)
    local error_info = ""
    if interval < min_interval then
        error_info = "interval much tiny, set failed"
        skynet.error(error_info)
        return false, error_info
    else
        timer_interval = interval
        error_info = "set_internal " .. interval .. " ok"
        skynet.error(error_info)
        return true, error_info
    end
end

--可用于测试或者调试，加速某个任务的计时器tick_count个周期，即tick_count*timer_interval时间
function CMD.add_tick(source, func, tick_count)
    local id = tostring(source) .. "-" .. "func"
    local error_info = ""
    if schedule_configs[id] then
        if tick_count < 0 then
            error_info = "added tick_count should be positive, add_tick failed"
            skynet.error(error_info)
            return false, error_info
        end
        schedule_configs[id].tick_count = schedule_configs[id].tick_count + tick_count
        error_info = "add_tick " .. tick_count .. " ok"
        skynet.error(error_info)
        return true, error_info
    else
        error_info = "this id not be used, add_tick failed"
        skynet.error(error_info)
        return false, error_info
    end
end

--schedule_config = {months = "", weeks = "", days = "", hours = "", minutes = "" }
function CMD.add_schedule(source, func, args, schedule_config)
    local id = tostring(source) .. "-" .. "func"
    local error_info = ""
    assert(type(args) == "table")
    assert(type(schedule_config) == "table")
    if not schedule_configs[id] then
        local now_time = math.floor(skynet.time())
        local movements = get_movements(schedule_config, now_time)
        if movements == nil or next(movements) == nil then
            error_info = "schedule config is invalid! add schedule failed!"
            skynet.error(error_info)
            return false, error_info
        end
        local next_index = get_start_index(schedule_config, movements, now_time)
        if next_index < 0 then
            error_info = "schedule config time is late now time! add schedule failed!"
            skynet.error(error_info)
            return false, error_info
        end
        schedule_configs[id] =
        {
            source = source,
            func = func,
            config = schedule_config,
            config2 = schedule_config,
            args = args,
            start_time = now_time,
            movements = movements,
            next_index = next_index,
            tick_count = 0,
            exec_count = 0,
            changed = false,
            removed = false,
        }
        error_info = "add_schedule ok"
        skynet.error(error_info)
        return true, error_info
    else
        error_info = "this id already had schedule_config! add schedule failed"
        skynet.error(error_info)
        return false, error_info
    end
end

function CMD.change_schedule(source, func, schedule_config)
    local id = tostring(source) .. "-" .. "func"
    local error_info = ""
    assert(type(schedule_config) == "table")
    if schedule_configs[id] then
        local now_time = math.floor(skynet.time())
        local movements = get_movements(schedule_config, now_time)
        if movements == nil or next(movements) == nil then
            error_info = "schedule config is invalid, change failed"
            skynet.error(error_info)
            return false, error_info
        end
        local next_index = get_start_index(schedule_config, movements, now_time)
        if next_index < 0 then
            error_info = "schedule config time is late now time, change failed"
            skynet.error(error_info)
            return false, error_info
        end

        schedule_configs[id].changed = true
        schedule_configs[id].config2 = schedule_config

        error_info = "change_schedule ok"
        skynet.error(error_info)
        return true, error_info
    else
        error_info = "this id not be used, change failed!"
        skynet.error(error_info)
        return false, error_info
    end
end

function CMD.remove_schedule(source, func)
    local id = tostring(source) .. "-" .. "func"
    local error_info = ""
    if schedule_configs[id] then
        schedule_configs[id].removed = true
        error_info = "remove_schedule ok"
        skynet.error(error_info)
        return true, error_info
    else
        error_info = "this id not be used, remove failed"
        skynet.error(error_info)
        return false, error_info
    end
end

local function schedule_timer()
    while true do
        for id, t in pairs(schedule_configs) do
            if t.changed then
                t.config = t.config2
                local now_time = math.floor(skynet.time())
                local movements = get_movements(t.config, now_time)
                if movements == nil or next(movements) == nil then
                    skynet.error("schedule config is invalid, change failed")
                end
                local next_index = get_start_index(t.config, movements, now_time)
                if next_index < 0 then
                    skynet.error("schedule config time is late now time, change failed")
                end
                t.start_time = now_time
                t.movements = movements
                t.next_index = next_index
                t.changed = false
            end
            if t.next_index <= 0 or t.removed then
                schedule_configs[id] = nil
            end
        end
        for id, t in pairs(schedule_configs) do
            if t.next_index >= 0 then
                local next_movement = next_time(id)
                skynet.error(string.format("id: %s next_movement: %s", id, next_movement))
                if next_movement > 0 then
                    skynet.error(string.format("id: %s start_time: %s", id, t.start_time))
                    skynet.error(string.format("id: %s tick_count: %s", id, t.tick_count))
                    if t.start_time + t.tick_count * timer_interval >= next_movement then
                        skynet.send(t.source, "lua", t.func, t.args)
                        t.exec_count = t.exec_count + 1
                        t.next_index = t.next_index + 1
                    end
                    skynet.error(string.format("id: %s next_index: %s", id, t.next_index))
                end
            end
            t.tick_count = t.tick_count + 1
        end
        skynet.error("timer_interval:", timer_interval)
        skynet.sleep(math.floor(timer_interval / min_interval))
    end
end

skynet.start(function ()
    log.info("===>>> start %s node schedule service", nodename)

    skynet.dispatch("lua", function(_, source, cmd, ...)
        local func = assert(CMD[cmd], cmd .. " not found")
        if func then
            skynet.ret(skynet.pack(func(source, ...)))
        end
    end)

    skynet.fork(schedule_timer)
end)
local skynet = require "skynet"

local nodename = skynet.getenv("nodename")

local log_file = nil
local last_cycle = -1
local log_path = skynet.getenv("log_path")
local log_cycle = skynet.getenv("log_cycle")
local def_level = skynet.getenv("log_level")

local LOG_LEVEL = {
    DEBUG   = 1,
    INFO    = 2,
    WARN    = 3,
    ERROR   = 4,
    FATAL   = 5
}

local LOG_LEVEL_DESC = {
    [1] = "DEBUG",
    [2] = "INFO",
    [3] = "WARN",
    [4] = "ERROR",
    [5] = "FATAL",
}

-- 设置默认等级
local OUT_PUT_LEVEL = LOG_LEVEL.DEBUG
if LOG_LEVEL[def_level] then
    OUT_PUT_LEVEL = LOG_LEVEL[def_level]
else
    if LOG_LEVEL_DESC[def_level] then
        OUT_PUT_LEVEL = def_level
    end
end

local function get_cycle(date)
	local cycle
	if log_cycle == "year" then
		cycle = date.year
	elseif log_cycle == "month" then
		cycle = date.month
	elseif log_cycle == "day" then
		cycle = date.day
	elseif log_cycle == "hour" then
		cycle = date.hour
	elseif log_cycle == "min" then
		cycle = date.min
	else
		cycle = date.sec
	end
	return cycle
end

local function check_exists(path)
	if not os.rename(path, path) then
		os.execute("mkdir " .. path)
	end
end

local function file_path(date)
	local date_fmt
	if log_cycle == "year" then
		date_fmt = string.format("%04d", date.year)
	elseif log_cycle == "month" then
		date_fmt = string.format("%04d-%02d", date.year, date.month)
	elseif log_cycle == "day" then
		date_fmt = string.format("%04d-%02d-%02d", date.year, date.month, date.day)
	elseif log_cycle == "hour" then
		date_fmt = string.format("%04d-%02d-%02d-%02d", date.year, date.month, date.day, date.hour)
	elseif log_cycle == "min" then
		date_fmt = string.format("%04d-%02d-%02d-%02d:%02d", date.year, date.month, date.day, date.hour, date.min)
	else
		date_fmt = string.format("%04d-%02d-%02d-%02d:%02d:%02d", date.year, date.month, date.day, date.hour, date.min, date.sec)
	end
	return string.format("%s%s_%s.log", log_path, nodename, date_fmt)
end

local function open_file(date)
	check_exists(log_path)

	if log_file then
		log_file:close()
		log_file = nil
	end

	local file, err = io.open(file_path(date), "a")
	if not file then
		print("logger error:", tostring(err))
		return
	end

	log_file = file
	last_cycle = get_cycle(date)
end

local function log_time(date)
	return string.format("%02d:%02d:%02d.%02d", date.hour, date.min, date.sec, math.floor(skynet.time()*100%100))
end

local function format(fmt, ...)
    local ok, str = pcall(string.format, fmt, ...)
    if ok then
        return str
    else
        return "error format : " .. fmt
    end
end

local function write_file(date, msg)
	local cycle = get_cycle(date)
	if not log_file or cycle ~= last_cycle then
		open_file(date)
	end

	log_file:write(msg .. '\n')
	log_file:flush()
end

local function send_mail(date, msg)
	-- TODO
end

local function print_log(level, ...)
    if level < OUT_PUT_LEVEL then
        return
    end

    local str
    if select("#", ...) == 1 then
        str = tostring(...)
    else
        str = format(...)
    end

    local info = debug.getinfo(3)
	if info then
		local filename = string.match(info.short_src, "[^/.]+.lua")
		str = string.format("[%s:%d] %s", filename, info.currentline, str)
    end

    local date = os.date("*t")
	local msg = string.format("[%s][%s]%s", log_time(date), LOG_LEVEL_DESC[level], str)
    skynet.error(msg)

	write_file(date, msg)

	-- 致命错误发送邮件
	if level >= LOG_LEVEL.ERROR then
		send_mail(date, msg)
	end
end


local log = {}

function log.debug(fmt, ...)
	print_log(LOG_LEVEL.DEBUG, fmt, ...)
end

function log.info(fmt, ...)
 	print_log(LOG_LEVEL.INFO, fmt, ...)
end

function log.warn(fmt, ...)
 	print_log(LOG_LEVEL.WARN, fmt, ...)
end

function log.error(fmt, ...)
 	print_log(LOG_LEVEL.ERROR, fmt, ...)
end

function log.fatal(fmt, ...)
	print_log(LOG_LEVEL.FATAL, fmt, ...)
end

return log
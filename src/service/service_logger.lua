local skynet = require "skynet"
require "skynet.manager"

local CMD = {}

skynet.register_protocol {
	name = "text",
	id = skynet.PTYPE_TEXT,
	unpack = skynet.tostring,
    dispatch = function(_, address, msg)
		log.debug(string.format("[%08x]: %s", address, msg))
	end
}

skynet.register_protocol {
	name = "SYSTEM",
	id = skynet.PTYPE_SYSTEM,
	unpack = function(...) return ... end,
	dispatch = function(_, _)
		log.fatal("SIGHUP")
	end
}

skynet.start(function()
	skynet.register(".logger")

    skynet.dispatch("lua", function(_, _, cmd, ...)
        local func = assert(CMD[cmd], cmd .. " not found")
        if func then
            func(...)
        end
	end)
end)